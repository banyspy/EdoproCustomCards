-- Pyrostar Reloader
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --Activate
	local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- choose action
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
    -- tohand
	local e3=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND+CATEGORY_SEARCH,
		functg=s.thtg,
		funcop=s.thop})
	c:RegisterEffect(e3)
end
function s.cfilter(c,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsPreviousControler(tp)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.addtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.shftg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return (b1 or b2 or b3) and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		s.addtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK)
		s.shftg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.addop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.spop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==3 then s.shfop(e,tp,eg,ep,ev,re,r,rp) end
end
function s.addfilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and s.CheckFlag(tp,1) end
    s.RegisterFlagForTime(tp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and s.CheckFlag(tp,2)
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
    s.RegisterFlagForTime(tp,2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.shffilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsAbleToDeck()
end
function s.shftg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.shffilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>=3 and s.CheckFlag(tp,4) end
    s.RegisterFlagForTime(tp,4)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
end
function s.shfop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.shffilter,tp,LOCATION_GRAVE,0,nil)
    if not (#g>=3) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=g:Select(tp,3,3,false,nil)
	if #tg>0 then
        Duel.HintSelection(tg,true)
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	    local g=Duel.GetOperatedGroup()
	    if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	end
end

function s.RegisterFlagForTime(tp,num)
    for i=1,num do
        Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    end
end
function s.CheckFlag(tp,num)
    return Duel.GetFlagEffect(tp,id)&num==0
end

function s.thfilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end