--YuYuYu Incorruptible Hearts
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  e0:SetTarget(s.actg)
  c:RegisterEffect(e0)
  --(1) Return to hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(s.rthtg)
  e1:SetOperation(s.rthop)
  c:RegisterEffect(e1)
  --(2) Move
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTarget(s.movetg)
  e2:SetOperation(s.moveop)
  c:RegisterEffect(e2)
  --(3) Activate in hand
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
  e3:SetCondition(s.handcon)
  c:RegisterEffect(e3)
end
s.listed_names={CARD_YUYUYU_SEA_OF_TREES}
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return true end
  local b1=s.rthtg(e,tp,eg,ep,ev,re,r,rp,0)
  local b2=s.movetg(e,tp,eg,ep,ev,re,r,rp,0)
  if (b1 or b2) and Duel.SelectYesNo(tp,94) then
    local op=0
    if b1 and b2 then
      op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then
      op=Duel.SelectOption(tp,aux.Stringid(id,0))
    else
      op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
    end
    if op==0 then
      s.rthtg(e,tp,eg,ep,ev,re,r,rp,1)
      e:SetCategory(CATEGORY_TOHAND)
      e:SetProperty(0)
      e:SetOperation(s.rthop)
    else
      s.movetg(e,tp,eg,ep,ev,re,r,rp,1)
      e:SetProperty(EFFECT_FLAG_CARD_TARGET)
      e:SetOperation(s.moveop)
    end
  else
    e:SetCategory(0)
    e:SetProperty(0)
    e:SetOperation(nil)
  end
end
--(1) Return to hand
function s.thfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsAbleToHand()
end
function s.ppzfilter(c)
  return (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsSetCard(SET_YUYUYU) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_PZONE,0,1,nil) 
  and Duel.IsExistingMatchingCard(s.ppzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
  and e:GetHandler():GetFlagEffect(id)==0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE)
  e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_PZONE,0,1,1,nil)
  if g1:GetCount()>0 and Duel.SendtoHand(g1,tp,REASON_EFFECT)>0 and g1:GetFirst():IsLocation(LOCATION_HAND) then
    Duel.ConfirmCards(1-tp,g1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g2=Duel.SelectMatchingCard(tp,s.ppzfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    local tc=g2:GetFirst()
    if tc then
      Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
  end
end
--(2) Move
function s.movefilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and bit.band(c:GetType(),0x81)==0x81
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.movefilter,tp,LOCATION_MZONE,0,1,nil)
  and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():GetFlagEffect(id)==0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.movefilter,tp,LOCATION_MZONE,0,1,1,nil)
  e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
  Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0),2))
end
--(4) Activate in hand
function s.handcon(e)
  return Duel.IsEnvironment(CARD_YUYUYU_SEA_OF_TREES)
end