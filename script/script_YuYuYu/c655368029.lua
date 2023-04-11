--YuYuYu Nogi Sonoko
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Destroy
  YuYuYu.DestroyAddRitualSpell(c,id)
  --(2) Add to Extra Deck
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCountLimit(1,{id,1})
  e2:SetTarget(s.aedtg)
  e2:SetOperation(s.aedop)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Search 1
  YuYuYu.TributeAdd(c,id,2)
  --(2) Gain ATK
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,3))
  e4:SetCategory(CATEGORY_ATKCHANGE)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_BATTLE_DESTROYING)
  e4:SetCondition(s.atkcon1)
  e4:SetTarget(s.atktg)
  e4:SetOperation(s.atkop)
  c:RegisterEffect(e4)
  local e5=e4:Clone()
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e5:SetCode(EVENT_DESTROYED)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCondition(s.atkcon2)
  c:RegisterEffect(e5)
  --(3) Search 2
  YuYuYu.LeaveFieldAdd(c,id,2)
end
--Pendulum Effects
--(1) Destroy
--Already handle by BanyspyAux file
--(2) Add to Extra Deck
function s.ppzfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.aedtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.ppzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectTarget(tp,s.ppzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.aedop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local tc=Duel.GetFirstTarget()
  if Duel.SendtoExtraP(e:GetHandler(),nil,REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    if tc then
      Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
  end
end
--Monster Effects
--(1) Search 1
--Already handle by BanyspyAux file
--(2) Gain ATK
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsRelateToBattle()
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
  return r&REASON_EFFECT~=0 and re:GetHandler()==e:GetHandler()
end
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsRitualMonster()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(600)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end
--(3) Search 2
--Already handle by BanyspyAux file