-- ProjektStarBlast Resources Gathering
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Plus sign banish and zone ban
	local e1,e2=ProjektStarBlast.CreateActivateDiscardEff({
		handler=c,
		handlerid=id,
		--category=CATEGORY_TOHAND,
		functg=s.thtg,
		funcop=s.thop
	})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	ProjektStarBlast.CreateShuffleAddEff(c,id)
end
s.listed_names={CARD_PROJEKTSTARBLAST_KIANA}
s.listed_series={SET_PROJEKTSTARBLAST}
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local place = Duel.IsExistingMatchingCard(s.placeKiana,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local g=Duel.GetDecktopGroup(tp,5)
	local result=g:FilterCount(Card.IsAbleToHand,nil)>0
	local active = result and Duel.IsPlayerCanDiscardDeck(tp,5)
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.addfilter(c)
	return c:IsSetCard(SET_PROJEKTSTARBLAST) and c:IsAbleToHand()
end
function s.placeKiana(c)
	return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) and not c:IsForbidden()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
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
		if not Duel.IsPlayerCanDiscardDeck(tp,5) then return end
		Duel.ConfirmDecktop(tp,5)
		local g=Duel.GetDecktopGroup(tp,5)
		if #g>0 then
			Duel.DisableShuffleCheck()
			if g:IsExists(s.addfilter,1,nil) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=g:FilterSelect(tp,s.addfilter,1,1,nil)
				if sg:GetFirst():IsAbleToHand() then 
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,sg)
					Duel.ShuffleHand(tp)
					g:Sub(sg)
					Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
				else Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
				end
			else
				Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_REVEAL)
				Duel.ShuffleDeck(tp)
			end
		end
	end
end
