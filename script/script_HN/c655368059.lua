--HN MAGES.
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effcts
  --(1) Destroy replace
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_DESTROY_REPLACE)
  e1:SetRange(LOCATION_PZONE)
  e1:SetTarget(s.dreptg)
  e1:SetValue(s.drepval)
  e1:SetOperation(s.drepop)
  c:RegisterEffect(e1)
  --(2) Inflict damage
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_DAMAGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(s.damtg)
  e2:SetOperation(s.damop)
  c:RegisterEffect(e2)
  --Monster Effects
  ---(1) Unaffected by S/T
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_IMMUNE_EFFECT)
  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e3:SetRange(LOCATION_MZONE)
  e3:SetValue(s.unfilter)
  c:RegisterEffect(e3)
  --(2) Gain effect this turn
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
  e4:SetCode(EVENT_SUMMON_SUCCESS)
  e4:SetOperation(s.geop)
  c:RegisterEffect(e4)
  local e5=e4:Clone()
  e5:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e5)
  if not s.global_check then
    s.global_check=true
    s[0]=0
    s[1]=0
    local ge1=Effect.CreateEffect(c)
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
    ge1:SetOperation(s.checkop)
    Duel.RegisterEffect(ge1,0)
    local ge2=Effect.CreateEffect(c)
    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
    ge2:SetOperation(s.clearop)
    Duel.RegisterEffect(ge2,0)
  end
end
--Pendulum Effects
--(1) Destroy replace
function s.drepfilter(c,tp)
  return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
    and c:IsSetCard(SET_HN) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()~=tp
end
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return eg:IsExists(s.drepfilter,1,nil,tp) and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
  return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.drepval(e,c)
  return s.drepfilter(c,e:GetHandlerPlayer())
end
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
---(2) Inflict damage
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
  local tc=eg:GetFirst()
  while tc do
    if tc:IsSetCard(SET_HN) and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
    and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()) then
      local p=tc:GetSummonPlayer()
      s[p]=s[p]+1
    end
    tc=eg:GetNext()
  end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
  s[0]=0
  s[1]=0
end 
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return s[tp]>0 end
  Duel.SetTargetPlayer(1-tp)
  Duel.SetTargetParam(s[tp]*300)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,s[tp]*300)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  Duel.Damage(p,s[tp]*300,REASON_EFFECT)
end
--Monster Effects
--(1) Unsaffected by S/T
function s.unfilter(e,te)
  return te:IsActiveType(TYPE_TRAP+TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--(2) Gain effect this turn
function s.geop(e,tp,eg,ep,ev,re,r,rp)
  --(2.1) Special Summon
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetDescription(aux.Stringid(id,1))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,id)
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  e1:SetReset(RESET_EVENT+0x16c0000+RESET_PHASE+PHASE_END)
  e:GetHandler():RegisterEffect(e1)
end
--(2.1) Special Summon
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_HN) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end