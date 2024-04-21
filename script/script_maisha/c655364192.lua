--Unnamed Determination
--scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
	--Set this card
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_GRAVE)
	e7:SetCountLimit(1,{id,1})
	e7:SetHintTiming(0,TIMING_MAIN_END|TIMING_END_PHASE)
	e7:SetCost(aux.bfgcost)
	e7:SetTarget(s.shftg)
	e7:SetOperation(s.shfop)
	c:RegisterEffect(e7)
	--Can be activated from the hand
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,4))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(function (e)
		local p=Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_ONFIELD,0)
		local o=Duel.GetFieldGroupCount(1-e:GetHandlerPlayer(),LOCATION_ONFIELD,0)
		return o>p
	end)
	c:RegisterEffect(e0)
end
s.listed_names={655364181}
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.dmtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.fmtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		e:SetCategory(CATEGORY_EQUIP)
		s.dmtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK)
		s.fmtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.dmop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.fmop(e,tp,eg,ep,ev,re,r,rp) end
end

function s.dmfilter(c)
	return c:ListsCode(655364181) and c:IsAbleToGrave()
end
function s.dmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil,c,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,3,0,0)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dmfilter,tp,LOCATION_DECK,0,nil,c,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end

function s.pfmfilter(c)
	return c:ListsCode(655364181) and c:IsAbleToGrave()
end
function s.fmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=Duel.GetMatchingGroup(s.pfmfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local og=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return 
		#pg>0 and #og>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,pg+og,2,0,0)
end
function s.fmop(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetMatchingGroup(s.pfmfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local og=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	
	local sg=Duel.SelectMatchingCard(tp,s.pfmfilter,tp,LOCATION_ONFIELD,0,1,math.max(math.min(#pg,#og),1),e:GetHandler())
	if #sg>0 then
		Duel.HintSelection(sg,true)
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local tg=og:FilterSelect(1-tp,Card.IsAbleToGrave,#sg,#sg,nil)
		if #tg>0 then Duel.SendtoGrave(tg,REASON_RULE,PLAYER_NONE,1-tp) end
	end
end

--Set self
function s.tdfilter(c)
	return c:ListsCode(655364181) and c:IsAbleToDeck() and not c:IsCode(id)
	and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.shftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,nil) end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.shfop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,5,5,nil)
	if #tg>0 then
		Duel.HintSelection(tg,true)
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
		if Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end