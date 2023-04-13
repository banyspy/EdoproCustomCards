--HN Leanbox Nation
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:SetUniqueOnField(1,0,id)
  --(1) Search
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --(2) Second attack
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_BATTLE_DESTROYING)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.sacon)
  e2:SetTarget(s.satg)
  e2:SetOperation(s.saop)
  c:RegisterEffect(e2)
end
s.listed_names={99980030}
--(1) Search
function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
  if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
  end
end
--(2) Second attack
function s.sacon(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  return a:IsControler(tp) and a:IsSetCard(SET_HN) and a:IsType(TYPE_XYZ) and a:CanChainAttack() and a:GetBattleTarget():IsControler(1-tp)
end
function s.satg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.saop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  local tc=Duel.GetAttacker()
  if c:IsRelateToEffect(e) and tc:IsRelateToBattle() and tc:IsFaceup() then
    Duel.ChainAttack()
  end
end