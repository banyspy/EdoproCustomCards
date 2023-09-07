--DAL Metatron - Angel of Extinction
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Return to hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.rthtg)
  e1:SetOperation(s.rthop)
  c:RegisterEffect(e1)
  --(2) Banish
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_REMOVE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCondition(aux.exccon)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.bantg)
  e2:SetOperation(s.banop)
  c:RegisterEffect(e2)
end
s.listed_series={SET_DALSPIRIT}
--(1) Return to hand
function s.rthfilter1(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT) and Duel.IsExistingMatchingCard(s.rthfilter2,tp,0,LOCATION_MZONE,1,c,c:GetAttack())
end
function s.rthfilter2(c,atk)
  return c:IsFaceup() and c:IsAttackBelow(atk) 
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.rthfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.rthfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
  local sg=Duel.GetMatchingGroup(s.rthfilter2,tp,0,LOCATION_MZONE,g:GetFirst(),g:GetFirst():GetAttack())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
    local g=Duel.GetMatchingGroup(s.rthfilter2,tp,0,LOCATION_MZONE,tc,tc:GetAttack())
    Duel.SendtoHand(g,nil,REASON_EFFECT)
  end
end
--(2) Banish
function s.banfilter1(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.banfilter2(c)
  return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local ct=Duel.GetMatchingGroupCount(s.banfilter1,tp,LOCATION_MZONE,0,nil)
  if chk==0 then return ct>0 and Duel.IsExistingTarget(s.banfilter2,tp,0,LOCATION_GRAVE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectTarget(tp,s.banfilter2,tp,0,LOCATION_GRAVE,1,ct,nil)
  Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
  Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end