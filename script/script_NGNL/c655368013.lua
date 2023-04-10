--NGNL Materialization Shiritori
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Negate Summon (Summon)
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_SPSUMMON)
  e1:SetCondition(s.nscon1)
  e1:SetTarget(s.nstg1)
  e1:SetOperation(s.nsop1)
  c:RegisterEffect(e1)
  --(1) Negate Summon (Effect)
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_CHAINING)
  e2:SetCondition(s.nscon2)
  e2:SetTarget(s.nstg2)
  e2:SetOperation(s.nsop2)
  c:RegisterEffect(e2)
  --(2) Activate in hand
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  e3:SetCondition(s.handcon)
  c:RegisterEffect(e3)
  --(3) Return to hand
  NGNL.SpellTrapReturnToHand(c)
end
--(1) Negate Summon (Summon)
function s.nscon1(e,tp,eg,ep,ev,re,r,rp)
  return tp~=ep and Duel.GetCurrentChain()==0
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_NGNL) and c:IsType(TYPE_PENDULUM) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.setfilter(c)
  return c:IsCode(id) and c:IsSSetable()
end
function s.nstg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,eg:GetCount(),0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.nsop1(e,tp,eg,ep,ev,re,r,rp)
  Duel.NegateSummon(eg)
  if Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)~=0 then
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 
    and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
      local g2=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
      local tc=g2:GetFirst()
      if tc then
        Duel.SSet(tp,tc)
        Duel.ConfirmCards(1-tp,tc)
      end
    end
  end
end
--(1) Negate Summon (Effect)
function s.nscon2(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.IsChainNegatable(ev) then return false end
  if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
  return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and ep~=tp
end
function s.nstg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)  end
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.nsop2(e,tp,eg,ep,ev,re,r,rp)
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Remove(eg,POS_FACEDOWN,REASON_EFFECT)~=0 then
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
    if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0  
    and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
      local g2=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
      local tc=g2:GetFirst()
      if tc then
        Duel.SSet(tp,tc)
        Duel.ConfirmCards(1-tp,tc)
      end
    end
  end
end
--(2) Activate in hand
function s.handcon(e)
  local tp=e:GetHandlerPlayer()
  local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
  local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
  return tc1 and tc1:IsSetCard(SET_NGNL) and tc2 and tc2:IsSetCard(SET_NGNL)
end
--(3) Return to hand
--Already handled by BanyspyAux file