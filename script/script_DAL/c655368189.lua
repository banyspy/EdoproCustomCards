--DAL Inverse Spirit - Demon Lord
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --(1) Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetRange(LOCATION_HAND)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetCondition(s.hspcon)
  e1:SetOperation(s.hspop)
  c:RegisterEffect(e1)
  --(2) Destroy
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_DESTROY,
    functg=s.destg,
    funcop=s.desop})
  --(3) Destroy replace
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_DESTROY_REPLACE)
  e3:SetCountLimit(1)
  e3:SetTarget(s.dreptg)
  e3:SetOperation(s.drepop)
  c:RegisterEffect(e3)
  --(4) Cannot activate S/T
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e4:SetCode(EVENT_ATTACK_ANNOUNCE)
  e4:SetOperation(s.acop)
  c:RegisterEffect(e4)
end
s.listed_names={CARD_DALSPIRIT_PRINCESS}
s.listed_series={SET_DAL}
--(1) Special Summon from hand
function s.hspconfilter(c,tp)
  return c:IsFaceup() and c:IsCode(CARD_DALSPIRIT_PRINCESS) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
function s.hspcon(e,c)
  if c==nil then return true end
  local tp=c:GetControler()
  return Duel.IsExistingMatchingCard(s.hspconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
  local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectMatchingCard(tp,s.hspconfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
  Duel.Remove(g,POS_FACEUP,REASON_COST)
end
--(2) Destroy
function s.desfilter(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
  local ct=Duel.Destroy(g,REASON_EFFECT)
  if ct>0 then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(ct*300)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
  end
end
--(3) Destroy replace
function s.drepfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DAL) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
  and Duel.IsExistingMatchingCard(s.drepfilter,tp,LOCATION_ONFIELD,0,1,c) end
  if Duel.SelectEffectYesNo(tp,c,96) then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
    local g=Duel.SelectMatchingCard(tp,s.drepfilter,tp,LOCATION_ONFIELD,0,1,1,c)
    Duel.SetTargetCard(g)
    g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
    return true
  else return false end
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
  Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
--(4) Cannot activate S/T
function s.acop(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EFFECT_CANNOT_ACTIVATE)
  e1:SetTargetRange(0,1)
  e1:SetValue(s.aclimit)
  e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
  Duel.RegisterEffect(e1,tp)
end
function s.aclimit(e,re,tp)
  return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end