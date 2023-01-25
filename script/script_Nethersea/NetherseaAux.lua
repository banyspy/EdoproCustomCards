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

function Nethersea.WeManyDontAskMoreThanOnce(tp,e,f)
	if(Duel.GetFlagEffect(0,REGISTER_FLAG_WEMANY)>0) then 
		if(Duel.GetFlagEffect(0,REGISTER_FLAG_WEMANY) ==  Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(0,REGISTER_FLAG_WEMANY)
		else
			Duel.RegisterFlagEffect(0,REGISTER_FLAG_WEMANY,0,0,1) 
		end
		return false
	end
	Duel.RegisterFlagEffect(0,REGISTER_FLAG_WEMANY,0,0,1) 
	
	if(Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
		Duel.ResetFlagEffect(0,REGISTER_FLAG_WEMANY)
	end

	return true
end