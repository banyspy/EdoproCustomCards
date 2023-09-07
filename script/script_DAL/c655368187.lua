--DAL Takamiya Mana
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetRange(LOCATION_HAND)
  e1:SetCondition(s.hspcon)
  e1:SetValue(1)
  c:RegisterEffect(e1)
  --(2) Gain effect
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e2:SetCode(EVENT_BE_MATERIAL)
  e2:SetCondition(s.efcon)
  e2:SetOperation(s.efop)
  c:RegisterEffect(e2)
end
--(1) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsCode(CARD_DAL_ITSUKA_SHIDO)
end
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
  Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
--(2) Gain Effect
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return r&REASON_XYZ~=0 and c:GetReasonCard():IsSetCard(SET_DAL)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=c:GetReasonCard()
  --(2.1) Gain ATK
  local e1=Effect.CreateEffect(rc)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCondition(s.atkcon)
  e1:SetTarget(s.atktg)
  e1:SetOperation(s.atkop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  rc:RegisterEffect(e1,true)
  if not rc:IsType(TYPE_EFFECT) then
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_ADD_TYPE)
  e2:SetValue(TYPE_EFFECT)
  e2:SetReset(RESET_EVENT+RESETS_STANDARD)
  rc:RegisterEffect(e2,true)
  end
end
--(2.1) Gain ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetSummonType()&SUMMON_TYPE_XYZ~=0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and c:IsFaceup() then
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(500)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
  c:RegisterEffect(e1)
  end
end