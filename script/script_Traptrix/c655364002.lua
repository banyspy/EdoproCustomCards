-- Traptrix Stylidium
-- scripted by bankkyza
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
	--Targeted monster becomes unaffected by other card effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCost(s.reveal)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	c:RegisterEffect(e2)
	--Special Summon a Link monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE,SET_TRAP_HOLE}
function s.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end
function s.reveal(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
end
function s.targetfilter(c)
	return ((c:IsSetCard(SET_TRAPTRIX) and c:IsType(TYPE_MONSTER)) 
	or c:GetType()==TYPE_TRAP) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,0,1,nil) 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Unaffected by other card effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3100)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.immfilter)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.immfilter(e,re)
	return e:GetHandler()~=re:GetOwner()
end
function s.shffilter(c)
	return c:IsAbleToDeck() and (c:IsSetCard(SET_TRAPTRIX) 
	or ( c:GetType()==TYPE_TRAP and (c:IsSetCard({SET_HOLE,SET_TRAP_HOLE})))) 
end
function s.spfilter(c,e,tp,ct,g)
	return c:IsRace(RACE_INSECT|RACE_PLANT) and c:IsType(TYPE_LINK) and c:IsLink(ct)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.shffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if chk==0 then return #nums>0 end --existence of card to summon checked in cost
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.shffilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	local nums={}
	for i=1,#g do
		if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,i,g) then
			table.insert(nums,i)
		end
	end
	if not (#nums>0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local rg=g:Select(tp,ct,ct,nil)
	Duel.HintSelection(rg,true)
	Duel.SendtoDeck(rg,nil,2,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct)
	if #sg>0 then
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local c=e:GetHandler()
			-- Cannot Special Summon monsters from the Extra Deck, except Insect or Plant monsters
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT|RACE_PLANT) end)
			e1:SetTargetRange(1,0)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			-- Lizard check
			aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACE_INSECT|RACE_PLANT) end)
		end
	end
end