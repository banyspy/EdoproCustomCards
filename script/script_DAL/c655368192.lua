--DAL White Licorice - Origami
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DAL),3,3,s.ovfilter,aux.Stringid(id,0))
  c:EnableReviveLimit()
  --(1) Destroy
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCost(s.descost)
  e1:SetTarget(s.destg)
  e1:SetOperation(s.desop)
  c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
  --(2) Special Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_BATTLE_DESTROYING)
  e2:SetCountLimit(1,id)
  e2:SetCondition(s.spcon)
  e2:SetTarget(s.sptg)
  e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end
s.listed_names={655368191}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--Xyz Summon
function s.ovfilter(c)
  return c:IsFaceup() and c:IsCode(655368191)
end
--(1) Destroy
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and e:GetHandler():GetAttackAnnouncedCount()==0 end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetDescription(aux.Stringid(id,3))
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_ATTACK)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  e:GetHandler():RegisterEffect(e1)
end
function s.desfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
    Duel.Damage(1-tp,1000,REASON_EFFECT)
  end
end
--(2) Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end