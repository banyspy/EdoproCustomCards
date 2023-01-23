--Token March
--scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--Special summon as many tokens as possible to your field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,-2,-2,1,RACE_WARRIOR,ATTRIBUTE_LIGHT)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ft,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ft,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,-2,-2,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	for i=1,ft do
		local token=Duel.CreateToken(tp,id+1)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--Atk/Def = opponent LP
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(Duel.GetLP(1-tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		token:RegisterEffect(e2)
		--Battle protection
	    local e3=Effect.CreateEffect(c)
	    e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	    e3:SetValue(1)
	    token:RegisterEffect(e3)
	    local e4=e3:Clone()
	    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	    token:RegisterEffect(e4)
	end
	Duel.SpecialSummonComplete()
end
