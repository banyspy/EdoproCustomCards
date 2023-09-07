--DAL Itsuka Shido
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(s.hspcon)
  c:RegisterEffect(e1)
  --(2) Shuffle
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCountLimit(1)
  e2:SetTarget(s.tdtg)
  e2:SetOperation(s.tdop)
  c:RegisterEffect(e2)
  --(3) Special Summon
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_TO_GRAVE)
  e3:SetProperty(EFFECT_FLAG_DELAY)
  e3:SetCondition(s.spcon)
  e3:SetTarget(s.sptg)
  e3:SetOperation(s.spop)
  c:RegisterEffect(e3)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) and not c:IsCode(id)
end
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
  Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--(2) Shuffle
function s.tdfilter(c,e,tp)
  return c:IsSetCard(SET_DALSPIRIT) and c:IsAbleToDeck()
  and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
  and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter1(c,e,tp,code)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:ListsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
    and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,tc:GetCode()) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
      if g:GetCount()>0 then 
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    end
  end
end
--(3) Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.spfilter(c,e,tp)
return c:IsSetCard(SET_DALSPIRIT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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