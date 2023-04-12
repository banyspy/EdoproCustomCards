--OTNN Tails Emergency
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
end
--(1) Special Summon
function s.spfilter1(c,e,tp)
  return c:IsRace(RACE_WARRIOR) and c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
  and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,c,c:GetLevel(),e,tp)
end
function s.spfilter2(c,lv,e,tp)
  return c:IsRace(RACE_WARRIOR) and c:GetLevel()==lv and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
  and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.xyzfilter(c,mg,tp,chk)
  return c:IsXyzSummonable(nil,mg,2,2) and c:IsSetCard(SET_OTNN) and (not chk or Duel.GetLocationCountFromEx(tp,tp,mg,c)>0)
end
function s.mfilter1(c,mg,exg,tp)
  return mg:IsExists(s.mfilter2,1,c,c,exg,tp)
end
function s.mfilter2(c,mc,exg)
  return exg:IsExists(Card.IsXyzSummonable,1,nil,nil,Group.FromCards(c,mc),2,2) --and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  local mg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
  local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,tp,false)
  if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
  and not Duel.IsPlayerAffectedByEffect(tp,59822133)
  and Duel.GetMZoneCount(tp)>1
  and exg:GetCount()>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.filter2(c,e,tp)
  return c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local mg=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
  local exg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg,tp,false)
  if not (Duel.IsPlayerCanSpecialSummonCount(tp,2)
  and not Duel.IsPlayerAffectedByEffect(tp,59822133)
  and Duel.GetMZoneCount(tp)>1
  and exg:GetCount()>0) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local atk=0
  local sg1=mg:FilterSelect(tp,s.mfilter1,1,1,nil,mg,exg,tp)
  Debug.Message(#sg1)
  local tc1=sg1:GetFirst()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local sg2=mg:FilterSelect(tp,s.mfilter2,1,1,tc1,tc1,exg,tp)
  local tc2=sg2:GetFirst()
  atk=tc1:GetOriginalLevel()+tc2:GetOriginalLevel()
  sg1:Merge(sg2)
  Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
  Duel.BreakEffect()
  local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,sg1,tp,true)
  if xyzg:GetCount()>0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
    if Duel.XyzSummon(tp,xyz,sg1)~=0 then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetValue(atk*100)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
      xyz:RegisterEffect(e1)
    end
  end
end