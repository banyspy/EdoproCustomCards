--Nethersea Founder
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	--Attribute and race cannot be changed as rule
	Nethersea.CannotChangeAttributeRace(c)
	--spsummon limit
	Nethersea.SpecialSummonLimit(c)
	-- Search 1 "Nethersea" card or water aqua monster, then tribute 1 "Nethersea" card or water aqua monster from hand or field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.handefftarget)
	e1:SetOperation(s.handeffoperation)
	c:RegisterEffect(e1)
	--cannot be destroyed by card effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--cannot be banished by card effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	c:RegisterEffect(e3)
	--Negate the effects of monsters that battle your WATER Aqua monsters
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--Adjust itself to apply the negation effect right away
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_BE_BATTLE_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(function(e) Duel.AdjustInstantly(e:GetHandler()) end)
	c:RegisterEffect(e5)

	Nethersea.GenerateToken(c)
end
s.listed_names={CARD_UMI}
function s.tributecheck(c,tp)
	return Nethersea.NetherseaCardOrWQ(c) and (c:IsReleasableByEffect() or Nethersea.WorkaroundTributeSTinHandCheck(c,tp))
end
function s.thfilter(c)
	return Nethersea.NetherseaCardOrWQ(c) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.handefftarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
	and Duel.IsExistingMatchingCard(s.tributecheck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	--Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,1)
end
function s.handeffoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		local sg=Group.CreateGroup()
		sg:Merge(g)
		sg:AddCard(c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g=Duel.SelectMatchingCard(tp,s.tributecheck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,sg,tp)
		sg:DeleteGroup()
		if #g>0 then 
			--Same workaround as the above
			--Since they can't be tribute for some reason due to game said so, we need to workaround by give REASON_RULE to force it
			local tc = g:GetFirst()
			if tc:IsSpellTrap() and tc:IsLocation(LOCATION_HAND) then
				Duel.Release(g,REASON_RULE+REASON_EFFECT)
			else
				Duel.Release(g,REASON_EFFECT)
			end
		end
	end
end
function s.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end
function s.distg(e,c)
	local bc=c:GetBattleTarget()
	if c:IsRelateToBattle() and bc and bc:IsControler(e:GetHandlerPlayer())
		and bc:IsFaceup() and Nethersea.NetherseaMonsterOrWQ(bc) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		return true
	end
	return false
end
