--DAL Sandalphon - Throne of Annihilation
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Gain ATK
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT}
--(1) Gain ATK
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    --(1.1) Second attack
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e2:SetCondition(s.sacon)
    e2:SetTarget(s.satg)
    e2:SetOperation(s.saop)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2,true)
    --(1.2) Double damage
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
    e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e3:SetCondition(s.ddcon)
    e3:SetOperation(s.ddop)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e3,true)
    if not tc:IsType(TYPE_EFFECT) then
      local e4=Effect.CreateEffect(e:GetHandler())
      e4:SetType(EFFECT_TYPE_SINGLE)
      e4:SetCode(EFFECT_ADD_TYPE)
      e4:SetValue(TYPE_EFFECT)
      e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
      tc:RegisterEffect(e4,true)
    end
  end
end
--(1.1) Second attack
function s.sacon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
  and not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK)
end
function s.satg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsRelateToBattle() end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.saop(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_EXTRA_ATTACK)
  e1:SetValue(1)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
  e:GetHandler():RegisterEffect(e1)
end
--(1.2) Double damage
function s.ddcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and e:GetHandler():GetBattleTarget()~=nil
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ChangeBattleDamage(ep,ev*2)
end