-- ProjektStarBlast Serialization
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Set up to spell/trap effect that activated this turn
	local e1,e2=ProjektStarBlast.CreateActivateDiscardEff({
		handler=c,
		handlerid=id,
		--category=CATEGORY_TOHAND,
		functg=s.tdtg,
		funcop=s.tdop
	})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	ProjektStarBlast.CreateShuffleAddEff(c,id)
end
s.listed_names={CARD_PROJEKTSTARBLAST_KIANA}
s.listed_series={SET_PROJEKTSTARBLAST}
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local place = Duel.IsExistingMatchingCard(s.placeKiana,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local active = Duel.IsPlayerCanDraw(tp,1) and
		Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,e:GetHandler())	
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		local m=3
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then m=5 end
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,m,PLAYER_ALL,LOCATION_GRAVE|LOCATION_REMOVED)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.placeKiana(c)
	return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) and not c:IsForbidden()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local tc=Duel.SelectMatchingCard(tp,s.placeKiana,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then 
			if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
		end
	elseif op==2 then
		local m=3
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then m=5 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_GRAVE|LOCATION_REMOVED,1,m,c)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
			local sg=Duel.GetOperatedGroup()
			if sg:IsExists(s.sfilter,1,nil,tp) then Duel.ShuffleDeck(tp) end
			if sg:IsExists(s.sfilter,1,nil,1-tp) then Duel.ShuffleDeck(1-tp) end
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.sfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(tp)
end