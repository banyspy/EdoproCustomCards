--Zodragon Cancer
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("ZodragonAux.lua")
function s.initial_effect(c)
	--Activate when attack is declared
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return eg and eg:GetFirst():IsControler(1-tp) end)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Activate in response to opponent effect
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return rp~=tp end)
	c:RegisterEffect(e2)
	--Can be activated from the hand
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
function s.handconfilter(c)
	return c:IsSetCard(SET_ZODRAGON) and c:IsMonster()
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.handconfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,0),RESET_PHASE|PHASE_END,1)
end
function s.etarget(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_ZODRAGON)
end