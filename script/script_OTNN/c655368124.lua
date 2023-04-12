--OTNN Tail Yellow
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:EnableReviveLimit()
  --Xyz Summon
  Xyz.AddProcedure(c,s.xyzfilter,nil,2,nil,nil,99,nil,false,s.xyzcheck)
  --(1) Gain Rank
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e1:SetTarget(s.rktg)
  e1:SetOperation(s.rkop)
  c:RegisterEffect(e1)
  --(2) Gain ATK
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_ATKCHANGE)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetCode(EVENT_ATTACK_ANNOUNCE)
  e2:SetTarget(s.atktg)
  e2:SetOperation(s.atkop)
  c:RegisterEffect(e2)
  --(3) Attach
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_BATTLE_DESTROYING)
  e3:SetCondition(aux.bdocon)
  e3:SetTarget(s.attachtg)
  e3:SetOperation(s.attachop)
  c:RegisterEffect(e3)
  --(4) Destroy replace
  local e4=Effect.CreateEffect(c)
  e4:SetCategory(EFFECT_DESTROY_REPLACE+CATEGORY_DAMAGE)
  e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e4:SetCode(EFFECT_DESTROY_REPLACE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCountLimit(1)
  e4:SetTarget(s.dreptg)
  e4:SetValue(function (e,c) return s.drepfilter1(c,e:GetHandlerPlayer()) end)
  e4:SetOperation(s.drepop)
  c:RegisterEffect(e4)
  --(5) Inflict damage
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,3))
  e5:SetCategory(CATEGORY_DAMAGE)
  e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e5:SetCode(EVENT_ATTACK_ANNOUNCE)
  e5:SetTarget(s.damtg)
  e5:SetOperation(s.damop)
  c:RegisterEffect(e5)
end
--Xyz Summon
function s.xyzfilter(c,tp)
  return c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(1)
end
function s.xyzcheck(g,tp)
  local mg=g:Filter(function(c) return not c:IsHasEffect(511001175) end,nil)
  return mg:GetClassCount(Card.GetLevel)==1
end
function s.check(c,lvl)
  return c:Level()~=lvl and not c:IsHasEffect(511001175)
end
--(1) Gain Rank
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_UPDATE_RANK)
  e1:SetValue(1)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
  c:RegisterEffect(e1)
end
--(2) Gain ATK
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
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
--(3) Attach
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
--(4) Destroy replace
function s.drepfilter1(c,tp)
  return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) 
  and c:IsSetCard(SET_OTNN) and c:IsType(TYPE_XYZ) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return eg:IsExists(s.drepfilter1,1,nil,tp) 
  and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
  if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT+REASON_REPLACE)
  return true
  else return false end
end
function s.drepfilter2(c)
  return c:IsFaceup() and c:IsSetCard(SET_OTNN) and c:IsType(TYPE_XYZ)
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.IsExistingMatchingCard(s.drepfilter2,tp,LOCATION_MZONE,0,1,nil)  then
    local g=Duel.GetMatchingGroup(s.drepfilter2,tp,LOCATION_MZONE,0,nil)
    local sum=0
    local tc=g:GetFirst()
    while tc do
      sum=sum+tc:GetRank()
      tc=g:GetNext()
    end
    if sum>0 then
      Duel.Damage(1-tp,sum*100,REASON_EFFECT)
    end
  else 
    return end
end
--(5) Inflict damage
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
  Duel.SetTargetPlayer(1-tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
  Duel.Damage(p,ct*300,REASON_EFFECT)
end