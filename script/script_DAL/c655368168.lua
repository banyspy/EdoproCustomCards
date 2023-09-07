--DAL Spirit - Efreet
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Destroy
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_DESTROY+CATEGORY_SEARCH+CATEGORY_TOHAND,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.destg,
    funcop=s.desop})
  --(2) Indes
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e2:SetCountLimit(1)
  e2:SetValue(s.indcon)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--(1) Destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not tc:IsRelateToEffect(e) or Duel.Destroy(tc,REASON_EFFECT)==0 then return end
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
--(2) Indes
function s.indcon(e,re,r,rp)
  return (r&(REASON_BATTLE|REASON_EFFECT))~=0 and rp~=e:GetHandlerPlayer()
end