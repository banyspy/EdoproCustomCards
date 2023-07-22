-- Book of Ultra-Gemini Secrets
-- Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Banish from GY and shuffle upto 3 Gemini and draw 1
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.dtarget)
	e2:SetOperation(s.dactivate)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_GEMINI}
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsType(TYPE_GEMINI) and c:IsAbleToGraveAsCost()
    and ((not c:IsGeminiStatus() and Duel.IsPlayerCanDraw(tp,2)) or (c:IsGeminiStatus() and Duel.IsPlayerCanDraw(tp,3)))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
    if tc:IsGeminiStatus() then 
        e:SetLabel(1) 
    else 
        e:SetLabel(0) 
    end
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
    if e:GetLabel() == 1 then
	    Duel.SetTargetParam(3)
	    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
    else
        Duel.SetTargetParam(2)
	    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.filter(c)
	return c:IsMonster() and c:IsType(TYPE_GEMINI) and c:IsAbleToDeck()
end
function s.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end
function s.dtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.filter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.dactivate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Remove(c,POS_FACEUP,REASON_EFFECT)==0 then return end
    Duel.BreakEffect()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(s.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==#g then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
