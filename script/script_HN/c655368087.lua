--HN Transcending Shares
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Return to Extra Deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.rtdtg)
  e1:SetOperation(s.rtdop)
  c:RegisterEffect(e1)
end
--(1) Return to Extra Deck
function s.rtdfilter(c,tp)
  local rk=c:GetRank()
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN_HDD) and c:IsType(TYPE_XYZ) and c:IsAbleToExtra() and Duel.IsPlayerCanDraw(tp,rk+1)
end
function s.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.rtdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.rtdfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
  Duel.SetTargetPlayer(tp)
  local rk=g:GetFirst():GetRank()
  Duel.SetTargetParam(rk+1)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,rk+1)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,rk)
end
function s.rtdop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local tc=Duel.GetFirstTarget()
  local rk=tc:GetRank()
  if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
    if rk>0 and Duel.Draw(p,rk+1,REASON_EFFECT)==rk+1 then
      local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
      if #g2==0 then return end
      Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
      local sg=g2:Select(p,rk,rk,nil)
      Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
    end
  end
end