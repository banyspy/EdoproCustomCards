--DAL Force Switch
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Return to hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.rthtg)
  e1:SetOperation(s.rthop)
  c:RegisterEffect(e1)
 end
 s.listed_series={SET_DALSPIRIT,SET_DAL}
 --(1) Return to hand
function s.rthfilter(c,e,tp)
  --check
  if c:IsSetCard(SET_DALSPIRIT) then --DAL Spirit case
    return Duel.IsExistingMatchingCard(s.spfilterDALSpirit,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c)
  elseif c:IsSetCard(SET_DAL) and c:IsType(TYPE_XYZ) then -- DAL Xyz monster case
  	return Duel.IsExistingMatchingCard(s.spfilterDALXyz,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
  else -- Other case
    return Duel.IsExistingMatchingCard(s.spfilterDALOther,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c)
  end
end
function s.spfilterDALSpirit(c,e,tp,card)
  return c:IsSetCard(SET_DALSPIRIT) and not c:IsCode(card:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  and Duel.GetMZoneCount(tp,card)>0
end
function s.spfilterDALXyz(c,e,tp,card)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_XYZ) and not c:IsCode(card:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  and Duel.GetLocationCountFromEx(tp,tp,card,c)>0
end
function s.spfilterDALOther(c,e,tp,card)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and not c:IsCode(card:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  and Duel.GetMZoneCount(tp,card)>0
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
  local tc=g:GetFirst()
  if tc:IsSetCard(SET_DALSPIRIT) then
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
  elseif tc:IsSetCard(SET_DAL) and tc:IsType(TYPE_XYZ) then
  	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
  else
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,700)
  end
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()    
  local tc=Duel.GetFirstTarget()
  if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
  --DAL Spirit case
  if tc:IsSetCard(SET_DALSPIRIT) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then 
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilterDALSpirit,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc)
    local tc2=sg:GetFirst()
    if Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      e1:SetValue(500)
      tc2:RegisterEffect(e1)
      Duel.SpecialSummonComplete()
    end
  -- DAL Xyz monster case
  elseif tc:IsSetCard(SET_DAL) and tc:IsType(TYPE_XYZ) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then 
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilterDALXyz,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    local tc2=sg:GetFirst()
    if Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)~=0  then
      if c:IsRelateToEffect(e) then
        c:CancelToGrave()
        Duel.Overlay(tc2,Group.FromCards(c))
      end
      Duel.SpecialSummonComplete()
    end
  -- Other case
  elseif Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.spfilterDALOther,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,tc)
    local tc2=sg:GetFirst()
    if Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)~=0 then
      Duel.Recover(tp,700,REASON_EFFECT)
    end
  end
end