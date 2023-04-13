--HN Goddess of Fertility Green Heart
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
  --(2) Cannot negate
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_CANNOT_INACTIVATE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetValue(s.efilter)
  c:RegisterEffect(e2)
end
--Link Summon
function s.matcheck(g,lc)
  return g:IsExists(s.matfilter,1,nil)
end
function s.matfilter(c)
  return c:IsSetCard(SET_HN) and HN.HasVertInName(c)
end
--(1) Special Summon
--Already handled by BankkyzaAux File
--(2) Cannot negate
function s.efilter(e,ct)
  local p=e:GetHandlerPlayer()
  local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
  local tc=te:GetHandler()
  local lg=e:GetHandler():GetLinkedGroup()
  return p==tp and te:IsActiveType(TYPE_MONSTER) and tc:IsSetCard(SET_HN) and (tc:IsType(TYPE_XYZ) or tc:IsType(TYPE_LINK)) and lg:IsContains(tc)
end