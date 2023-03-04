if not aux.ZodragonProcedure then
	aux.ZodragonProcedure = {}
	Zodragon = aux.ZodragonProcedure
end

if not Zodragon then
	Zodragon = aux.ZodragonProcedure
end

--Archetype code
SET_ZODRAGON = 0xb03

--Variable for Summon Limit Rule
LIMIT_COUNTER = 655360041

function Zodragon.SummonLimit(c)
    --summon cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCost(Zodragon.summoncost)
	e1:SetOperation(Zodragon.summonop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SUMMON_COST)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_FLIPSUMMON_COST)
    c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_NORMALSUMMON,Zodragon.counterfilter)
    Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_SPSUMMON,Zodragon.counterfilter)
    Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_FLIPSUMMON,Zodragon.counterfilter)
end
function Zodragon.counterfilter(c)
	return c:IsSetCard(SET_ZODRAGON)
end
function Zodragon.summoncost(e,c,tp)
	return Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_NORMALSUMMON)==0
    and Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_SPSUMMON)==0
    and Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_FLIPSUMMON)==0
end
function Zodragon.summonop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(LIMIT_COUNTER,15))
	e1:SetTargetRange(1,0)
	e1:SetTarget(Zodragon.summonlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
end
function Zodragon.summonlimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(SET_ZODRAGON)
end