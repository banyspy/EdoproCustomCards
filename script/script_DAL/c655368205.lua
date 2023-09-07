--DAL Pool Party
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
end
s.listed_names={655368212}
s.listed_series={SET_DAL}
--(1) Special Summon 1
function s.spconfilter(c)
  return c:IsFaceup() and c:IsCode(655368212)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetMZoneCount(tp)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  if Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil) then
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
  else
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
  end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local ft=Duel.GetMZoneCount(tp)
  if ft<=0 then return end
  if Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil) then ft=math.min(2,ft) else ft=math.min(1,ft) end
  if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
  if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_BP)
    e1:SetTargetRange(0,1)
    e1:SetCondition(s.con)
    e1:SetLabel(Duel.GetTurnCount())
    if Duel.GetTurnPlayer()==tp then
      e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
    else
      e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
    end
    Duel.RegisterEffect(e1,tp)
  end
end
function s.con(e)
  return Duel.GetTurnCount()~=e:GetLabel()
end