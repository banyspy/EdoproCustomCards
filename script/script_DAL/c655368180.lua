--DAL Spirit - Ruler
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Cannot Normal Summon
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetCode(EFFECT_CANNOT_SUMMON)
  c:RegisterEffect(e1)
  --(2) Special Summon from hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_SPSUMMON_PROC)
  e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e2:SetRange(LOCATION_HAND)
  e2:SetCondition(s.hspcon)
  c:RegisterEffect(e2)
  --(1) Special Summon
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_POSITION+CATEGORY_SEARCH+CATEGORY_TOHAND,
    functg=s.postg,
    funcop=s.postop})
  --(4) Negate
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,4))
  e4:SetCategory(CATEGORY_NEGATE)
  e4:SetType(EFFECT_TYPE_QUICK_O)
  e4:SetCode(EVENT_CHAINING)
  e4:SetCountLimit(1,id)
  e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  e4:SetRange(LOCATION_MZONE)
  e4:SetCondition(s.negcon)
  e4:SetTarget(s.negtg)
  e4:SetOperation(s.negop)
  c:RegisterEffect(e4)
  --(5) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_names={id}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(2) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT) and not c:IsCode(id)
end
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
  Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end
--(3) Change to face-down
function s.poscon(e,tp,eg,ep,ev,re,r,rp)
  return re and re:GetHandler():IsSetCard(SET_DAL) and not (e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM)
end
function s.posfilter(c)
  return c:IsFaceup() and c:IsCanTurnSet()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
  local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.postop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
  if g:GetCount()>0 then
    Duel.HintSelection(g)
    if Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)~=0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
      if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
      end
    end
  end
end
--(4) Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re) then
    Duel.SendtoGrave(eg,REASON_EFFECT)
  end
end
--(5) Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(0x997) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end