if not aux.NetherseaProcedure then
	aux.NetherseaProcedure = {}
	Nethersea = aux.NetherseaProcedure
end

if not Nethersea then
	Nethersea = aux.NetherseaProcedure
end

--Card name variable
CARD_NETHERSEA_FOUNDER       = 400100100
CARD_NETHERSEA_PREDATOR      = 400100200
CARD_NETHERSEA_SPEWER        = 400100300
CARD_NETHERSEA_BRANDGUIDER   = 400100400
CARD_NETHERSEA_SWARMCALLER   = 400100500
CARD_NETHERSEA_REEFBREAKER   = 400100600
CARD_ENDSPEAKER              = 400100700
CARD_ENDSPEAKER_WILLOFWEMANY = 400100800
CARD_NETHERSEA_COMMUNICATION = 400100900
CARD_NETHERSEA_APPROACHING   = 400101000
CARD_NETHERSEA_HIVEMIND      = 400101100
CARD_NETHERSEA_EVOLUTION     = 400101200 

--Archetype code
SET_NETHERSEA = 0x259

--Flag Check
REGISTER_FLAG_WEMANY = 400100000

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
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function Nethersea.GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
    local id=e:GetHandler():GetOriginalCode()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,id+10)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

function Nethersea.QuickTributeProc(c)
	--summon with nethersea card on field or s/t
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_HAND+LOCATION_SZONE,0)
	e0:SetTarget(aux.AND(aux.TargetBoolFunction(Card.IsSetCard,SET_NETHERSEA),aux.NOT(aux.TargetBoolFunction(Card.IsCode,c:GetOriginalCode()))))
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
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
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		Duel.Summon(tp,c,true,nil,1)
	else
		Duel.MSet(tp,c,true,nil,1)
	end
end

function Nethersea.WeManyDontAskMoreThanOnce(tp,e,f)
	if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY)>0) then 
		if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY) ==  Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
		else
			Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,0,0,1) 
		end
		return false
	end
	Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,0,0,1) 
	
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