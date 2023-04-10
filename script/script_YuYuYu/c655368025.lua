--YuYuYu Togo Mimori
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Destroy 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_PZONE)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.destg1)
  e1:SetOperation(s.desop1)
  c:RegisterEffect(e1)
  --(2) Cannot activate
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetCode(EFFECT_CANNOT_ACTIVATE)
  e2:SetRange(LOCATION_PZONE)
  e2:SetTargetRange(0,1)
  e2:SetValue(s.caclimit)
  e2:SetCondition(s.cactcon)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Search 1
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1)
  e3:SetCost(s.thcost1)
  e3:SetTarget(s.thtg1)
  e3:SetOperation(s.thop1)
  c:RegisterEffect(e3)
  --(2) Destroy 2
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_DESTROY)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e4:SetCode(EVENT_FREE_CHAIN)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1,{id,1})
  e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
  e4:SetCondition(s.descon2)
  e4:SetTarget(s.destg2)
  e4:SetOperation(s.desop2)
  c:RegisterEffect(e4)
  --(3) Search 2
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e5:SetCode(EVENT_LEAVE_FIELD)
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e5:SetCondition(s.thcon2)
  e5:SetTarget(s.thtg2)
  e5:SetOperation(s.thop2)
  c:RegisterEffect(e5)
end
--Pendulum Effects
--(1) Destroy 1
function s.thfilter1(c)
  return c:IsSetCard(SET_YUYUYU) and (c:GetType()&(TYPE_SPELL+TYPE_RITUAL))>0 and c:IsAbleToHand()
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDestructable() and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
    end
  end
end
--(2) Cannot activate
function s.caclimit(e,re,tp)
  return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsImmuneToEffect(e)
end
function s.cactfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsControler(tp)
end
function s.cactcon(e)
  local tp=e:GetHandlerPlayer()
  local a=Duel.GetAttacker()
  local d=Duel.GetAttackTarget()
  return (a and s.cactfilter(a,tp)) or (d and s.cactfilter(d,tp))
end
--Monster Effects
--(1) Search 1
function s.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsReleasable() end
  Duel.Release(e:GetHandler(),REASON_COST)
end
function s.thfilter2(c)
  return c:IsSetCard(SET_YUYUYU) and (c:GetType()&(TYPE_MONSTER+TYPE_RITUAL))>0 and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--(2) Destroy
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
    Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
    if tc:IsRelateToEffect(e) then
      Duel.Destroy(tc,REASON_EFFECT)
    end
  end
end
--(3) Search 2
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
  and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
  if g:GetCount()>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
    Duel.ConfirmCards(1-tp,g)
    Duel.Recover(tp,500,REASON_EFFECT)
  end
end