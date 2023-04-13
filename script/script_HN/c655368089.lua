--HN Fragment Reaction
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Send to GY
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DECKDES+CATEGORY_RECOVER+CATEGORY_DRAW+CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.tgtg)
  e1:SetOperation(s.tgop)
  c:RegisterEffect(e1)
end
--(1) Send to GY
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
  if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) and ct>=4 and Duel.IsPlayerCanDraw(tp,1) end
  Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.effilter(c)
  return c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER)
end
function s.thfilter(c)
  return c:IsSetCard(SET_HN) and c:IsAbleToHand()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardDeck(tp,3,REASON_EFFECT)~=0 then
    local g=Duel.GetOperatedGroup()
    local ct=g:FilterCount(s.effilter,nil)
    Duel.Draw(tp,1,REASON_EFFECT)
    if ct==0 then return end
    local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if ct==1 then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
      Duel.Recover(tp,1000,REASON_EFFECT)
    elseif ct==2 then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
      Duel.Draw(tp,1,REASON_EFFECT)
    elseif ct==3 and hg:GetCount()>0 then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local shg=hg:Select(tp,1,1,nil)
      Duel.SendtoHand(shg,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,shg)
    end
  end
end