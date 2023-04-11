--YuYuYu Miyoshi Karin
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Destroy 1
  YuYuYu.DestroyAddRitualSpell(c,id)
  --(2) Return to hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.rthtg)
  e2:SetOperation(s.rthop)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Search 1
  YuYuYu.TributeAdd(c,id,2)
  --(2) Double damage
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,3))
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_ATTACK_ANNOUNCE)
  e4:SetCountLimit(1)
  e4:SetCost(s.ddcost)
  e4:SetTarget(s.ddtg)
  e4:SetOperation(s.ddop)
  c:RegisterEffect(e4)
  --(3) Search 2
  YuYuYu.LeaveFieldAdd(c,id,2)
end
--Pendulum Effects
--(1) Destroy
--Already handle by BanyspyAux file
--(2) Return to hand
function s.ppzfilter(c)
  return c:IsFaceup()and c:IsSetCard(SET_YUYUYU) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToHand()
  and Duel.IsExistingMatchingCard(s.ppzfilter,tp,LOCATION_EXTRA,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.ppzfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
  end
end
--Monster Effects
--(1) Search 1
--Already handle by BanyspyAux file
--(2) Double damage
function s.ddcostfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU)and c:IsType(TYPE_PENDULUM) and c:IsAbleToDeckAsCost()
end
function s.ddcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.ddcostfilter,tp,LOCATION_EXTRA,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.ddcostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
  Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToBattle() then return end
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
  e1:SetCondition(s.damcon)
  e1:SetOperation(s.damop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and e:GetHandler():GetBattleTarget()~=nil
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local dam=Duel.GetBattleDamage(ep)
  Duel.ChangeBattleDamage(ep,dam*2)
end
--(3) Search 2
--Already handle by BanyspyAux file