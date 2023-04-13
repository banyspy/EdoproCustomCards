--HN Next Black
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),5,3)
  c:EnableReviveLimit()
  --(1) Gain additional effect
  --(1.1) Cannot chain
  --(3) Special Summon
  HN.HDDNextCommonEffect(c,id,CARD_HN_HDD_WHITE_HEART)
  --(2) Half ATK
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_BATTLE_CONFIRM)
  e3:SetCountLimit(1)
  e3:SetCondition(s.atkcon)
  e3:SetCost(s.atkcost)
  e3:SetTarget(s.atktg)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3,false,1)
end
s.listed_names={CARD_HN_HDD_WHITE_HEART}
--(2) Half ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  e:GetHandler():GetBattleTarget():CreateEffectRelation(e)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=c:GetBattleTarget()
  if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
  if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    e1:SetValue(math.ceil(tc:GetAttack()/2))
    tc:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CHANGE_DAMAGE)
    e3:SetTargetRange(0,1)
    e3:SetValue(s.damval)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
    Duel.RegisterEffect(e3,tp)
  end
end
function s.damval(e,re,val,r,rp,rc)
  local tp=e:GetHandlerPlayer()
  if r&REASON_BATTLE==0 then return val end
  return val*2
end