--NGNL Stephanie Dola
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Scale Change
  NGNL.ForceChangeScaleEffect(c)
  --(2) Shuffle
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCountLimit(1,id)
  e2:SetTarget(s.tdtg)
  e2:SetOperation(s.tdop)
  c:RegisterEffect(e2)
  --(3) Send to GY
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3))
  e3:SetCategory(CATEGORY_DECKDES)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_DRAW)
  e3:SetRange(LOCATION_PZONE)
  e3:SetCondition(s.tgcon)
  e3:SetTarget(s.tgtg)
  e3:SetOperation(s.tgop)
  c:RegisterEffect(e3)
  --Monster Effects
  --(1) Special Summon from hand
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetCode(EFFECT_SPSUMMON_PROC)
  e4:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e4:SetRange(LOCATION_HAND)
  e4:SetCondition(s.hspcon)
  c:RegisterEffect(e4)
  --(2) Negate effect
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,4))
  e5:SetCategory(CATEGORY_NEGATE)
  e5:SetType(EFFECT_TYPE_QUICK_O)
  e5:SetCode(EVENT_CHAINING)
  e5:SetCountLimit(1,{id,1})
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCondition(s.negcon)
  e5:SetCost(s.negcost)
  e5:SetTarget(s.negtg)
  e5:SetOperation(s.negop)
  c:RegisterEffect(e5)
  --(3) Avoid battle damage
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_SINGLE)
  e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e6:SetValue(1)
  c:RegisterEffect(e6)
end
s.roll_dice=true
--Pendulum Effects
--(1) Scale Change
--Already handled by BanyspyAux file
--(2) Shuffle
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsPlayerCanDraw(tp,2) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,2,REASON_EFFECT)~=0 then
    Duel.ShuffleDeck(tp)
    if Duel.Draw(tp,2,REASON_EFFECT)==2 then
      Duel.ShuffleHand(tp)
      Duel.BreakEffect()
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
      local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
      if g:GetCount()>0 then
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
      end
    end
  end
end
--(3) Send to GY
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetTargetPlayer(1-tp)
  Duel.SetTargetParam(1)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.DiscardDeck(p,d,REASON_EFFECT)
end
--Monster Effects
--(1) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_NGNL) and c:GetCode()~=id
end
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
    Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--(2) Negate effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
  Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  Duel.NegateActivation(ev)
end