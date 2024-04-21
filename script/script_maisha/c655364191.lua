--Dual Swords of Truth and Deception
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
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.revcon)
	e2:SetTarget(s.revtg)
	e2:SetOperation(s.revop)
	c:RegisterEffect(e2)
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
s.listed_names={655364181,655364188,655364189}
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=s.eqtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.shtg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		e:SetCategory(CATEGORY_EQUIP)
		s.eqtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_TODECK)
		s.shtg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.eqop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.shop(e,tp,eg,ep,ev,re,r,rp) end
end

function s.eqfilter(c,mc,tp)
	return c:IsCode({655364188,655364189}) and c:CheckEquipTarget(mc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
	and (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.rescon(sg)
	return #sg==1 or (
		sg:IsExists(Card.IsCode,1,nil,655364188) and 
		sg:IsExists(Card.IsCode,1,nil,655364189) 
	)
end
function s.eqtgfilter(c,e,tp)
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,c,tp)
	return c:IsCode(655364181) and c:IsFaceup() and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqtgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local sz=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if not (sz>0) then return  end
	local mc=Duel.SelectMatchingCard(tp,s.eqtgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	if not mc then return end
	local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,mc,tp)
	local eq=aux.SelectUnselectGroup(g,e,tp,1,math.min(sz,2),s.rescon,1,tp,HINTMSG_EQUIP)
	if #eq>0 then
		for ec in eq:Iter() do
			Duel.Equip(tp,ec,mc)
		end
	end
end
function s.truthfilter(c)
	return c:IsCode(655364188) and c:IsAbleToDeck()
end
function s.deceptionfilter(c)
	return c:IsCode(655364189) and c:IsAbleToDeck()
end
function s.gfilter(c,tp)
	return (c:IsControler(tp) and (s.truthfilter(c) or s.deceptionfilter(c))) or (c:IsControler(1-tp) and c:IsAbleToDeck())
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local pg=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	local og=Duel.GetMatchingGroup(s.gfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(aux.FaceupFilter(s.truthfilter),tp,LOCATION_ONFIELD,0,1,nil) and
		Duel.IsExistingMatchingCard(aux.FaceupFilter(s.deceptionfilter),tp,LOCATION_ONFIELD,0,1,nil) and
		Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,pg+og,5,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.pgcon(sg)
	return sg:IsExists(Card.IsCode,1,nil,655364188) and sg:IsExists(Card.IsCode,1,nil,655364189) 
end
function s.ogcon(sg)
	return 	sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<=1 and 
			sg:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)<=1 and
			sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
	local pg=Duel.GetMatchingGroup(s.gfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	local ps=aux.SelectUnselectGroup(pg,e,tp,2,2,s.pgcon,1,tp,HINTMSG_TODECK)
	if not ps then return end
	Duel.HintSelection(ps,true)
	Duel.SendtoDeck(ps,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	local og=Duel.GetMatchingGroup(s.gfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil,tp)
	local os=aux.SelectUnselectGroup(og,e,tp,1,3,s.ogcon,1,tp,HINTMSG_TODECK)
	if not os then return end
	Duel.HintSelection(os,true)
	Duel.SendtoDeck(os,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--Set self
function s.revfilter(c,tp)
	return c:IsCode({655364188,655364189}) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
	--and c:GetReasonPlayer()==1-tp
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and e:GetHandler():IsSSetable() end
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SSet(tp,c)
	end
end
