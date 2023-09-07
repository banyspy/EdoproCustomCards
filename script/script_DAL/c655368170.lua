--DAL Spirit - Hermit
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Change to Def Position
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_POSITION+CATEGORY_DEFCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.postg,
    funcop=s.posop})
  --(2) Cannot be battle target
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
  e2:SetCondition(s.cbtcon)
  e2:SetValue(aux.imval1)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--(1) Change to Def Position
function s.posfilter(c)
  return c:IsPosition(POS_FACEUP_ATTACK)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,1,0,0)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc:IsRelateToEffect(e) or Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)==0 then return end
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
  e1:SetValue(0)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
  tc:RegisterEffect(e1)
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
--(2) Cannot be battle target
function s.cbtfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER)
end
function s.cbtcon(e)
  return Duel.IsExistingMatchingCard(s.cbtfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end