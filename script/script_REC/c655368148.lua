--RE:C CM: Fate Restoration
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
function s.initial_effect(c)
  --(1) Negate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.negcon)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  c:RegisterEffect(e1)
end
function s.negconfilter(c)
  return c:IsFaceup() and c:IsCode(CARD_REC_HOLOPSICON)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.negconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) 
  and Duel.IsExistingMatchingCard(aux.disfilter1,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
    local g=Duel.GetMatchingGroup(aux.disfilter1,tp,0,LOCATION_ONFIELD,nil)
    local tc=g:GetFirst()
    local ct=0
    while tc and tc:IsFaceup() and not tc:IsImmuneToEffect(e) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_DISABLE)
      e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
      tc:RegisterEffect(e1)
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_DISABLE_EFFECT)
      e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
      tc:RegisterEffect(e2)
      if tc:IsType(TYPE_TRAPMONSTER) then
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END|RESET_OPPO_TURN)
        tc:RegisterEffect(e3)
      end
      ct=ct+1
      tc=g:GetNext()
    end
    if ct>0 and Duel.IsPlayerCanDraw(1-tp,ct) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
      Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,2))
      Duel.Draw(1-tp,ct,REASON_EFFECT)
    end
  end
end