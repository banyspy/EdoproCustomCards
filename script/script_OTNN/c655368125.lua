--OTNN Tail Red - Faller Chain
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
  --(4) Double damage
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
  e4:SetOperation(s.ddop)
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
  e7:SetType(EFFECT_TYPE_IGNITION)
  e7:SetRange(LOCATION_MZONE)
  e7:SetCountLimit(1)
  e7:SetCost(s.atkcost2)
  e7:SetTarget(s.atktg2)
  e7:SetOperation(s.atkop2)
  c:RegisterEffect(e7)
  --(8) Negate
  local e8=Effect.CreateEffect(c)
  e8:SetDescription(aux.Stringid(id,3))
  e8:SetCategory(CATEGORY_DISABLE)
  e8:SetType(EFFECT_TYPE_QUICK_O)
  e8:SetCode(EVENT_CHAINING)
  e8:SetCountLimit(1)
  e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e8:SetRange(LOCATION_MZONE)
  e8:SetCondition(s.negcon)
  e8:SetTarget(s.negtg)
  e8:SetOperation(s.negop)
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
--(4) Double damage
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ChangeBattleDamage(ep,ev*2)
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
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) then
  	local e1=Effect.CreateEffect(c)
  	e1:SetType(EFFECT_TYPE_SINGLE)
	  e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	  e1:SetCode(EFFECT_UPDATE_ATTACK)
	  e1:SetValue(c:GetOverlayCount()*600)
  	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
  	c:RegisterEffect(e1)
  end
end
--(8) Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
  local rc=re:GetHandler()
  return bit.band(loc,LOCATION_MZONE)~=0 and rp~=tp and re:IsActiveType(TYPE_MONSTER)
  and Duel.IsChainDisablable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=re:GetHandler()
  if Duel.NegateEffect(ev) and c:IsRelateToEffect(e) and rc:IsRelateToEffect(re) and c:IsType(TYPE_XYZ) then
  	local og=rc:GetOverlayGroup()
    if og:GetCount()>0 then
      Duel.SendtoGrave(og,REASON_RULE)
    end
  	rc:CancelToGrave()
  	Duel.Overlay(c,Group.FromCards(rc))
  end
end