--DAL Zadkiel - Freezing puppet
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Lose ATK/DEF
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT}
--(1) Lose ATK/DEF
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local atk=tc:GetAttack()//2
    local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc1 in aux.Next(g1) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetValue(-atk)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      tc1:RegisterEffect(e1)
      local e2=e1:Clone()
      e2:SetCode(EFFECT_UPDATE_DEFENSE)
      tc1:RegisterEffect(e2)
    end
  end
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
    --(1.1) Make ATK/DEF 0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetCondition(s.effcon)
    e1:SetTarget(s.efftg)
    e1:SetOperation(s.effop)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1,true)
    if not tc:IsType(TYPE_EFFECT) then
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_ADD_TYPE)
      e2:SetValue(TYPE_EFFECT)
      e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e2,true)
    end
  end
end
--(1.1) Make ATK/DEF 0
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return bc and bc:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
  local bc=e:GetHandler():GetBattleTarget()
  if bc:IsRelateToBattle() then
  local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(0)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    bc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    bc:RegisterEffect(e2)
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    bc:RegisterEffect(e3)
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_DISABLE_EFFECT)
    e4:SetValue(RESET_TURN_SET)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    bc:RegisterEffect(e4)
  end
end