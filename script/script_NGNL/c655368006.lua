--NGNL Imanity Throne
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Send to GY
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_COIN+CATEGORY_DECKDES)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(s.tgcon)
  e1:SetTarget(s.tgtg)
  e1:SetOperation(s.tgop)
  c:RegisterEffect(e1)
  --(2) Return to hand
  NGNL.SpellTrapReturnToHand(c)
end
s.toss_coin=true
--(1) Send to GY
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
  local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
  local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
  return tc1 and tc1:IsSetCard(SET_NGNL) and tc2 and tc2:IsSetCard(SET_NGNL)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local lsc=Duel.GetFieldCard(tp,LOCATION_PZONE,0):GetLeftScale()
  local rsc=Duel.GetFieldCard(tp,LOCATION_PZONE,1):GetRightScale()
  if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsPlayerCanDiscardDeck(1-tp,1) and (lsc>rsc or rsc>lsc) end
  if lsc>rsc then lsc,rsc=rsc,lsc end
  e:SetLabel(rsc-lsc)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,rsc-lsc)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  local res=Duel.TossCoin(tp,1)
  if res==1 then 
    Duel.DiscardDeck(1-tp,e:GetLabel(),REASON_EFFECT)
  else  
    Duel.DiscardDeck(tp,e:GetLabel(),REASON_EFFECT)
  end
end
--(2) Return to hand
--Already handled by BanyspyAux file