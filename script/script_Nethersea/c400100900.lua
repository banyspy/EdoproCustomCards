--Nethersea Communication
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Negate then destroy, possibly summon monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    
    --shuffle and draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,4})
	e2:SetCondition(s.DoNotRepeatAsk)
	e2:SetTarget(s.gravetarget)
	e2:SetOperation(s.graveoperation)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.gravecon)
    c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsSetCard(SET_NETHERSEA) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.gravecon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.DoNotRepeatAsk(e,tp,eg,ep,ev,re,r,rp)
    return not (e:GetHandler():IsLocation(LOCATION_GRAVE))
end
function s.gravefilter(c)
	return c:IsSetCard(SET_NETHERSEA) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,LOCATION_GRAVE+LOCATION_REMOVED,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMatchingGroupCount(s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil) < 3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local tg=Duel.GetOperatedGroup()
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end