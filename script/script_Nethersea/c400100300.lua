--Nethersea Spewer
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Tribute 1 "Nethersea" card from hand or field except this card, and if you do, destroy 1 card on the field or 1 "Nethersea" monster from your deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.handefftarget)
	e1:SetOperation(s.handeffoperation)
	c:RegisterEffect(e1)
	--Can attack all monsters
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Banish a card when another "Nethersea "monster is summoned
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e3:SetCondition(s.rmvcon)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	
	Nethersea.GenerateToken(c)
end
function s.tributecheck(c,tp)
	return Nethersea.NetherseaCardOrWQ(c) and not c:IsCode(id) and
	 (c:IsReleasableByEffect() or Nethersea.WorkaroundTributeSTinHandCheck(c,tp))
end
function s.desfilter(c)
	return (c:IsLocation(LOCATION_ONFIELD)) or ( Nethersea.NetherseaCardOrWQ(c) and c:IsLocation(LOCATION_DECK))
end
function s.handefftarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tributecheck,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) 
	and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD+LOCATION_DECK,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.handeffoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.tributecheck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,tp)
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
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD+LOCATION_DECK,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	end
end
function s.cfilter(c,tp)
	return Nethersea.NetherseaMonsterOrWQ(c) and c:IsControler(tp)
end
function s.rmvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end