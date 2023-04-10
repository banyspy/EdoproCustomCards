--NGNL Checkmate Declaration
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
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --(2) Return to hand 1
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCondition(aux.exccon)
  e2:SetCost(s.rthcost1)
  e2:SetTarget(s.rthtg1)
  e2:SetOperation(s.rthop1)
  c:RegisterEffect(e2)
  --(3) Return to hand 2
  NGNL.SpellTrapReturnToHand(c)
end
--(1) Special Summon
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_NGNL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
end
function s.penfilter(c)
  return c:IsType(TYPE_PENDULUM) and c:IsSetCard(SET_NGNL) and not c:IsForbidden()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) 
  and Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
  if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)>0 then
    local g2=Duel.GetMatchingGroup(s.penfilter,tp,LOCATION_DECK,0,nil) 
    local ct=0
    if Duel.CheckLocation(tp,LOCATION_PZONE,0) then ct=ct+1 end
    if Duel.CheckLocation(tp,LOCATION_PZONE,1) then ct=ct+1 end
    if ct>0 and g2:GetCount()>0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
      local sg=g2:Select(tp,1,ct,nil)
      for sc in aux.Next(sg) do
        Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
      end
    end
  end
end
--(2) Return to hand 1
function s.rthcost1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
  Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.rthfilter1(c)
  return c:IsFaceup() and c:IsSetCard(SET_NGNL) and c:IsAbleToHand()
end
function s.rthtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.rthfilter1,tp,LOCATION_MZONE,0,1,nil)
  and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) 
  and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g1=Duel.SelectTarget(tp,s.rthfilter1,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
  g1:Merge(g2)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.rthop1(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
  if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
    local g2=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_HAND,0,1,1,nil)
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_EFFECT+REASON_DISCARD)
  end
end
--(3) Return to hand 2
--Already handled by BanyspyAux file