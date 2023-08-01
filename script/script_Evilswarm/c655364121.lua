-- Evilswarm Salamander
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    -- Copy effect of "lswarm" monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
    --Add back to hand and can normal summon it
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(s.retcost)
	e4:SetTarget(s.rettg)
	e4:SetOperation(s.retop)
	c:RegisterEffect(e4)
end
s.listed_name={id}
s.listed_series={SET_LSWARM}
function s.thfilter(c,e,tp)
	return c:IsSetCard(SET_LSWARM) and c:IsMonster() and not c:IsCode(id)
	and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,tp,false,false))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
        local tg=g:GetFirst()
        aux.ToHandOrElse(tg,tp,
        function()
            return tg:IsCanBeSpecialSummoned(e,0,tp,tp,false,false)
        end,
        function()
            Duel.SpecialSummonStep(tg,0,tp,tp,false,false,POS_FACEUP)
			--Cannot Special Summon non-"lswarm" monsters from Extra Deck
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_LSWARM) end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tg:RegisterEffect(e1,true)
			--Clock Lizard check
			local e2=aux.createContinuousLizardCheck(e:GetHandler(),LOCATION_MZONE,function(_,c) return not c:IsSetCard(SET_LSWARM) end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tg:RegisterEffect(e2,true)
			Duel.SpecialSummonComplete()
        end,
        aux.Stringid(id,1))
	end
end
function s.effilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(SET_LSWARM) and c:IsMonster() and c:IsType(TYPE_EFFECT) and aux.SpElimFilter(c,true)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.effilter(chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.effilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.HintSelection(g,true)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetOriginalCode())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
function s.retcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.retfilter(c)
	return c:IsSetCard(SET_LSWARM) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
	--Activation legality
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,0)
end
	--Add 1 "lswarm" monster to hand and can normal summon it
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tg and Duel.SendtoHand(tg,tp,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tg)
		if tg:IsSummonable(true,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Summon(tp,tg,true,nil)
		end
	end
end