--DAL Spirits' Guard
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCost(s.accost)
  e1:SetOperation(s.acop)
  c:RegisterEffect(e1)
  --(2) Act in hand
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  e2:SetCondition(s.handcon)
  c:RegisterEffect(e2)
end
s.listed_names={CARD_DAL_ITSUKA_SHIDO}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Activate
function s.accostfilter(c)
  return c:IsCode(CARD_DAL_ITSUKA_SHIDO) and c:IsAbleToRemoveAsCost()
end
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.accostfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectMatchingCard(tp,s.accostfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
  local tg=g:GetFirst()
  Duel.Remove(g,POS_FACEUP,REASON_COST)
  --(1.1) To hand
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e1:SetRange(LOCATION_REMOVED)
  e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e1:SetCountLimit(1)
  e1:SetCondition(s.tdcon)
  e1:SetOperation(s.tdop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
  tg:RegisterEffect(e1)
end
--(1.1) To hand
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetTurnPlayer()==tp
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_EFFECT)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
  --(1.2) Battle indes
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
  e1:SetTargetRange(LOCATION_MZONE,0)
  e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DAL))
  e1:SetValue(s.indval)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
  --(1.3) Cannot target
  local e2=e1:Clone()
  e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
  e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
  e2:SetValue(aux.tgoval)
  Duel.RegisterEffect(e2,tp)
end
--(1.2) Battle indes
function s.indval(e,re,rp)
  return rp~=e:GetHandlerPlayer()
end
--(2) Act in hand
function s.handfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.handcon(e)
  return Duel.IsExistingMatchingCard(s.handfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end