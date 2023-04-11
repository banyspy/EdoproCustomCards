--YuYuYu Inubouzaki Fuu
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
  --(2) Place in PZone
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCountLimit(1,{id,1})
  e2:SetCondition(s.ppzcon)
  e2:SetTarget(s.ppztg)
  e2:SetOperation(s.ppzop)
  c:RegisterEffect(e2)
  --Monster Effects
  --(1) Search 1
  YuYuYu.TributeAdd(c,id,2)
  --(2) Gain ATK
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,3))
  e4:SetCategory(CATEGORY_ATKCHANGE)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e4:SetCode(EVENT_ATTACK_ANNOUNCE)
  e4:SetTarget(s.atktg)
  e4:SetOperation(s.atkop)
  c:RegisterEffect(e4)
  --(3) Search 2
  YuYuYu.LeaveFieldAdd(c,id,2)
end
--Pendulum Effects
--(1) Destroy
--Already handle by BanyspyAux file
--(2) Place in PZone
function s.ppzcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)==1
end
function s.ppzfilter(c)
  return c:IsSetCard(SET_YUYUYU) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.ppztg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
  and Duel.IsExistingMatchingCard(s.ppzfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.ppzop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
  local g=Duel.SelectMatchingCard(tp,s.ppzfilter,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
  end
end
--Monster Effects
--(1) Search 1
--Already handle by BanyspyAux file
--(2) Gain ATK
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsRitualMonster()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local ct=Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
  for tc in aux.Next(g) do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(ct*200)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
    tc:RegisterEffect(e1)
  end
end
--(3) Search 2
--Already handle by BanyspyAux file