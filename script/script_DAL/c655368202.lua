--DAL Camael - Bright Burning Annihilating Demon
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Inflict damage 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DAMAGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.damtg1)
  e1:SetOperation(s.damop1)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DALSPIRIT}
--(1) Inflict damage
function s.damfilter1(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.damtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.damfilter1,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.damfilter1,tp,LOCATION_MZONE,0,1,1,nil)
  local tc=g:GetFirst()
  local atk=tc:GetAttack()//2
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,atk)
end
function s.damop1(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsFaceup() and tc:IsRelateToEffect(e) then
  local atk=tc:GetAttack()//2
    Duel.Damage(1-tp,atk,REASON_EFFECT)
  end
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
  --(1.1) Inflict damage 2
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EVENT_BATTLE_DESTROYING)
    e1:SetCondition(aux.bdcon)
    e1:SetTarget(s.damtg2)
    e1:SetOperation(s.damop2)
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
--(1.1) Inflict damage 2
function s.damtg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local dam=e:GetHandler():GetBattleTarget():GetBaseAttack()
  if dam<0 then dam=0 end
  Duel.SetTargetPlayer(1-tp)
  Duel.SetTargetParam(dam/2)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam/2)
end
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Damage(p,d,REASON_EFFECT)
end