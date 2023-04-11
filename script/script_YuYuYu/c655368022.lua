--YuYuYu Aobozu
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Give effect
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e1:SetCode(EVENT_BE_MATERIAL)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.mtcon)
  e1:SetOperation(s.mtop)
  c:RegisterEffect(e1)
  --(2) Destroy replace
  YuYuYu.DestroyReplace(c,id)
end
--(2) Give effect
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
  return r==REASON_RITUAL
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=eg:Filter(Card.IsSetCard,nil,SET_YUYUYU)
  local rc=g:GetFirst()
  if not rc then return end
  --(1.1) Negate attack
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetCategory(CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_ATTACK_ANNOUNCE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetCondition(s.nacon)
  e1:SetTarget(s.natg)
  e1:SetOperation(s.naop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  rc:RegisterEffect(e1,true)
  if not rc:IsType(TYPE_EFFECT) then
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetValue(TYPE_EFFECT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e2,true)
  end
  rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
end
--(1.1) Negate attack
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttacker():GetControler()~=tp
end
function s.desfilter(c,atk)
  return c:IsFaceup() and c:IsAttackBelow(atk)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local atk=Duel.GetAttacker():GetAttack()
  if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.naop(e,tp,eg,ep,ev,re,r,rp,chk)
  if Duel.NegateAttack() then
    local atk=Duel.GetAttacker():GetAttack()
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
    if g:GetCount()>0 then
      Duel.HintSelection(g)
      Duel.Destroy(g,REASON_EFFECT)
    end
  end
end
--(2) Destroy replace
--Already handle by BanyspyAux file