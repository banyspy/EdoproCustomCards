--DAL Spirit - Witch
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Change ATK/DEF
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SEARCH+CATEGORY_TOHAND,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.atktg,
    funcop=s.atkop})
  --(2) Negate attack
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_DAMAGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_ATTACK_ANNOUNCE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(s.negcon)
  e2:SetTarget(s.negtg)
  e2:SetOperation(s.negop)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--(1) Change ATK/DEF
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return re and re:GetHandler():IsSetCard(0x997) and not (e:GetHandler():GetSummonType()==SUMMON_TYPE_PENDULUM)
end
function s.atkfilter(c,atk)
  return c:IsFaceup() and c:GetAttack()~=atk
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local c=e:GetHandler()
  local atk=c:GetAttack()
  if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,atk) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,atk)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler() 
  local tc=Duel.GetFirstTarget()
  local atk=tc:GetAttack()
  local def=tc:GetDefense()
  if not tc:IsRelateToEffect(e) or not tc:IsFaceup() or not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_ATTACK_FINAL)
  e1:SetValue(atk)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
  e2:SetValue(def)
  e2:SetReset(RESET_EVENT+RESETS_STANDARD)
  c:RegisterEffect(e2)
  if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
    end
  end
end
--(2) Negate attack
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetAttacker():IsControler(1-tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  local a=Duel.GetAttacker()
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,a:GetAttack())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  if Duel.NegateAttack() then
  Duel.Damage(1-tp,a:GetAttack(),REASON_EFFECT)
  end
end