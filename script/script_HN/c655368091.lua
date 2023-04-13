--HN CPU Xmas
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Draw
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.drtg)
  e1:SetOperation(s.drop)
  c:RegisterEffect(e1)
end
--(1) Draw
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chkc then
    local te=e:GetLabelObject()
    local tg=te:GetTarget()
    return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
  end
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(1)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
  local tc=Duel.GetOperatedGroup():GetFirst()
  Duel.ConfirmCards(1-tp,tc)
  if tc:IsSetCard(SET_HN) then
    b1=tc:IsType(TYPE_MONSTER) and tc:IsLevelAbove(3) 
    b2=tc:GetType()==TYPE_SPELL 
    if b1 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) 
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
      Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    elseif b2 and tc:CheckActivateEffect(false,true,false)~=nil and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
      local te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(false,true,true)
      Duel.ClearTargetCard()
      tc:CreateEffectRelation(e)
      local tg=te:GetTarget()
      if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
      te:SetLabelObject(e:GetLabelObject())
      if not te then return end
      if not te:GetHandler():IsRelateToEffect(e) then return end
      e:SetLabelObject(te:GetLabelObject())
      local op=te:GetOperation()
      if op then op(e,tp,eg,ep,ev,re,r,rp) end
      Duel.BreakEffect()
      Duel.SendtoGrave(tc,REASON_EFFECT)
    elseif not (b1 or b2) and tc:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,6))
      if tc and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp,1,REASON_EFFECT)
      end
    end
  else
    Duel.SendtoDeck(tc,nil,1,REASON_EFFECT)
  end
  Duel.ShuffleHand(tp)
end