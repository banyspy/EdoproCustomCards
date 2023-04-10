--YuYuYu Into Jukai
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
  e1:SetCondition(s.spcon)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  c:RegisterEffect(e1)
  --(2) Activate
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCondition(s.accon)
  e2:SetTarget(s.actg)
  e2:SetOperation(s.acop)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_YUYUYU_SEA_OF_TREES}
--(1) Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsEnvironment(CARD_YUYUYU_SEA_OF_TREES)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_YUYUYU) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCountFromEx(tp)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end
--(2) Activate
function s.accon(e,tp,eg,ep,ev,re,r,rp)
  return not Duel.IsEnvironment(CARD_YUYUYU_SEA_OF_TREES)
end
function s.acfilter(c,tp)
  return c:IsCode(CARD_YUYUYU_SEA_OF_TREES) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.thfilter(c)
  return c:IsSetCard(SET_YUYUYU) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp) 
  and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
  local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
  if tc then
    local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
    if fc then
      Duel.SendtoGrave(fc,REASON_RULE)
      Duel.BreakEffect()
    end
    Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
    local te=tc:GetActivateEffect()
    local tep=tc:GetControler()
    local cost=te:GetCost()
    if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
    --Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
    end
  end
end