--Vulcanizer
--Script by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0xff)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ADJUST)
		ge2:SetCountLimit(1)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
	s[1]=0
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local sdg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
        Duel.DisableShuffleCheck()
		Duel.SendtoDeck(sdg,nil,-2,REASON_RULE)
	    
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.Hint(HINT_CARD,0,id)

        if c:GetPreviousLocation()==LOCATION_HAND then
		    Duel.Draw(tp,1,REASON_RULE)
	    end

		--Spawn Manic Eraser
        local ManicEraser=Duel.CreateToken(tp,655369302)
        Duel.SpecialSummon(ManicEraser,0,tp,tp,true,true,POS_FACEUP)

		--Change LP to 4.8 Million
		Duel.SetLP(tp,48000,REASON_RULE)

		--Function that manage about Damage Reduction Stack
		s.DamageReductionStackManager(e,tp,eg,ep,ev,re,r,rp)
		
		--Negate cheese card
		local code={30748475,24207889,27279764}

		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		e1:SetLabel(code)
		e1:SetTarget(s.distg)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.GlobalEffect()
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabel(code)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		Duel.RegisterEffect(e3,tp)

		--Cannot lose except by LP to 0
		local r1=Effect.GlobalEffect()
        r1:SetType(EFFECT_TYPE_FIELD)
        r1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_PLAYER_TARGET)
        r1:SetCode(EFFECT_CANNOT_LOSE_DECK)
        r1:SetTargetRange(1,0)
        r1:SetValue(1)
        Duel.RegisterEffect(r1,tp)
        local r2=r1:Clone()
        r2:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
        Duel.RegisterEffect(r2,tp)
        local r3=r1:Clone()
        r3:SetCode(EFFECT_CANNOT_LOSE_LP)
        r3:SetCondition(function() return win==false end)
        Duel.RegisterEffect(r3,tp)

		--Special Summon Minions
		local e4=Effect.GlobalEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
		e4:SetOperation(s.ssop)
		Duel.RegisterEffect(e4,tp)
    end
end

function s.distg(e,c)
	return c:IsOriginalCodeRule(e:GetLabel())
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOriginalCodeRule(e:GetLabel())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local z=Duel.GetMZoneCount(tp)
	z=math.min(2,z)--2 Monster or up to the empty zones
	local round=Duel.GetTurnCount(tp)
	local SummonId= ( (round-1) % 3 ) + 655369303 -- Rotate between 3 monsters
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then z=1 end

	for i=1,z do
		if Duel.IsPlayerCanSpecialSummonMonster(tp,SummonId,nil,nil,nil,nil,nil,nil,nil,POS_FACEUP_DEFENSE) then
			local Summon=Duel.CreateToken(tp,SummonId)
        	Duel.SpecialSummonStep(Summon,0,tp,tp,true,true,POS_FACEUP_DEFENSE)
			--Treat as Effect Monster
			local e1=Effect.CreateEffect(Summon)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetValue(TYPE_MONSTER|TYPE_EFFECT)
			Summon:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end

--Apply Damage Reduction stack
function s.DamageReductionStackManager(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetFlagEffect(e:GetOwnerPlayer(),id)
	--Damage Reduction Stack
	local e1=Effect.GlobalEffect()
	e1:SetDescription(aux.Stringid(id,11-num))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetLabel(num)
	e1:SetTargetRange(1,0)
	e1:SetValue(function (e,re,dam,r,rp,rc) return dam/(2^(6-e:GetLabel())) end)
	Duel.RegisterEffect(e1,tp)
	--If take damage then reduce 1 Dmg Reduction Stack
	--Check at the EP if damage is taken, if true then reset current effects then apply new one
	local e5=Effect.GlobalEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetLabel(num)
	e5:SetLabelObject(e1)
	e5:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==1-tp and s[tp]>0 end)
	e5:SetOperation(s.CheckReduceStack)
	Duel.RegisterEffect(e5,tp)
end
--Apply new effect that update the Flag value
--This is useful for Reduction Stack number on the information bar
function s.CheckReduceStack(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Debug.Message("Manic Eraser Damage Reduction Stack is reduced to "..6-Duel.GetFlagEffect(e:GetOwnerPlayer(),id).." stacks!")
	s.clear(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()<6 then
		s.DamageReductionStackManager(e,tp,eg,ep,ev,re,r,rp)
	else
		--Show that there are no Damage Stack Reduction left
		local e1=Effect.GlobalEffect()
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
	end
	e:Reset()
end