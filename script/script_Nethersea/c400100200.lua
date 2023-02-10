--Nethersea Predator
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Tribute 1 "Nethersea" card from hand or field except this card, and if you do, ss "Nethersea" monster from hand or GY except tributed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.handefftarget)
	e1:SetOperation(s.handeffoperation)
	c:RegisterEffect(e1)
	--cannot be targeted by your opponent card effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Once per turn, negate your opponent attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	
	Nethersea.GenerateToken(c)
end
function s.handeffspfilter(c,e,tp)
	return Nethersea.NetherseaMonsterOrWQ(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tributechecktarget(c,e,tp)
	return Nethersea.NetherseaCardOrWQ(c) and (c:IsReleasableByEffect() or Nethersea.WorkaroundTributeSTinHandCheck(c,tp))
	and Duel.IsExistingMatchingCard(s.handeffspfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
function s.tributecheckoperation(c,tp)
	return Nethersea.NetherseaCardOrWQ(c) and (c:IsReleasableByEffect() or Nethersea.WorkaroundTributeSTinHandCheck(c,tp))
end
function s.handefftarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			return Duel.IsExistingMatchingCard(s.tributechecktarget,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp)
		else
			return Duel.IsExistingMatchingCard(s.tributechecktarget,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp)
		end
	 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.handeffoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		g=Duel.SelectMatchingCard(tp,s.tributecheckoperation,tp,LOCATION_MZONE,0,1,1,c,tp)
	else
		g=Duel.SelectMatchingCard(tp,s.tributecheckoperation,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
	end
	if #g>0 then
		--Same workaround as the above
		--Since they can't be tribute for some reason due to game said so, we need to workaround by give REASON_RULE to force it
		local tc = g:GetFirst()
		if tc:IsSpellTrap() and tc:IsLocation(LOCATION_HAND) then
			if not (Duel.Release(g,REASON_RULE+REASON_EFFECT)>0) then return end
		else
			if not (Duel.Release(g,REASON_EFFECT)>0) then return end
		end
		
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sp=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.handeffspfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,g,e,tp)
		if #sp>0 then Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP) end
	end
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetAttacker():IsControler(1-tp) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateAttack()
end
