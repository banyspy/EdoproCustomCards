--HN CFW Judge
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),4,2)
  c:EnableReviveLimit()
  --(1) Gain Def
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DEFCHANGE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCost(s.defcost)
  e1:SetTarget(s.deftg)
  e1:SetOperation(s.defop)
  c:RegisterEffect(e1,false,1)
  --(2) Gain effects
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetCondition(s.gecon)
  e2:SetOperation(s.geop)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_MATERIAL_CHECK)
  e3:SetValue(s.valcheck)
  e3:SetLabelObject(e2)
  c:RegisterEffect(e3)
  --(3) Indes by effects
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e4:SetCondition(s.indcon)
  e4:SetValue(1)
  c:RegisterEffect(e4)
  --(4) Change battle position
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e5:SetCode(EVENT_DESTROYED)
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCondition(s.poscon)
  e5:SetCost(s.poscost)
  e5:SetTarget(s.postg)
  e5:SetOperation(s.posop)
  c:RegisterEffect(e5)
end
--(1) Gain Def
function s.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.deffilter(c)
  return c:IsFaceup() and c:GetBaseAttack()>0
end
function s.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.deffilter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.deffilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.defop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  local c=e:GetHandler()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_DEFENSE)
    e1:SetValue(tc:GetBaseAttack()/2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_ATTACK)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
    tc:RegisterEffect(e2)
  end
end
--(2) Gain effects
function s.gecon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function s.geop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
  c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
function s.valcheck(e,c)
  local g=c:GetMaterial()
  if g:IsExists(Card.IsCode,1,nil,CARD_HN_ARFOIRE) then
    e:GetLabelObject():SetLabel(1)
  else
    e:GetLabelObject():SetLabel(0)
  end
end
--(3) Indes by effects
function s.indcon(e)
  return e:GetHandler():GetFlagEffect(id)>0
end
--(4) Change battle position
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
  local des=eg:GetFirst()
  if des:IsReason(REASON_BATTLE) then
    local rc=des:GetReasonCard()
    return rc and rc:IsSetCard(SET_HN) and rc:IsType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ) 
    and rc:IsControler(tp) and rc:IsRelateToBattle() and e:GetHandler():GetFlagEffect(id)>0
  end
  return false
end
function s.poscostfilter(c)
  return c:IsSetCard(SET_HN_CPU) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.poscostfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.poscostfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
  Duel.SendtoGrave(g,REASON_COST)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsCanChangePosition() end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SWAP_AD)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
  end
end