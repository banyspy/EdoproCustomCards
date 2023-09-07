--DAL Arusu Maria
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum effects
  --(1) Search 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_PZONE)
  e1:SetCountLimit(1,{id,1})
  e1:SetTarget(s.thtg1)
  e1:SetOperation(s.thop1)
  c:RegisterEffect(e1)
  --(2) Destroy
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCondition(s.descon)
  e2:SetTarget(s.destg)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Special Summon from hand
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_SPSUMMON_PROC)
  e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e3:SetRange(LOCATION_HAND)
  e3:SetCountLimit(1)
  e3:SetCondition(s.hspcon)
  e3:SetOperation(s.hspop)
  c:RegisterEffect(e3)
  --(2) Search
  DAL.CreateAddSpaceQuakeOnSummonEffect(c,true)
  --(3) Special Summon
  DAL.CreateTributeSummonListedMonsterEffect(c,CARD_DALSPIRIT_AI)
  --(4) Place Pendulum Zone
  local e8=Effect.CreateEffect(c)
  e8:SetDescription(aux.Stringid(id,3))
  e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e8:SetRange(LOCATION_EXTRA)
  e8:SetCountLimit(1)
  e8:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
  e8:SetTarget(s.pztg)
  e8:SetOperation(s.pzop)
  c:RegisterEffect(e8)
end
s.listed_names={CARD_DAL_SPACEQUAKE,CARD_DALSPIRIT_AI}
s.listed_series={SET_DAL}
--Pendulum Effects
--(1) Search
function s.thfilter1(c)
  return c:IsSetCard(SET_DAL) and c:IsSpell() and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
  if #g>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--(2) Destroy
function s.desconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingTarget(s.desconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.desfilter(c)
  return c:IsCode(CARD_DALSPIRIT_AI) and (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() 
  and c:IsLocation(LOCATION_EXTRA))) and not c:IsForbidden()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDestructable()
  and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
      Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
  end
end
--Monster Effects
--(1) Special Summon from hand
function s.hspconfilter(c)
  return c:IsSetCard(SET_DAL) and c:IsSpell() and not c:IsPublic()
end
function s.hspcon(e,c)
  if c==nil then return true end
  local tp=c:GetControler()
  return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.hspconfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
  local g=Duel.SelectMatchingCard(tp,s.hspconfilter,tp,LOCATION_HAND,0,1,1,nil)
  Duel.ConfirmCards(1-tp,g)
  Duel.ShuffleHand(tp)
end
--(4) Place Pendulum Zone
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return Duel.CheckPendulumZones(tp) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not Duel.CheckPendulumZones(tp) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() then return end
  if c:IsRelateToEffect(e) then
    Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
  end
end