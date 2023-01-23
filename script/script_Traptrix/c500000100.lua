--Traptrix Dracofly
local s,id=GetID()
function s.initial_effect(c)
	--Unaffected by "Hole" normal trap cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--summon effect from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--summon other when self summon
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,1})
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--set
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.igncon)
	e6:SetTarget(s.trtg)
	e6:SetOperation(s.trop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e7:SetCondition(s.quickcon)
	c:RegisterEffect(e7)
end
s.listed_series={0x4c,0x89,0x108a}
function s.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and (c:IsSetCard(0x4c) or c:IsSetCard(0x89))
end
function s.summonfilter(c)
	return c:IsSetCard(0x108a) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(s.summonfilter,tp,LOCATION_HAND,0,nil)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg1 = Duel.GetMatchingGroup(s.summonfilter,tp,LOCATION_HAND,0,nil)
	if #sg1>0 and (Duel.GetLocationCount(tp,LOCATION_MZONE))>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sg2=sg1:Select(tp,1,1,nil)
		Duel.Summon(tp,sg2:GetFirst(),true,nil)
	end
	c:CompleteProcedure()
end
function s.checkfilter(c)
	return c:IsSetCard(0x108a) and c:IsType(TYPE_MONSTER)
end
function s.igncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.checkfilter,tp,LOCATION_MZONE,0,e:GetHandler())==0
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.checkfilter,tp,LOCATION_MZONE,0,e:GetHandler())>0
end
function s.tgfilter(c)
	--local sc = c:AssumeProperty(TYPE_TRAP,nil)
	return c:IsFaceup() and c:IsMonster() and (c:IsCanTurnSet() or c:IsType(TYPE_LINK))
end
function s.tgfilter2(c,effect)
	return c:IsFaceup() and c:IsMonster() and (c:IsCanTurnSet() or c:IsType(TYPE_LINK)) and not c:IsImmuneToEffect(effect)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		--if not Duel.CanPlayerSetSpellTrap(tp) then return end
		return (Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) and 
		Duel.GetLocationCount(tp,LOCATION_SZONE) > 1 ) or
		(Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) and 
		Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE) > 0) end
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	--if not Duel.CanPlayerSetSpellTrap(tp) then return end
	local c = e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.tgfilter2,tp,LOCATION_MZONE,0,e:GetHandler(),e)
	local g2=Duel.GetMatchingGroup(s.tgfilter2,tp,0,LOCATION_MZONE,e:GetHandler(),e)
	local sg=Group.CreateGroup()
	if((#g1)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE) > 1 ) 
	then sg:Merge(g1) end
	if((#g2)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 and Duel.GetLocationCount(1-tp,LOCATION_SZONE) > 0)
	then sg:Merge(g2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=sg:Select(tp,1,1,nil)
	if #g>0 then
		local g1 = g:GetFirst()
        Duel.MoveToField(g1,tp,g1:GetOwner(),LOCATION_SZONE,POS_FACEDOWN,true)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP)
		g1:RegisterEffect(e1)
		Duel.MoveToField(c,tp,c:GetOwner(),LOCATION_SZONE,POS_FACEDOWN,true)
		local e2=e1:Clone()
		c:RegisterEffect(e2)
	end
end