--DAL Temporal Selves
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_DESTROYED)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --(2) Destroy
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCondition(aux.exccon)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.destg)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Special Summon
function s.spfilter1(c,e,tp)
  return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
  and c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsSetCard(SET_DALSPIRIT) and c:IsCanBeEffectTarget(e)
  and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND,0,1,nil,c:GetCode(),e,tp)
  and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spfilter2(c,code,e,tp)
  return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return eg:IsContains(chkc) and s.spfilter1(chkc,e,tp) end
  if chk==0 then return eg:IsExists(s.spfilter1,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=eg:FilterSelect(tp,s.spfilter1,1,1,nil,e,tp)
  Duel.SetTargetCard(g)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local ft=Duel.GetMZoneCount(tp)
  if ft<=0 then return end
  if ft>3 then ft=3 end
  if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
  local fid=e:GetHandler():GetFieldID()
  local tc=Duel.GetFirstTarget()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND,0,1,ft,nil,tc:GetCode(),e,tp)
  if ft<=0 or g:GetCount()==0 then return end
  local tc=g:GetFirst()
  while tc do
  	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
  	local e1=Effect.CreateEffect(e:GetHandler())
  	e1:SetType(EFFECT_TYPE_SINGLE)
  	e1:SetCode(EFFECT_DISABLE)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  	tc:RegisterEffect(e1)
  	local e1=Effect.CreateEffect(e:GetHandler())
  	e1:SetType(EFFECT_TYPE_SINGLE)
  	e1:SetCode(EFFECT_DISABLE_EFFECT)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  	tc:RegisterEffect(e1)
  	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
  	tc=g:GetNext()
  end
  Duel.SpecialSummonComplete()
  g:KeepAlive()
  --(1.1) Shuffle
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_PHASE+PHASE_END)
  e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  e1:SetCountLimit(1)
  e1:SetLabel(fid)
  e1:SetLabelObject(g)
  e1:SetCondition(s.tdcon)
  e1:SetOperation(s.tdop)
  Duel.RegisterEffect(e1,tp)
end
--(1.1) Shuffle
function s.tdfilter(c,fid)
  return c:GetFlagEffectLabel(id)==fid
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
  local g=e:GetLabelObject()
  if not g:IsExists(s.tdfilter,1,nil,e:GetLabel()) then
  g:DeleteGroup()
  e:Reset()
  return false
  else return true end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local g=e:GetLabelObject()
  local tg=g:Filter(s.tdfilter,nil,e:GetLabel())
  Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
end
--(2) Destroy
function s.desfilter(c,e,tp)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
  and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,c:GetCode(),e,tp)
  and Duel.GetMZoneCount(tp,c)>0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
  	if Duel.GetMZoneCount(tp)<=0 then return end
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tc:GetCode(),e,tp)
  	if g:GetCount()>0 then
  	  Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  	end
  end
end