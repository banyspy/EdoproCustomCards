--DAL Spirit Comrade
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:SetUniqueOnField(1,0,id)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
  e0:SetHintTiming(TIMING_DAMAGE_STEP)
  e0:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e0)
  --(1) Gain ATK/DEF
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(s.atktg)
  e1:SetValue(s.atkval)
  c:RegisterEffect(e1)
  local e2=e1:Clone()
  e2:SetCode(EFFECT_UPDATE_DEFENSE)
  c:RegisterEffect(e2)
  --(2) Battle Indes
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e3:SetRange(LOCATION_SZONE)
  e3:SetTargetRange(LOCATION_MZONE,0)
  e3:SetCondition(s.indcon)
  e3:SetTarget(s.indtarget)
  e3:SetValue(s.indct)
  c:RegisterEffect(e3)
  --(3) Set Trap
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetProperty(EFFECT_FLAG_DELAY)
  e4:SetCode(EVENT_DESTROYED)
  e4:SetCondition(s.settcon)
  e4:SetTarget(s.setttg)
  e4:SetOperation(s.settop)
  c:RegisterEffect(e4)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Gain ATK
function s.atktg(e,c)
  return c:IsSetCard(SET_DALSPIRIT)
end
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.atkval(e,c)
  return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*300
end
--(2) Battle Indes
function s.indfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.indcon(e)
  return Duel.IsExistingMatchingCard(s.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
function s.indtarget(e,c)
  return c:IsSetCard(SET_DALSPIRIT)
end
function s.indct(e,re,r,rp)
  if r&REASON_BATTLE~=0 then
    return 1
  else return 0 end
end
--(3) Set Trap
function s.settcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsPreviousPosition(POS_FACEUP)
end
function s.settfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_TRAP) and c:IsSSetable() and not c:IsCode(id)
end
function s.setttg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.settfilter,tp,LOCATION_DECK,0,1,nil,false) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.settop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectMatchingCard(tp,s.settfilter,tp,LOCATION_DECK,0,1,1,nil,false)
  local tc=g:GetFirst()
  if tc then
    Duel.SSet(tp,tc)
    Duel.ConfirmCards(1-tp,tc)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
  end
end