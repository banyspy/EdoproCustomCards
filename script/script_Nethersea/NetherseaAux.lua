if not aux.NetherseaProcedure then
	aux.NetherseaProcedure = {}
	Nethersea = aux.NetherseaProcedure
end

if not Nethersea then
	Nethersea = aux.NetherseaProcedure
end

--Card name variable
CARD_NETHERSEA_FOUNDER       = 655360101
CARD_NETHERSEA_PREDATOR      = 655360102
CARD_NETHERSEA_SPEWER        = 655360103
CARD_NETHERSEA_BRANDGUIDER   = 655360104
CARD_NETHERSEA_SWARMCALLER   = 655360105
CARD_NETHERSEA_REEFBREAKER   = 655360106
CARD_ENDSPEAKER              = 655360107
CARD_ENDSPEAKER_WILLOFWEMANY = 655360108
CARD_NETHERSEA_COMMUNICATION = 655360109
CARD_NETHERSEA_APPROACHING   = 655360110
CARD_NETHERSEA_HIVEMIND      = 655360111
CARD_NETHERSEA_EVOLUTION     = 655360112 

--Archetype code
SET_NETHERSEA = 0xb11

--Flag Check
REGISTER_FLAG_WEMANY = 655360100

function Nethersea.NetherseaMonsterOrWQ(c)
	return c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER)
end

function Nethersea.NetherseaCardOrWQ(c)
	return c:IsCode(CARD_UMI) or (c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER))
end

function Nethersea.GenerateToken(c)
    --token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),4))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,{c:GetOriginalCode(),4})
	e1:SetTarget(Nethersea.GenerateTokenTarget)
	e1:SetOperation(Nethersea.GenerateTokenOperation)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(Nethersea.GenerateTokenConditionToNotRepeatAsk)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_RELEASE)
    c:RegisterEffect(e3)
end
function Nethersea.GenerateTokenConditionToNotRepeatAsk(e)
    return not e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function Nethersea.GenerateTokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local id=e:GetHandler():GetOriginalCode()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,Nethersea.TokenID(id),SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function Nethersea.GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
    local id=e:GetHandler():GetOriginalCode()
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,Nethersea.TokenID(id),SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,Nethersea.TokenID(id))
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		Debug.Message(Nethersea.TokenID(id))
		--Cannot Special Summon monsters except WATER Aqua/Thunder/Fish/Sea serpent
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		--Clock Lizard check
		local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	end
end

function Nethersea.TokenID(id)
	return 655360100+((id-655360100)*20)
end

function Nethersea.QuickTributeProc(c)
	--summon with nethersea card on field or s/t
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_HAND+LOCATION_ONFIELD,0)
	e0:SetTarget(aux.AND(aux.OR(aux.TargetBoolFunction(Card.IsCode,CARD_UMI),aux.AND(aux.TargetBoolFunction(Card.IsRace,RACE_AQUA),aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))),aux.NOT(aux.TargetBoolFunction(Card.IsCode,c:GetOriginalCode()))))
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,{c:GetOriginalCode(),0})
	e1:SetTarget(Nethersea.QuickTributeProcTarget)
	e1:SetOperation(Nethersea.QuickTributeProcOperation)
	c:RegisterEffect(e1)
end
function Nethersea.QuickTributeProcTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function Nethersea.QuickTributeProcOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	--Workaround Spell/Trap sent to GY before choose to tribute if you activate quick tribute as chain link 1
	--Make Spell/trap stuck on the field until monster summon
	local g=Duel.GetMatchingGroup(Nethersea.WorkaroundPreventSTtoGYFilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if  ((Duel.GetCurrentChain(true))==1) and (#g>0)then
		local tg=g:GetFirst()
		for tg in aux.Next(g) do
			tg:CancelToGrave()
			local e1=Effect.CreateEffect(tg)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SUMMON)
			e1:SetRange(LOCATION_SZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetOperation(Nethersea.WorkaroundSTtoGraveBeforeTributeOperation)
			tg:RegisterEffect(e1)
		end
	end
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		Duel.Summon(tp,c,true,nil,1)
	else
		Duel.MSet(tp,c,true,nil,1)
	end
end

function Nethersea.WorkaroundPreventSTtoGYFilter(c)
	return c:IsCode(CARD_UMI) and c:IsSpellTrap() and not c:IsType(TYPE_CONTINUOUS|TYPE_FIELD|TYPE_EQUIP)
end

function Nethersea.WorkaroundSTtoGraveBeforeTributeOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

function Nethersea.WeManyDontAskMoreThanOnce(tp,e,f)
	if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY)>0) then 
		if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY) ==  Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
		else
			Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,RESET_PHASE+PHASE_END,0,1) 
		end
		return false
	end
	Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,RESET_PHASE+PHASE_END,0,1) 
	
	if(Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
		Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
	end

	return true
end

function Nethersea.ResetWeManyFlag(tp)
	Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
end

--This workaround is because apparently IsReleasable() and IsReleasableByEffect() always return false for spell/trap in hand
--So the clostest checking is if it's spell/trap in hand, and if the monster that activated in hand can be tributed
--If monster that also in hand can be tributed, spell/trap in hand also likely can be tributed too
--or if player is not affected by thing like masked of restricted or fog king
--It isn't perfect but it's what can be do, for now
function Nethersea.WorkaroundTributeSTinHandCheck(c,tp)
	return c:IsSpellTrap() and c:IsLocation(LOCATION_HAND)
	and (Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_HAND,0,1,nil) or Duel.IsPlayerCanRelease(tp))
end

--spsummon limit
function Nethersea.SpecialSummonLimit(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
	c:RegisterEffect(e1)
end

--Also treated as "Umi"
function Nethersea.AlsoTreatedAsUmi(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(CARD_UMI)
	c:RegisterEffect(e1)
end

--Attribute and race cannot be changed as rule
function Nethersea.CannotChangeAttributeRace(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetCode()&EFFECT_ADD_RACE==EFFECT_ADD_RACE end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetValue(function(e,te) return te:GetCode()&EFFECT_REMOVE_RACE==EFFECT_REMOVE_RACE end)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetValue(function(e,te) return te:GetCode()&EFFECT_CHANGE_RACE==EFFECT_CHANGE_RACE end)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetValue(function(e,te) return te:GetCode()&EFFECT_ADD_ATTRIBUTE==EFFECT_ADD_ATTRIBUTE end)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetValue(function(e,te) return te:GetCode()&EFFECT_REMOVE_ATTRIBUTE==EFFECT_REMOVE_ATTRIBUTE end)
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetValue(function(e,te) return te:GetCode()&EFFECT_CHANGE_ATTRIBUTE==EFFECT_CHANGE_ATTRIBUTE end)
	c:RegisterEffect(e6)
end
