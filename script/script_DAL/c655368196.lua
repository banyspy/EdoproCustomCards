--DAL Sonogami Rio
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Link Summon
  Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DAL),2,2)
  c:EnableReviveLimit()
   --(1) Special Summon 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon1)
  e1:SetTarget(s.sptg1)
  e1:SetOperation(s.spop1)
  c:RegisterEffect(e1)
  --(2) Cannot target
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
  e2:SetTarget(s.untartg)
  e2:SetValue(s.untarval)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--(1) Special Summon 1
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
  return (re and re:GetHandler():IsSetCard(SET_DAL)) or e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.spfiler1(c,e,tp)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfiler1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfiler1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsPlayerCanDraw(tp,1) then
    Duel.Draw(tp,1,REASON_EFFECT)
  end
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
  e1:SetTargetRange(1,0)
  e1:SetTarget(s.splimit)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
  return not c:IsSetCard(SET_DAL)
end
--(2) Cannot target
function s.untartg(e,c)
  return c:IsSetCard(SET_DAL) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
function s.untarval(e,re,rp)
  return rp~=e:GetHandlerPlayer()
end