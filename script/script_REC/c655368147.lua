--Re:C CM: Representation Exposition
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Negate attack
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_RECOVER)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetCondition(s.nacon)
  e1:SetTarget(s.natg)
  e1:SetOperation(s.naop)
  c:RegisterEffect(e1)
  --(2) Negate effect
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_NEGATE+CATEGORY_RECOVER)
  e2:SetType(EFFECT_TYPE_ACTIVATE)
  e2:SetCode(EVENT_CHAINING)
  e2:SetCondition(s.negcon)
  e2:SetTarget(s.negtg)
  e2:SetOperation(s.negop)
  c:RegisterEffect(e2)
end
--(1) Negate attack
function s.acconfilter(c)
  return c:IsFaceup() and c:IsCode(CARD_REC_HOLOPSICON)
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
  local at=Duel.GetAttacker()
  return at:GetControler()~=tp and Duel.IsExistingMatchingCard(s.acconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
  local at=Duel.GetAttacker()
  if chk==0 then return at and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
    local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if Duel.NegateAttack()~=0 and ct>0 then
      Duel.Recover(tp,ct*500,REASON_EFFECT)
    end
  end
end
--(2) Negate effect
function s.negconfilter(c,tp)
  return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  if not (rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return false end
  local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
  return g and g:IsExists(s.negconfilter,1,nil,tp) and Duel.IsChainDisablable(ev) 
  and Duel.IsExistingMatchingCard(s.acconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
    local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if Duel.NegateEffect(ev)~=0 and ct>0 then
      Duel.Recover(tp,ct*500,REASON_EFFECT)
    end
  end
end