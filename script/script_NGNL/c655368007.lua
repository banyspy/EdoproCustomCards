--NGNL The Lucky Draw
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Draw
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN) 
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.drcon)
  e1:SetTarget(s.drtg)
  e1:SetOperation(s.drop)
  c:RegisterEffect(e1)
  --(2) Return to hand
  NGNL.SpellTrapReturnToHand(c)
end
--(1) Draw
function s.drfilter(c)
  return c:IsSetCard(SET_NGNL)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
  local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
  local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
  return (tc1 and s.drfilter(tc1)) or (tc2 and s.drfilter(tc2))
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  local d1=Duel.Draw(tp,1,REASON_EFFECT)
  local dc1=Duel.GetOperatedGroup():GetFirst()
  local d2=Duel.Draw(1-tp,1,REASON_EFFECT)
  local dc2=Duel.GetOperatedGroup():GetFirst()
  if d1>0 then
    Duel.ConfirmCards(1-tp,dc1)
    if dc1:IsType(TYPE_MONSTER) then
      Duel.Recover(tp,1000,REASON_EFFECT)
      Duel.ShuffleHand(tp)
    else
      Duel.SendtoGrave(dc1,REASON_EFFECT+REASON_DISCARD)
      Duel.ShuffleHand(tp)
    end
  end
  if d2>0 then
  Duel.ConfirmCards(tp,dc2)
  if dc2:IsType(TYPE_MONSTER) then
      Duel.Recover(1-tp,1000,REASON_EFFECT)
      Duel.ShuffleHand(1-tp)
    else
      Duel.SendtoGrave(dc2,REASON_EFFECT+REASON_DISCARD)
      Duel.ShuffleHand(1-tp)
    end
  end
end
--(2) Return to hand
--Already handled by BanyspyAux file