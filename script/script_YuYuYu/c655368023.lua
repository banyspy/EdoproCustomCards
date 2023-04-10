--YuYuYu Yoshiteru
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
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e2:SetCode(EFFECT_DESTROY_REPLACE)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetTarget(s.dreptg)
  e2:SetValue(s.drepval)
  e2:SetOperation(s.drepop)
  c:RegisterEffect(e2)
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
  --(1.1) Second attack
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_BATTLE_DESTROYING)
  e1:SetCondition(s.sacon)
  e1:SetTarget(s.satg)
  e1:SetOperation(s.saop)
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
--(1.1) Gain ATK
function s.sacon(e,tp,eg,ep,ev,re,r,rp)
  return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
function s.satg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.saop(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_ATTACK)
  e1:SetValue(700)
  e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_BATTLE)
  e:GetHandler():RegisterEffect(e1)
  Duel.ChainAttack()
end
--(2) Destroy replace
function s.drepfilter(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and bit.band(c:GetType(),0x81)==0x81 and c:IsControler(tp)
  and c:IsLocation(LOCATION_MZONE) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.drepfilter,1,nil,tp) and eg:GetCount()==1 
  and Duel.GetFlagEffect(tp,id)==0 end
  return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.drepval(e,c)
  return s.drepfilter(c,e:GetHandlerPlayer())
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
  Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end