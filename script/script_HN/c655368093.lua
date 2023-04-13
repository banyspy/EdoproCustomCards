--HN Divine Pudding
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Excavate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.excatg)
  e1:SetOperation(s.excaop)
  c:RegisterEffect(e1)
end
function s.excafilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and c:GetLink()>0
end
function s.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
    local ct=lg:GetSum(Card.GetLink)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct or ct<1 then return false end
    local g=Duel.GetDecktopGroup(tp,ct)
    return g:FilterCount(Card.IsAbleToHand,nil)>0
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thfilter(c)
  return c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.excaop(e,tp,eg,ep,ev,re,r,rp)
  local lg=Duel.GetMatchingGroup(s.excafilter,tp,LOCATION_MZONE,0,c)
  local ct=lg:GetSum(Card.GetLink)
  Duel.ConfirmDecktop(tp,ct)
  local g=Duel.GetDecktopGroup(tp,ct)
  if g:GetCount()>0 then
    local tg=g:Filter(Card.IsAbleToHand,nil)
    if tg:GetCount()>0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local sg=tg:Select(tp,1,1,nil)
      Duel.SendtoHand(sg,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,sg)
    end
    Duel.ShuffleDeck(tp)
    if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) 
    and g:IsExists(Card.IsCode,1,nil,99980290,id) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
      Duel.BreakEffect()
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
      local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
      if hg:GetCount()>0 then
        Duel.SendtoHand(hg,tp,REASON_EFFECT)
        if hg:GetFirst():IsLocation(LOCATION_HAND) then
          Duel.ConfirmCards(1-tp,hg)
        end
      end
    end
  end
end