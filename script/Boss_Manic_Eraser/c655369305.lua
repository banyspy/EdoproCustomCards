--Vulcanizer
--Script by bankkyza

local s,id=GetID()
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
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local sdg=Duel.GetMatchingGroup(aux.TRUE,tp,0x7f,0,nil)
        Duel.DisableShuffleCheck()
		Duel.SendtoDeck(sdg,nil,-2,REASON_RULE)
	    
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		Duel.Hint(HINT_CARD,0,id)

        if c:GetPreviousLocation()==LOCATION_HAND then
		    Duel.Draw(tp,1,REASON_RULE)
	    end

		--Spawn Manic Eraser
        local ManicEraser=Duel.CreateToken(tp,655369301)
        Duel.SpecialSummon(ManicEraser,0,tp,tp,true,true,POS_FACEUP)

		--Change LP to 4.8 Million
		Duel.SetLP(tp,48000,REASON_RULE)

		for i=1,10 do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,i+5))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetValue(s.val1)
			e1:SetReset(RESET_PHASE+PHASE_END,i*2)
			Duel.RegisterEffect(e1,tp)
		end
		--Negate cheese card
		local code={30748475,24207889,27279764}

		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_ALL,LOCATION_ALL)
		e1:SetLabel(code)
		e1:SetTarget(s.distg)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
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

function s.val1(e,re,dam,r,rp,rc)
	return dam/2
end

function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local z=Duel.GetMZoneCount(tp)
	z=math.min(3,z)
	local round=Duel.GetFlagEffect(tp,id)
	local SummonId= ( (round-1) % 3 ) + 655369302
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
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end