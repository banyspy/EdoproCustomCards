--Counterattack the Pirate
--Script by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
    e5:SetHintTiming(TIMING_DRAW_PHASE,0)
	e5:SetType(EFFECT_TYPE_ACTIVATE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e5:SetCondition(function(e,tp) return (Duel.GetTurnPlayer()==tp and not e:GetHandler():HasFlagEffect(id)) end)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFlagEffect(1-tp,655369311)<=0 or not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
    Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,0,0)
end