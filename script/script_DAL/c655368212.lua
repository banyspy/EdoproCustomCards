--DAL The Spirit Summer
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
  --(1) Gain LP
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_RECOVER)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetCondition(s.reccon)
  e1:SetOperation(s.recop)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2)
  --(2) Shuffle
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetTarget(s.tdtg)
  e3:SetOperation(s.tdop)
  c:RegisterEffect(e3)
  --(3) Special Summon
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,2))
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCode(EVENT_DESTROYED)
  e4:SetTarget(s.sptg)
  e4:SetOperation(s.spop)
  c:RegisterEffect(e4)
end
s.listed_series={SET_DAL}
--(1) Gain LP
function s.recfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) and c:GetSummonPlayer()==tp
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.recfilter,1,nil,tp)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_CARD,0,id)
  Duel.Recover(tp,300,REASON_EFFECT)
end
--(2) Shuffle
function s.tdfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return  Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND,0,1,nil)
  and Duel.IsPlayerCanDraw(tp,1) end
  Duel.SetTargetPlayer(tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_HAND,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.ConfirmCards(1-tp,g)
    Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    Duel.ShuffleDeck(tp)
    Duel.Draw(tp,1,REASON_EFFECT)
  end
end
--(3) Special Summon
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end