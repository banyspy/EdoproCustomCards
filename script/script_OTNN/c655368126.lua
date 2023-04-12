--OTNN Tail Red - Riser Chain
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --Xyz Summon
  Xyz.AddProcedure(c,s.xyzfilter,nil,99,s.ovfilter,aux.Stringid(id,0))
  --Special Summon condition
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
  e0:SetCode(EFFECT_SPSUMMON_CONDITION)
  c:RegisterEffect(e0)
  --(1) Gain rank 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCondition(s.rkcon1)
  e1:SetTarget(s.rktg1)
  e1:SetOperation(s.rkop1)
  c:RegisterEffect(e1)
  --(2) Indes by effects
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCondition(s.indcon)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  --(3) Gain Rank 2
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,0))
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCountLimit(1)
  e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e3:SetTarget(s.rktg1)
  e3:SetOperation(s.rkop2)
  c:RegisterEffect(e3)
  --(4) Second attack
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetCode(EFFECT_EXTRA_ATTACK)
  e4:SetValue(1)
  c:RegisterEffect(e4)
  --(5) Gain ATK 1
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,1))
  e5:SetCategory(CATEGORY_ATKCHANGE)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e5:SetCode(EVENT_ATTACK_ANNOUNCE)
  e5:SetTarget(s.atktg1)
  e5:SetOperation(s.atkop1)
  c:RegisterEffect(e5)
  --(6) Attach
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,2))
  e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e6:SetCode(EVENT_BATTLE_DESTROYING)
  e6:SetCondition(aux.bdocon)
  e6:SetTarget(s.attachtg)
  e6:SetOperation(s.attachop)
  c:RegisterEffect(e6)
  --(7) Gain ATK 2
  local e7=Effect.CreateEffect(c)
  e7:SetDescription(aux.Stringid(id,1))
  e7:SetCategory(CATEGORY_ATKCHANGE)
  e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e7:SetCode(EVENT_SPSUMMON_SUCCESS)
  e7:SetRange(LOCATION_MZONE)
  e7:SetCountLimit(2)
  e7:SetCost(s.atkcost2)
  e7:SetTarget(s.atktg2)
  e7:SetOperation(s.atkop2)
  c:RegisterEffect(e7)
  --(8) Destroy
  local e8=Effect.CreateEffect(c)
  e8:SetDescription(aux.Stringid(id,3))
  e8:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
  e8:SetType(EFFECT_TYPE_IGNITION)
  e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e8:SetCountLimit(1)
  e8:SetRange(LOCATION_MZONE)
  e8:SetTarget(s.destg)
  e8:SetOperation(s.desop)
  c:RegisterEffect(e8)
end
--Xyz Summon
function s.xyzfilter(c,xyz,sumtype,tp)
  return c:IsType(TYPE_XYZ,xyz,sumtype,tp) and not c:IsSetCard(SET_OTNN)
end
function s.ovfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_OTNN) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>=5 and not c:IsCode(id)
end
--(1) Gain rank 1
function s.rkcon1(e,tp,eg,ep,ev,re,r,rp)
  local ct=e:GetHandler():GetOverlayCount()
  return e:GetHandler():GetSummonType()==SUMMON_TYPE_XYZ and ct>0
end
function s.rktg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rkop1(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_RANK)
  e1:SetValue(c:GetOverlayCount())
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
  c:RegisterEffect(e1)
end
--(2) Indes by effects
function s.indfilter(c)
  return c:IsSetCard(SET_OTNN)
end
function s.indcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():GetOverlayGroup():Filter(s.indfilter,nil)
end
--(3) Gain rank 2
function s.rkop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_RANK)
  e1:SetValue(1)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
  c:RegisterEffect(e1)
end
--(5) Gain ATK
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and c:IsFaceup() then
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE)
    e1:SetValue(c:GetRank()*100)
    c:RegisterEffect(e1)
  end
end
--(6) Attach
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=c:GetBattleTarget()
  if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsAbleToChangeControler() 
  and not tc:IsImmuneToEffect(e) and not tc:IsHasEffect(EFFECT_NECRO_VALLEY) then
    local og=tc:GetOverlayGroup()
    if og:GetCount()>0 then
      Duel.SendtoGrave(og,REASON_RULE)
    end
    Duel.Overlay(c,Group.FromCards(tc))
  end
end
--(7) Gain ATK 2
function s.atkcost2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atkfilter2(c,e,tp)
  return c:GetSummonPlayer()==1-tp and (not e or c:IsRelateToEffect(e))
end
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return eg:IsExists(s.atkfilter2,1,nil,nil,tp) end
  local g=eg:Filter(s.atkfilter2,nil,nil,tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetTargetCard(eg)
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
  local g=eg:Filter(s.atkfilter2,nil,e,tp)
  local sum=0
  for tc in aux.Next(g) do
    sum=sum+tc:GetBaseAttack()/2
  end
  if sum>0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(sum)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
  end
end
--(8) Destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
  local dam=g:GetFirst():GetAttack()
  if dam<0 then dam=0 end
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local dam=tc:GetAttack()
    if Duel.Destroy(tc,REASON_EFFECT)~=0 then
      local atk=Duel.Damage(1-tp,dam,REASON_EFFECT)
      if atk>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
      end
    end
  end
end