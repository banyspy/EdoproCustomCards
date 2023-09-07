--DAL Spirit - Diva
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Take control
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_CONTROL+CATEGORY_SEARCH+CATEGORY_TOHAND,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.tctg,
    funcop=s.tcop})
  --(2) Lose ATK
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1)
  e2:SetTarget(s.atktg)
  e2:SetOperation(s.atkop)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--(1) Take control
function s.tcfilter(c)
  return c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.tctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.tcfilter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
  local g=Duel.SelectTarget(tp,s.tcfilter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.tcop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc:IsRelateToEffect(e) or not tc:IsFaceup() or Duel.GetControl(tc,tp,PHASE_END,1)==0 then return end
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
--(2) Lose ATK
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) 
  and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local g1=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
  local g2=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  if #g1>0 and #g2>0 then
    local atklost=#g2*200
    local atkgain=0
    for sc1 in aux.Next(g1) do
      local atk=sc1:GetAttack()
      atkgain=atkgain+math.min(atk,atklost)
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
      e1:SetValue(-atklost)
      sc1:RegisterEffect(e1)
    end
    for sc2 in aux.Next(g2) do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
      e1:SetValue(atkgain)
      sc2:RegisterEffect(e1)
    end
  end
end