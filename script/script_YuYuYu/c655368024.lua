--YuYuYu Yuuki Yuuna
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Destroy 1
  YuYuYu.DestroyAddRitualSpell(c,id)
  --(2) Gain ATK
  local e2=Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_ATKCHANGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCondition(s.atkcon)
  e2:SetOperation(s.atkop)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Search 1
  YuYuYu.TributeAdd(c,id,1)
  --(2) Destroy 2
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_BATTLE_START)
  e4:SetCountLimit(1)
  e4:SetCondition(s.descon2)
  e4:SetTarget(s.destg2)
  e4:SetOperation(s.desop2)
  c:RegisterEffect(e4)
  --(3) Search 2
  YuYuYu.LeaveFieldAdd(c,id,1)
end
--Pendulum Effects
--(1) Destroy 1
--Already handle by BanyspyAux file
--(2) Gain ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  if not a:IsControler(tp) then
    a=Duel.GetAttackTarget()
  end
  return a and a:IsSetCard(SET_YUYUYU) and a:IsRitualMonster()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_CARD,0,id)
  local tc=Duel.GetAttacker()
  if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
  if tc:IsRelateToBattle() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    tc:RegisterEffect(e1)
  end
end
--Monster Effects
--(1) Search 1
--Already handle by BanyspyAux file
--(2) Destroy 2
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return bc
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetBattleTarget():GetAttack())
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
  local bc=e:GetHandler():GetBattleTarget()
  if bc:IsRelateToBattle() then
    local dam=bc:GetAttack()
    if Duel.Destroy(bc,REASON_EFFECT)~=0 then
      Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
  end
end
--(3) Search 2
--Already handle by BanyspyAux file