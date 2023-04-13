--HN Goddess of Prosperity Black Heart
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
  --(2) Indes by battle and no damage
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(s.indtg)
  e2:SetValue(1)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
  c:RegisterEffect(e3)
end
--Link Summon
function s.matcheck(g,lc)
  return g:IsExists(s.matfilter,1,nil)
end
function s.matfilter(c)
  return c:IsSetCard(SET_HN) and HN.HasNoireInName(c)
end
--(1) Special Summon
--Already handled by BankkyzaAux File
--(2) Indes by battle and no damage
function s.indtg(e,c)
  local lg=e:GetHandler():GetLinkedGroup()
  return c:IsFaceup() and c:IsSetCard(SET_HN) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)) and lg:IsContains(c) 
end