--NGNL Sora
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Scale change
  NGNL.ForceChangeScaleEffect(c)
  --(2) To hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
  --(3) Draw
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3))
  e3:SetCategory(CATEGORY_DRAW)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_DRAW)
  e3:SetRange(LOCATION_PZONE)
  e3:SetCondition(s.drcon)
  e3:SetTarget(s.drtg)
  e3:SetOperation(s.drop)
  c:RegisterEffect(e3)
  --Monster Effects
  --(1) Disable Summon
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,4))
  e4:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_COIN)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetCode(EVENT_SPSUMMON)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(s.dscon)
  e4:SetTarget(s.dstg)
  e4:SetOperation(s.dsop)
  c:RegisterEffect(e4)
  --(2) Discard
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,5))
  e5:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetCountLimit(1,id)
  e5:SetRange(LOCATION_MZONE)
  e5:SetTarget(s.distg)
  e5:SetOperation(s.disop)
  c:RegisterEffect(e5)
  --(3) Avoid battle damage
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_SINGLE)
  e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e6:SetValue(1)
  c:RegisterEffect(e6)
end
s.toss_coin=true
s.roll_dice=true
--Pendulum Effects
--(1) Scale Change
--Already handled by BanyspyAux file
--(2) To hand
function s.thfilter(c)
  return c:IsSetCard(SET_NGNL) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--(3) Draw
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(1)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Draw(p,d,REASON_EFFECT)
end
--Monster Effects
--(1) Disable Summon
function s.dscon(e,tp,eg,ep,ev,re,r,rp)
  return tp~=ep and eg:GetCount()==1 and Duel.GetCurrentChain()==0
end
function s.dstg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,eg:GetCount(),0,0)
end
function s.dsfilter(c)
  return c:IsFaceup() and c:IsAbleToHand()
end
function s.dsop(e,tp,eg,ep,ev,re,r,rp)
  local coin=Duel.SelectOption(tp,aux.Stringid(id,6),aux.Stringid(id,7))
  local res=Duel.TossCoin(tp,1)
  if coin~=res then
    Duel.NegateSummon(eg)
    Duel.SendtoHand(eg,nil,REASON_EFFECT)
  else
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectTarget(tp,s.dsfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc:IsRelateToEffect(e) then
      Duel.SendtoHand(tc,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,tc)
    end
  end
end
--(2) Discard
function s.disfilter(c)
  return c:IsDiscardable(REASON_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
  local tp=e:GetHandlerPlayer()
  local tc1=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
  local tc2=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
  if tc1 and tc1:IsSetCard(SET_NGNL) and tc2 and tc2:IsSetCard(SET_NGNL) then
    e:SetLabel(2)
  else 
    e:SetLabel(1)
  end
  if chk==0 then return Duel.IsPlayerCanDraw(tp,e:GetLabel())
  and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,s.disfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
    Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
  end
end