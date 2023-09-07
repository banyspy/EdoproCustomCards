--DAL Spirit - Sister
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Reveal
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_SEARCH+CATEGORY_TOHAND,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.revtg,
    funcop=s.revop})
  --(2) Gain LP
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_RECOVER)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1,id)
  e2:SetCondition(s.reccon)
  e2:SetTarget(s.rectg)
  e2:SetOperation(s.recop)
  c:RegisterEffect(e2)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=5 
  and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0)
  Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,0,0)
  Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
 local c=e:GetHandler()
  Duel.ConfirmDecktop(1-tp,5)
  local ct=Duel.GetDecktopGroup(1-tp,5):Filter(Card.IsMonster,nil,e,tp)
  Duel.ShuffleDeck(1-tp)
  local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  if ct:GetCount()>0 and g:GetCount()>0 then
    for sc in aux.Next(g) do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    e1:SetValue(ct:GetCount()*100)
    sc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    sc:RegisterEffect(e2)
    end
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
end
--(2) Gain LP
function s.reccon(e)
  local tp=e:GetHandlerPlayer()
  return math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))>0
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local tp=e:GetHandlerPlayer()
  Duel.SetTargetPlayer(tp)
  Duel.SetTargetParam(math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp)))
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
  Duel.Recover(p,d,REASON_EFFECT)
end