--Ominous Sea
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

		--Spawn Pirate
        local PirateOfTheDeadwave=Duel.CreateToken(tp,655369312)
        Duel.SendtoHand(PirateOfTheDeadwave,nil,REASON_RULE)
		
		--Function that manage about Health showing
		s.CannonAndHealthManager(e,tp,eg,ep,ev,re,r,rp)

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

		--Place Cannon
		s.placecannon(e,tp,eg,ep,ev,re,r,rp)

		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetCountLimit(1)
		e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==1-tp end)
		e2:SetOperation(s.thop)
		Duel.RegisterEffect(e2,tp)
    end
end

function s.placecannon(e,tp,eg,ep,ev,re,r,rp)
	local z=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if z<=0 then return end
	for i=1,z do
		local Cannon=Duel.CreateToken(tp,655369313)
		Duel.MoveToField(Cannon,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Cannon:RegisterFlagEffect(655369313,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(Card.IsOriginalCode,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,nil,655369314) then
		local Counterattack=Duel.CreateToken(1-tp,655369314)
		Duel.SendtoHand(Counterattack,1-tp,REASON_RULE)
		Counterattack:RegisterFlagEffect(655369314,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.ConfirmCards(tp,Counterattack)
	end
end

--Apply Damage Reduction stack
function s.CannonAndHealthManager(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetFlagEffect(e:GetOwnerPlayer(),id)
	local r3=Effect.GlobalEffect()
	r3:SetDescription(aux.Stringid(id,1))
	r3:SetType(EFFECT_TYPE_FIELD)
	r3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    r3:SetCode(EFFECT_CANNOT_LOSE_LP)
    r3:SetCondition(function(e) return Duel.GetFlagEffect(e:GetOwnerPlayer(),id)<6 end)
	r3:SetTargetRange(1,0)
    Duel.RegisterEffect(r3,tp)
	local r4=r3:Clone()
    r4:SetCode(EFFECT_CHANGE_DAMAGE)
	r4:SetValue(0)
    Duel.RegisterEffect(r4,tp)
	local r5=r4:Clone()
    r5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    Duel.RegisterEffect(r5,tp)
	--How many time "Counterattack the Pirate" has to activated left
	local e1=Effect.GlobalEffect()
	e1:SetDescription(aux.Stringid(id,11-num))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	--If "Counterattack the Pirate" is activate
	local e5=Effect.GlobalEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CUSTOM+655369314)
	e5:SetLabelObject(e1)
	e5:SetOperation(s.CheckReduceStack)
	Duel.RegisterEffect(e5,tp)
end
--Apply new effect that update the Flag value
--This is useful for number on the information bar
function s.CheckReduceStack(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	Debug.Message("Only has to counterattack "..6-Duel.GetFlagEffect(e:GetOwnerPlayer(),id).." time!")
	if e:GetLabel()<6 then
		s.CannonAndHealthManager(e,tp,eg,ep,ev,re,r,rp)
	else
		--Show that there are no need to activate "Counterattack" anymore
		local e1=Effect.GlobalEffect()
		e1:SetDescription(aux.Stringid(id,5))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		Duel.RegisterEffect(e1,tp)
	end
	e:Reset()
end