--DAL Fraxinus
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
  --(1) Special Summon 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_FZONE)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.spcost1)
  e1:SetTarget(s.sptg1)
  e1:SetOperation(s.spop1)
  c:RegisterEffect(e1)
  --(2) Special Summon 2
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
  e2:SetCode(EVENT_DESTROYED)
  e2:SetTarget(s.sptg2)
  e2:SetOperation(s.spop2)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DALSPIRIT,SET_DAL}
--(1) Special Summon 1
function s.spcostfilter1(c)
  return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_DALSPIRIT) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.spcostfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
  Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.spfilter1(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_ONFIELD)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
      Duel.HintSelection(g,true)
      Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
  end
end
--(2) Special Summon 2
function s.spfilter2(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_DAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetMZoneCount(tp)>0
  and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetMZoneCount(tp)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if #g>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end