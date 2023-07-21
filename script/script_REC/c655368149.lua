--RE:C God of Ink
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
function s.initial_effect(c)
  --(1) Draw
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.drcon)
  e1:SetTarget(s.drtg)
  e1:SetOperation(s.drop)
  c:RegisterEffect(e1)
end
--(1) Draw
function s.drconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_REC)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.drconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drfilter(c)
  return c:IsFaceup() and c:IsCode(CARD_REC_HOLOPSICON)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=2
  if Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_MZONE,0,1,nil) then ct=3 end
  if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
  Duel.SetTargetPlayer(tp)
  e:SetLabel(ct)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local ct=e:GetLabel()
  if Duel.Draw(p,ct,REASON_EFFECT)==ct then
    Duel.ShuffleHand(p)
    Duel.BreakEffect()
    Duel.DiscardHand(p,nil,2,2,REASON_EFFECT+REASON_DISCARD)
  end
end