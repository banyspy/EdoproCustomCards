--DAL Spacequake
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Destroy
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.destg)
  e1:SetOperation(s.desop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT}
--(1) Destroy
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DALSPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g1=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
  local g2=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
  if chk==0 then return (g1:GetCount()>0 or (g2:GetCount()>0 and Duel.GetMZoneCount(tp,g2)>0))
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  if g1:GetCount()>0 and g2:GetCount()>0 then
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,LOCATION_ONFIELD)
  else
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g1=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,c)
  local g2=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil) 
  if #g1>0 and #g2>0  then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg1=g1:Select(tp,1,1,nil)
    Duel.HintSelection(dg1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg2=g2:Select(tp,1,1,nil)
    Duel.HintSelection(dg2)
    dg1:Merge(dg2)
    Duel.Destroy(dg1,REASON_EFFECT) 
  end
  if Duel.GetMZoneCount(tp)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g3=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if #g3>0 then
    Duel.SpecialSummon(g3,0,tp,tp,false,false,POS_FACEUP)
  end
  if c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
    c:CancelToGrave()
    Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
  end
end