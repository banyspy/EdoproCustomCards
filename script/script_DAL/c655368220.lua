--DAL Nightmare Shot
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Negate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_CHAINING)
  e1:SetCondition(s.negcon)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT}
--(1) Negate
function s.negconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
  and Duel.IsExistingMatchingCard(s.negconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
  if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
  	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
  end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler() 
  if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
  	Duel.Destroy(eg,REASON_EFFECT)
  end
  if c:IsRelateToEffect(e) and c:IsCanTurnSet() and e:IsHasType(EFFECT_TYPE_ACTIVATE) 
  and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) 
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
  	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
  	c:CancelToGrave()
  	Duel.ChangePosition(c,POS_FACEDOWN)
  	Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
  end
end