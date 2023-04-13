--HN CPU CFW Magic
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),4,2)
  c:EnableReviveLimit()
  --(1) Destroy
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCost(s.descost)
  e1:SetTarget(s.destg)
  e1:SetOperation(s.desop)
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
  --(3) Gain ATK
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCode(EFFECT_UPDATE_ATTACK)
  e4:SetValue(s.atkvalue)
  e4:SetCondition(s.atkcon)
  c:RegisterEffect(e4)
  --(4) Gain LP
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_RECOVER)
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e5:SetCode(EVENT_DESTROYED)
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCondition(s.reccon)
  e5:SetCost(s.reccost)
  e5:SetTarget(s.rectg)
  e5:SetOperation(s.recop)
  c:RegisterEffect(e5)
end
--(1) Destroy
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack()/2)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    local dam=tc:GetAttack()/2
    if dam<0 or tc:IsFacedown() then dam=0 end
    if Duel.Destroy(tc,REASON_EFFECT)~=0 then
      Duel.Damage(1-tp,dam,REASON_EFFECT)
    end
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
--(3) Gain ATK
function s.atkcon(e)
  return e:GetHandler():GetFlagEffect(id)>0
end
function s.atkfilter(c)
  return c:IsSetCard(SET_HN_CPU) and c:IsType(TYPE_MONSTER)
end
function s.atkvalue(e,c)
  local g=Duel.GetMatchingGroup(s.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)
  local ct=g:GetClassCount(Card.GetCode)
  return ct*100
end
--(4) Gain LP
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
  local des=eg:GetFirst()
  if des:IsReason(REASON_BATTLE) then
    local rc=des:GetReasonCard()
    return rc and rc:IsSetCard(SET_HN) and rc:IsType(TYPE_MONSTER) and rc:IsType(TYPE_XYZ) 
    and rc:IsControler(tp) and rc:IsRelateToBattle() and e:GetHandler():GetFlagEffect(id)>0
  end
  return false
end
function s.reccostfilter(c)
  return c:IsSetCard(SET_HN_CPU) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.reccostfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.reccostfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,e:GetHandler())
  Duel.SendtoGrave(g,REASON_COST)
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local tc=eg:GetFirst()
  local atk=tc:GetBaseAttack()/2
  if atk<0 then atk=0 end
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(atk)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,atk)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Recover(p,d,REASON_EFFECT)
end