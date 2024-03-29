--Nethersea Communication
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Also treated as "Umi"
	Nethersea.AlsoTreatedAsUmi(c)
	-- Add "Nethersea" card or water aqua monster from deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --shuffle and draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
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
s.listed_names={CARD_UMI}
function s.filter(c)
	return Nethersea.NetherseaCardOrWQ(c) and not c:IsCode(id) and c:IsAbleToHand()
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
    return not (e:GetHandler():IsLocation(LOCATION_GRAVE) and (r&REASON_EFFECT)~=0)
end
function s.gravefilter(c)
	return Nethersea.NetherseaCardOrWQ(c) and not c:IsCode(id) and (c:IsAbleToDeck() or c:IsAbleToExtra())
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then 
		return Duel.IsPlayerCanDraw(tp,1) and (Duel.GetMatchingGroupCount(s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil) >= 3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,LOCATION_GRAVE+LOCATION_REMOVED,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1200)
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMatchingGroupCount(s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil) < 3 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tg=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
	Duel.HintSelection(tg,true)
	local rg=tg:Filter(Card.IsFacedown,nil)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local tg=Duel.GetOperatedGroup()
	if tg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=tg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then
			Duel.Recover(p,1200,REASON_EFFECT)
		end
	end
end