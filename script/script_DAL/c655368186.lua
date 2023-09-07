--DAL Irregular Spirit - Viris
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum effects
  --(1) Inflict damage
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCategory(CATEGORY_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetRange(LOCATION_PZONE)
  e1:SetCountLimit(1)
  e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(s.damtg)
  e1:SetOperation(s.damop)
  c:RegisterEffect(e1)
  --(2) Unaffected by Trap 1
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetRange(LOCATION_PZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DAL))
  e2:SetValue(s.untfilter)
  c:RegisterEffect(e2)
  --Monster effects
  --(1) Reveal
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_ATKCHANGE,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.revtg,
    funcop=s.revop})
  --(2) Unaffected by Trap 2
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetCode(EFFECT_IMMUNE_EFFECT)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetValue(s.untfilter)
  c:RegisterEffect(e4)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--Pendulum effects
--(1) Inflict damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  return tp~=Duel.GetTurnPlayer()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
  Duel.SetTargetPlayer(1-tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local dam=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
  Duel.Damage(p,dam*300,REASON_EFFECT)
end
--(2) Unaffected by Trap 1
function s.untfilter(e,te)
  return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_TRAP)
end
--Monster effects
--(1) Reveal
function s.revfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler() 
  local tc=Duel.GetFirstTarget()
  Duel.ConfirmDecktop(tp,5)
  local g=Duel.GetDecktopGroup(tp,5)
  local ct=g:FilterCount(s.revfilter,nil)
  Duel.ShuffleDeck(tp)
  if ct>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(-ct*500)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  tc:RegisterEffect(e1)
  end
end