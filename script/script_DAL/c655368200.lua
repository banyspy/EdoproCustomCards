--DAL Zaphkiel - Emperor of Time
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Unaffected
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_REMOVE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetTarget(s.unftg)
  e1:SetOperation(s.unfop)
  c:RegisterEffect(e1)
  --(2) Negate
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_DISABLE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCondition(s.negcon)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.negtg)
  e2:SetOperation(s.negop)
  c:RegisterEffect(e2)
end
s.listed_name={id}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Unaffected
function s.unffilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) 
end
function s.banfilter(c,tp)
  return c:IsSetCard(SET_DAL) and not c:IsCode(id) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.unftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.unffilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.unffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.unfop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
  	local e1=Effect.CreateEffect(e:GetHandler())
  	e1:SetDescription(aux.Stringid(id,0))
  	e1:SetType(EFFECT_TYPE_SINGLE)
  	e1:SetCode(EFFECT_IMMUNE_EFFECT)
  	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
  	e1:SetRange(LOCATION_MZONE)
  	e1:SetValue(s.unfilter)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  	e1:SetOwnerPlayer(tp)
  	tc:RegisterEffect(e1)
  end
  if Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_DECK,0,1,nil,tp) and
  Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  	local g=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
  	local tg=g:GetFirst()
  	if not tg or Duel.Remove(tg,POS_FACEDOWN,REASON_EFFECT)==0 then return end
  	--(1.1) To hand
  	local e1=Effect.CreateEffect(e:GetHandler())
  	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  	e1:SetRange(LOCATION_REMOVED)
  	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  	e1:SetCountLimit(1)
  	e1:SetCondition(s.thcon)
  	e1:SetOperation(s.thop)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
  	tg:RegisterEffect(e1)
  end
end
function s.unfilter(e,re)
  return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
--(1.1) To hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
--(2) Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DALSPIRIT),tp,LOCATION_MZONE,0,1,nil) and aux.exccon(e)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if ((tc:IsFaceup() and not tc:IsDisabled()) or tc:IsType(TYPE_TRAPMONSTER)) and tc:IsRelateToEffect(e) then
  	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
  	local e1=Effect.CreateEffect(c)
  	e1:SetType(EFFECT_TYPE_SINGLE)
  	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  	e1:SetCode(EFFECT_DISABLE)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  	tc:RegisterEffect(e1)
  	local e2=Effect.CreateEffect(c)
  	e2:SetType(EFFECT_TYPE_SINGLE)
  	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  	e2:SetCode(EFFECT_DISABLE_EFFECT)
  	e2:SetValue(RESET_TURN_SET)
  	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
  	tc:RegisterEffect(e2)
  	if tc:IsType(TYPE_TRAPMONSTER) then
  	local e3=Effect.CreateEffect(c)
  	e3:SetType(EFFECT_TYPE_SINGLE)
  	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
  	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
  	tc:RegisterEffect(e3)
  end
  end
end