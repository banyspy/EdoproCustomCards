if not aux.NetherseaProcedure then
	aux.NetherseaProcedure = {}
	Nethersea = aux.NetherseaProcedure
end

if not Nethersea then
	Nethersea = aux.NetherseaProcedure
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
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,0x259,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function Nethersea.GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
    local id=e:GetHandler():GetOriginalCode()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+10,0x259,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,id+10)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end