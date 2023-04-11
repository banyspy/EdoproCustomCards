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
  YuYuYu.DestroyAddRitualSpell(c,id)
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
  YuYuYu.TributeAdd(c,id,1)
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
  e4:SetCondition(function(e) return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) end)
  e4:SetTarget(s.destg2)
  e4:SetOperation(s.desop2)
  c:RegisterEffect(e4)
  --(3) Search 2
  YuYuYu.LeaveFieldAdd(c,id,1)
end
--Pendulum Effects
--(1) Destroy 1
--Already handle by BanyspyAux file
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
--Already handle by BanyspyAux file
--(2) Destroy
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
--Already handle by BanyspyAux file