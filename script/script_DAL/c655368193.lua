--DAL Vanargandr - Mana
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_DAL),3,3)
  c:EnableReviveLimit()
  --(1) Gain ATK
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCost(aux.dxmcostgen(1,1,nil))
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop)
  c:RegisterEffect(e1,false,1)
  --(2) Piercing
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_PIERCE)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Gain ATK
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) 
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
    local atk=tc:GetAttack()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    e1:SetValue(math.ceil(atk/2))
    tc:RegisterEffect(e1)
    if c:IsRelateToEffect(e) and c:IsFaceup() then
      local e2=Effect.CreateEffect(c)
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_UPDATE_ATTACK)
      e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
      e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
      e2:SetValue(math.ceil(atk/2))
      c:RegisterEffect(e2)
    end
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetValue(1)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e3)
  end
end