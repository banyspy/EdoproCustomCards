--NGNL Game Start
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Shuffle
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetTarget(s.tdtg)
  e1:SetOperation(s.tdop)
  c:RegisterEffect(e1)
  --(2) Return to hand
  NGNL.SpellTrapReturnToHand(c)
end
--(1) Shuffle
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp) and Duel.IsPlayerCanDraw(1-tp)
  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil) 
  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
  local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
  local gc1=g1:GetCount()
  local gc2=g2:GetCount()
  if gc1==0 or gc2==0 then return end
  g1:Merge(g2)
  Duel.SendtoDeck(g1,nil,2,REASON_EFFECT)
  Duel.ShuffleDeck(tp)
  Duel.ShuffleDeck(1-tp)
  Duel.BreakEffect()
  Duel.Draw(tp,gc1,REASON_EFFECT)
  Duel.Draw(1-tp,gc2,REASON_EFFECT)
  --(1.1) Discard
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
  e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
  e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e1:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCountLimit(1)
  e1:SetCondition(s.discon)
  e1:SetTarget(s.distg)
  e1:SetOperation(s.disop)
  Duel.RegisterEffect(e1,tp)
end
--(1.1) Discard
function s.discon(e,tp,eg,ep,ev,re,r,rp)
  return tp==Duel.GetTurnPlayer()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
  and Duel.IsPlayerCanDraw(tp,1) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)~=0 then
    Duel.Draw(tp,1,REASON_EFFECT)
  end
end
--(2) Return to hand
--Already handled by BanyspyAux file