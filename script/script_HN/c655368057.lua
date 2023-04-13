--HN Croire, Eden's Oracle
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Additional name
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id)
  e1:SetRange(LOCATION_HAND)
  e1:SetCost(s.ancost)
  e1:SetTarget(s.antg)
  e1:SetOperation(s.anop)
  c:RegisterEffect(e1)
  --(2) Croire, Eden's Oracle
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_DESTROY)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,id+1)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.destg)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)
end
--(1) Additional name
function s.ancost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDiscardable() end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function s.anfilter(c)
  return c:IsType(TYPE_MONSTER) and not c:IsSetCard(SET_HN_CPU) and c:GetLevel()>0
end
function s.antg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.anfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
end
function s.anop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(s.anfilter,tp,LOCATION_MZONE,0,nil)
  local tc=g:GetFirst()
  for tc in aux.Next(g) do
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_SETCODE)
    e1:SetValue(SET_HN_CPU)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
  end
end
--(2) Destroy
function s.desfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN_CPU)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then return false end
  if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
  and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g1=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
  g1:Merge(g2)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
  local tg=g:Filter(Card.IsRelateToEffect,nil,e)
  if tg:GetCount()>0 then
    Duel.Destroy(tg,REASON_EFFECT)
  end
end