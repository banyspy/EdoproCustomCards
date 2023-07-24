-- Amalgam - Polymorph, The Unstable
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
    --Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCountLimit(1,id)
	e2:SetTarget(s.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    --prevent attack target
    local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e3:SetValue(aux.imval1)
	c:RegisterEffect(e3)
    --Gain its Type
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,{id,1})
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e4:SetCondition(function() return Duel.IsMainPhase() end)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={SET_AMALGAM}
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsSetCard,1,false,1,true,c,c:GetControler(),nil,false,e:GetHandler(),SET_AMALGAM)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,false,true,true,c,nil,nil,false,e:GetHandler(),SET_AMALGAM)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.tglimit(e,c)
	return c:GetRace()&e:GetHandler():GetRace()~=0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local rc=c:GetRace()
	if chk==0 then return (~rc&RACE_ALL)~=0 end --Able to activate if there is other race available to choose
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
	local label=Duel.AnnounceRace(tp,1,(~rc&RACE_ALL))
	e:SetLabel(label)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local rc=e:GetLabel()
	if c:GetRace()&rc==0 then
		-- Change monster type
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_RACE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(rc)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
		c:RegisterEffect(e1)
	end
end