--HN Oblivion Conflict
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Gain ATK 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_DAMAGE_STEP_END)
  e1:SetCondition(s.atkcon1)
  e1:SetTarget(s.atktg1)
  e1:SetOperation(s.atkop1)
  c:RegisterEffect(e1)
  --(2) Gain ATK 2
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_ATKCHANGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCondition(s.atkcon2)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.atktg2)
  e2:SetOperation(s.atkop2)
  c:RegisterEffect(e2)
end
--(1) Gain ATK 1
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  local d=Duel.GetAttackTarget()
  if not d then return end
  if d:IsControler(tp) then
    e:SetLabelObject(d)
    return d:IsSetCard(SET_HN) and d:IsType(TYPE_XYZ) and a:IsRelateToBattle() and a:IsLocation(LOCATION_ONFIELD)
  elseif a:IsControler(tp) then
    e:SetLabelObject(a)
    return a:IsSetCard(SET_HN) and a:IsType(TYPE_XYZ) and d:IsRelateToBattle() and d:IsLocation(LOCATION_ONFIELD)
  end
  return false
end
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=e:GetLabelObject()
  if chk==0 then return tc:IsLocation(LOCATION_ONFIELD) and tc:IsRelateToBattle() end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
  local tc=e:GetLabelObject()
  if tc:IsRelateToBattle() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
    e1:SetValue(1000)
    tc:RegisterEffect(e1)
    if tc:IsChainAttackable() then
      Duel.ChainAttack()
    end
  end
end
--(2) Gain ATK 2
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  if not a:IsControler(tp) then
    a=Duel.GetAttackTarget()
  end
  return a and a:IsSetCard(SET_HN) and a:IsType(TYPE_XYZ) and aux.exccon(e)
end
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetAttacker()
  if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
  if tc:IsFaceup() and tc:IsRelateToBattle() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1000)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    tc:RegisterEffect(e1)
  end
end