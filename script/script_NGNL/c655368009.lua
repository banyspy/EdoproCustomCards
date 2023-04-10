--NGNL Fake End
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) To deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_COIN+CATEGORY_TODECK+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.tdtg)
  e1:SetOperation(s.tdop)
  c:RegisterEffect(e1)
  --(2) Return to hand
  NGNL.SpellTrapReturnToHand(c)
end
s.roll_dice=true
function s.tdfilter(c)
  return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,nil)
  if g:GetCount()<1 then return end
  local dc=Duel.TossDice(tp,1)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local sg=g:Select(tp,1,dc,nil)
  Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
  local og=Duel.GetOperatedGroup()
  if og:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
  Duel.BreakEffect()
  Duel.Draw(tp,1,REASON_EFFECT)
  if dc==6 and c:IsRelateToEffect(e) and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
  	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    c:CancelToGrave()
    Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
  end
end
--(2) Return to hand
--Already handled by BanyspyAux file