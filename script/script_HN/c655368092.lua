--HN Sweet-Nep Holiday
--Scripted by Raivost 
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Excavate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCost(s.exccost)
  e1:SetTarget(s.exctg)
  e1:SetOperation(s.excop)
  c:RegisterEffect(e1)
end
--(1) Excavate
function s.exccost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.exccostfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.exccostfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.exccostfilter(c)
  return c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
  and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.ConfirmDecktop(tp,3)
  local g=Duel.GetDecktopGroup(tp,3)
  local sg=g:Filter(s.spfilter,nil,e,tp)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
  if g:GetCount()>0 then
    Duel.DisableShuffleCheck()
    if sg:GetCount()>0 and ft>0 then
      if sg:GetCount()>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        sg=sg:Select(tp,ft,ft,nil)
      end
      g:Sub(sg)
      local tc=sg:GetFirst()
      while tc do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        tc=sg:GetNext()
      end
      Duel.SpecialSummonComplete()
    end
    Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)   
  end
  --HN monsters
  if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(e,c) return not c:IsSetCard(SET_HN) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end
end
