-- Malefic Sequence
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--act
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--cannot be targeted
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_FZONE,0)
	e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(s.indtg)
	c:RegisterEffect(e5)
    -- recover
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.target)
	e6:SetOperation(s.op)
	c:RegisterEffect(e6)
end
s.listed_series={SET_MALEFIC}
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_MALEFIC) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_MALEFIC)
end
function s.banfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.refilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_MALEFIC) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.banfilter,tp,LOCATION_REMOVED,0,1,nil) 
		and Duel.IsExistingTarget(s.refilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectTarget(tp,s.banfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,1,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g2=Duel.SelectTarget(tp,s.refilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g2,1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ex1,tg1=Duel.GetOperationInfo(0,CATEGORY_TODECK)
	local tc1=tg1:GetFirst()
	local ex2,tg2=Duel.GetOperationInfo(0,CATEGORY_TOHAND)
    local tc2=tg2:GetFirst()
    if tc1:IsRelateToEffect(e) and tc1:IsAbleToDeck() then
		Duel.SendtoDeck(tc1,nil,0,REASON_EFFECT)
		if not tc1:IsType(TYPE_EXTRA) then Duel.ShuffleDeck(tp) end
    end
    if tc2:IsRelateToEffect(e) and tc2:IsAbleToHand() then
        Duel.SendtoHand(tc2,nil,0,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc2)
    end
end