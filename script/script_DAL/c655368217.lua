--DAL Eden's Flares
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCode(EVENT_DESTROYED)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.accon)
  e1:SetOperation(s.acop)
  c:RegisterEffect(e1)
  --(2) Return
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCondition(aux.exccon)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.rttg)
  e2:SetOperation(s.rtop)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DAL}
function s.acfilter(c,tp)
  return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp)) 
  and c:IsSetCard(SET_DAL) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp 
end
function s.accon(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.acfilter,1,nil,tp)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
  --(1.1) Destroy
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_PHASE+PHASE_END)
  e1:SetReset(RESET_PHASE+PHASE_END)
  e1:SetCountLimit(1)
  e1:SetCondition(s.descon)
  e1:SetOperation(s.desop)
  Duel.RegisterEffect(e1,tp)
end
--(1.1) Destroy
function s.desfilter(c)
  return c:GetSummonType()&SUMMON_TYPE_SPECIAL~=0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_CARD,0,id)
  local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
  Duel.Destroy(g,REASON_EFFECT)
end
--(2) Return
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tdfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
  and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g1=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g2=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g2,1,0,0)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
  local ex,g1=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
  local ex,g2=Duel.GetOperationInfo(0,CATEGORY_TODECK)
  if g1:GetFirst():IsRelateToEffect(e) then
    Duel.SendtoHand(g1,nil,REASON_EFFECT)
  end
  if g2:GetFirst():IsRelateToEffect(e) then
    Duel.SendtoDeck(g2,nil,2,REASON_EFFECT)
  end
end