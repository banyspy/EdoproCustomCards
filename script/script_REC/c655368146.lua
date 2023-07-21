--RE:C Holopsicon
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e0)
  --(1) Activate from hand
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
  e1:SetRange(LOCATION_FZONE)
  e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_RECCM))
  e1:SetTargetRange(LOCATION_HAND,0)
  e1:SetCondition(s.accon)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  c:RegisterEffect(e2)
  --(1) Special Summon
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_FZONE)
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --(3) Search
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,1))
  e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetRange(LOCATION_FZONE)
  e4:SetCountLimit(1,id)
  e4:SetTarget(s.thtg1)
  e4:SetOperation(s.thop1)
  c:RegisterEffect(e4)
  --(4) To hand
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,2))
  e5:SetCategory(CATEGORY_TOHAND)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_GRAVE)
  e5:SetCost(s.thcost2)
  e5:SetTarget(s.thtg2)
  e5:SetOperation(s.thop2)
  c:RegisterEffect(e5)
end
--(1) Activate from hand
function s.accon(e)
  return Duel.IsExistingMatchingCard(s.spconfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
--(2) Special Summon
function s.spconfilter(c)
  return c:IsFaceup() and c:IsCode(CARD_REC_ALTAIR)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_REC) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.damfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_REC)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g1=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_MZONE,0,nil)
  local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
  if g1:GetCount()>0 and g2:GetCount()>0 then
    for tc in aux.Next(g1) do
      g2:Remove(Card.IsCode,nil,tc:GetCode())
    end
  end
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT)
  and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g2:GetCount()>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g1=Duel.GetMatchingGroup(s.damfilter,tp,LOCATION_MZONE,0,nil)
  local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
  if g1:GetCount()>0 and g2:GetCount()>0 then
    for tc in aux.Next(g1) do
      g2:Remove(Card.IsCode,nil,tc:GetCode())
    end
  end
  if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)~=0
  and g2:GetCount()>0 then
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g2:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
    if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CANNOT_ATTACK)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e1)
      tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
      Duel.SpecialSummonComplete()
    end
  end
end
--(3) Search
function s.thfilter1(c)
  return c:IsSetCard(SET_RECCM) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--(4) To hand
function s.thcostfilter2(c)
  return c:IsSetCard(SET_REC) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter2,tp,LOCATION_HAND,0,1,nil) end
  Duel.DiscardHand(tp,s.thcostfilter2,1,1,REASON_DISCARD+REASON_COST)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToHand() end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
  if e:GetHandler():IsRelateToEffect(e) then
    Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,e:GetHandler())
  end
end