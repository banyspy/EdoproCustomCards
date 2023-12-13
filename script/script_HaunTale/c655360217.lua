--Ancient Seal of the HaunTale
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Shuffle "HaunTale" cards and add from Deck to hand.
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_ATTACK+TIMING_BATTLE_START)
    e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    -- Return cards from the GY to the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,0})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.toedtg)
	e2:SetOperation(s.toedop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HAUNTALE}

function s.rtfilter(c)
	return c:IsSetCard(SET_HAUNTALE) and (c:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.thfilter(c)
	return c:IsSetCard(SET_HAUNTALE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.rtfilter,tp,LOCATION_EXTRA+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    if #tg>0 then Duel.HintSelection(tg,true) end
    local rg=tg:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
    Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
    if ct<=0 then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
    if #sg>0 then
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
    end
    tg:Clear()
end

function s.toedfilter(c,pc)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(SET_HAUNTALE) and not c:IsForbidden()
end
function s.toedtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.toedfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
end
function s.toedop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=Duel.SelectMatchingCard(tp,s.toedfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,c)
	local tc=g:GetFirst()
	if tc then
        Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
	end
end