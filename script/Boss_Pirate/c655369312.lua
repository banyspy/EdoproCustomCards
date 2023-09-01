--Pirate of the Deadwave
--Script by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Total Immunity
	Boss.TotalImmunity(c)
	--Has no Level
	c:SetStatus(STATUS_NO_LEVEL,true)
    local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(id,2))
	--e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	--e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	c:RegisterEffect(e1)
end
