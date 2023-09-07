--DAL Lancelot - Artemisia
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DAL),3,3)
  c:EnableReviveLimit()
  --(1) Negate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DISABLE)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.negcost)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  c:RegisterEffect(e1,false,1)
  --(2) Destroy
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(s.destg)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Negate
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.negfilter(c,atk)
  return Card.IsNegatableMonster(c) and c:GetAttack()<atk
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.negfilter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
  local g=Duel.GetMatchingGroup(s.negfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
  for tc in aux.Next(g) do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetValue(RESET_TURN_SET)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
    Duel.NegateRelatedChain(tc,RESET_TURN_SET)
  end
end
--(2) Destroy
function s.desfilter(c)
  return c:IsSetCard(SET_DAL)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND,0,1,nil) end
  local g=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
  if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(0,LOCATION_MZONE)
    e1:SetValue(-600)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    Duel.RegisterEffect(e2,tp)
    if Duel.IsPlayerCanDraw(tp,1) and g:GetFirst():IsSetCard(SET_DALSPIRIT) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
	  Duel.Draw(tp,1,REASON_EFFECT) 
	end
  end
end