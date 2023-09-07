--DAL Shadows in Time
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Shuffle
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetTarget(s.tdtg)
  e1:SetOperation(s.tdop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT,SET_DAL}
--(1) Shuffle
function s.tdfilter(c,e,tp)
  return c:IsSetCard(SET_DALSPIRIT) and c:IsAbleToDeck()
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
  and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp,card)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:ListsCode(card) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.setfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc1=Duel.GetFirstTarget()
  if tc1:IsRelateToEffect(e) then
    if Duel.SendtoDeck(tc1,nil,2,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0 
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tc1) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc1)
      if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 
      and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
      and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then    
        Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
        local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g2>0 then
          local tc2=g2:GetFirst()
          Duel.SSet(tp,tc2)
          Duel.ConfirmCards(1-tp,tc2)
          local e1=Effect.CreateEffect(c)
          e1:SetType(EFFECT_TYPE_SINGLE)
          e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
          e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
          e1:SetReset(RESET_EVENT+RESETS_STANDARD)
          tc2:RegisterEffect(e1)
        end
      end
    end
  end
end