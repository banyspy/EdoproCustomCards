--HN Game Reload
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e0)
  --(1) Return to hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.rthtg)
  e1:SetOperation(s.rthop)
  c:RegisterEffect(e1)
  --(2) Reveal
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_SZONE)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.revtg)
  e2:SetOperation(s.revop)
  c:RegisterEffect(e2)
end
--(1) Return to hand
function s.rthfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and c:IsLevelAbove(3) and c:IsAbleToHand()
end
function s.nsfilter(c)
  return c:IsSetCard(SET_HN)  and c:IsSummonable(true,nil)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
  local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
    local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
      local sg=g:Select(tp,1,1,nil):GetFirst()
      Duel.Summon(tp,sg,true,nil)
    end
  end
end
--(2) Reveal
function s.revfilter(c)
  return c:IsSetCard(SET_HN) and c:IsAbleToDeck()
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp)
  and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil) end
  Duel.SetTargetPlayer(tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(p,s.revfilter,p,LOCATION_HAND,0,1,63,nil)
  if g:GetCount()>0 then
    Duel.ConfirmCards(1-p,g)
    local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    Duel.ShuffleDeck(p)
    Duel.BreakEffect()
    Duel.Draw(p,ct,REASON_EFFECT)
  end
end