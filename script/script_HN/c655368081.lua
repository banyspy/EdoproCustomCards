--HN Goddess of Fate Purple Heart
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),2,nil,s.matcheck)
  --(1) Special Summon
  HN.LinkReviveOtherOnSummon(c,id)
  --(2) Cannot activate
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetCode(EFFECT_CANNOT_ACTIVATE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(0,1)
  e2:SetValue(s.calimit)
  e2:SetCondition(s.cacon)
  c:RegisterEffect(e2)
end
--Link Summon
function s.matcheck(g,lc)
  return g:IsExists(s.matfilter,1,nil)
end
function s.matfilter(c)
  return c:IsSetCard(SET_HN) and HN.HasNeptuneInName(c)
end
--(1) Special Summon
--Already handled by BankkyzaAux File
--(2) Cannot activate
function s.calimit(e,re,tp)
  return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsImmuneToEffect(e)
end
function s.cacon(e,tp,eg,ep,ev,re,r,rp)
  local tp=e:GetHandlerPlayer()
  local lg=e:GetHandler():GetLinkedGroup()
  local tc=Duel.GetAttacker()
  local bc=Duel.GetAttackTarget()
  if not bc then return false end
  if bc:IsControler(1-tp) then bc=tc end
  return bc:IsFaceup() and bc:IsSetCard(SET_HN) and (bc:IsType(TYPE_XYZ) or bc:IsType(TYPE_LINK)) and bc:IsControler(tp) and lg:IsContains(bc)
end