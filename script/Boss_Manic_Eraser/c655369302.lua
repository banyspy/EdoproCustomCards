--Manic Eraser Cat
--Script by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Total Immunity
	Boss.TotalImmunity(c)
	--Has no Level
	c:SetStatus(STATUS_NO_LEVEL,true)
    --Opponent can attack over
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e11:SetRange(LOCATION_MZONE)
	e11:SetValue(1)
	c:RegisterEffect(e11)
end
function s.cfilter(c)
	if c:IsFaceup() and c:IsCode(id) --[[or not c:CanAttack()]] then return false end
	local ag,direct=c:GetAttackableTarget()
	return #ag>0 or direct
end
function s.cacon(e)
	return Duel.GetCurrentPhase()>PHASE_MAIN1 and Duel.GetCurrentPhase()<PHASE_MAIN2
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
