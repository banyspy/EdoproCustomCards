--HN Pudding Buddies
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
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCondition(s.exccon)
  e1:SetTarget(s.exctg)
  e1:SetOperation(s.excop)
  c:RegisterEffect(e1)
end
function s.excconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_HN)
end
function s.exccon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.IsExistingMatchingCard(s.excconfilter,tp,LOCATION_MZONE,0,3,nil)
end
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
  Duel.ConfirmDecktop(tp,3)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()>0 then
    Duel.DisableShuffleCheck()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
    Duel.ShuffleHand(tp)
    g:Sub(sg)
    Duel.SortDecktop(tp,tp,g:GetCount())
  end
end