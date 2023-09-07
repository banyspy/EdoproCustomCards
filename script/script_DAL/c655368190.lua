--DAL Inverse Spirit - Devil
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --(1) Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_HAND)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetCondition(s.hspcon)
  e1:SetOperation(s.hspop)
  c:RegisterEffect(e1)
  --(2) Special Summon
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_SPECIAL_SUMMON,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.sptg,
    funcop=s.spop})
  --(3) Destroy replace
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_DESTROY_REPLACE)
  e3:SetCountLimit(1)
  e3:SetTarget(s.dreptg)
  e3:SetOperation(s.drepop)
  c:RegisterEffect(e3)
  --(4) Negate 
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,1))
  e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetCode(EVENT_CHAINING)
  e4:SetCountLimit(1)
  e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(s.negcon)
  e4:SetCost(s.negcost)
  e4:SetTarget(s.negtg)
  e4:SetOperation(s.negop)
  c:RegisterEffect(e4)
end
s.listed_names={CARD_DALSPIRIT_ANGEL}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Special Summon from hand
function s.hspconfilter(c,tp)
  return c:IsFaceup() and c:IsCode(CARD_DALSPIRIT_ANGEL) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.hspcon(e,c)
  if c==nil then return true end
  local tp=c:GetControler()
  return Duel.IsExistingMatchingCard(s.hspconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectMatchingCard(tp,s.hspconfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
  Duel.Remove(g,POS_FACEUP,REASON_COST)
end
--(2) Special Summon
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DALSPIRIT) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.GetMZoneCount(tp)>0
  and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
  local ft=math.min(2,Duel.GetMZoneCount(tp))
  if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
  local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp):Filter(Card.IsCanBeEffectTarget,nil,e)
  local tg=Group.CreateGroup()
  repeat
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    tg:Merge(sg)
    g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
    ft=ft-1
  until g:GetCount()==0 or ft==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2))
  Duel.SetTargetCard(tg)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local ft=math.min(2,Duel.GetMZoneCount(tp))
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
  if ft<=0 or #g==0 or (#g>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
  if #g<=ft then
  	for tc in aux.Next(g) do
    Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.unfilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    e1:SetOwnerPlayer(tp)
    tc:RegisterEffect(e1)
  end
  Duel.SpecialSummonComplete()
  else
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,ft,ft,nil)
    for tc in aux.Next(sg) do
    Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.unfilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    e1:SetOwnerPlayer(tp)
    tc:RegisterEffect(e1)
  end
    Duel.SpecialSummonComplete()
    g:Sub(sg)
    Duel.SendtoGrave(g,REASON_RULE)
  end
end
--(2.1) Unaffected
function s.unfilter(e,re)
  return e:GetOwnerPlayer()~=re:GetHandlerPlayer() and re:IsActiveType(TYPE_MONSTER)
end
--(3) Destroy replace
function s.drepfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DAL) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
  and Duel.IsExistingMatchingCard(s.drepfilter,tp,LOCATION_ONFIELD,0,1,c) end
  if Duel.SelectEffectYesNo(tp,c,96) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
    local g=Duel.SelectMatchingCard(tp,s.drepfilter,tp,LOCATION_ONFIELD,0,1,1,c)
    Duel.SetTargetCard(g)
    g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
    return true
  else return false end
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
  Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
--(4) Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  local rc=re:GetHandler()
  return rp~=tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return c:IsAbleToRemoveAsCost() end
  if Duel.Remove(c,POS_FACEUP,REASON_COST+REASON_TEMPORARY)~=0 then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabelObject(c)
    e1:SetCountLimit(1)
    e1:SetOperation(s.retop)
    Duel.RegisterEffect(e1,tp)
  end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
  end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
  Duel.Destroy(eg,REASON_EFFECT)
  end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ReturnToField(e:GetLabelObject())
end