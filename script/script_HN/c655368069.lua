--HN Next White
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),5,3)
  c:EnableReviveLimit()
  --(1) Gain additional effect
  --(1.1) Cannot chain
  --(3) Special Summon
  HN.HDDNextCommonEffect(c,id,CARD_HN_HDD_WHITE_HEART)
  --(2) Destroy
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_DESTROY)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_BATTLE_CONFIRM)
  e3:SetCountLimit(1)
  e3:SetCondition(s.descon)
  e3:SetCost(s.descost)
  e3:SetTarget(s.destg)
  e3:SetOperation(s.desop)
  c:RegisterEffect(e3,false,1)
end
s.listed_names={CARD_HN_HDD_WHITE_HEART}
--(2) Destroy
function s.descon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return c:IsRelateToBattle() and bc and bc:IsRelateToBattle()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,bc)
  if chk==0 then return g:GetCount()>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,bc)
  if g:GetCount()>0 then
    Duel.HintSelection(g)
    Duel.Destroy(g,REASON_EFFECT)
  end
end