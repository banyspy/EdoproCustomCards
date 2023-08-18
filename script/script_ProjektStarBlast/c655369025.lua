--Into The Mystery
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Send from deck, extra deck or opponent extra deck to GY
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
	local active = Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK|LOCATION_EXTRA,LOCATION_EXTRA,1,nil)
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)--send from your deck
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)--send from both player extra deck
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.placeKiana(c)
	return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) and not c:IsForbidden()
end
function s.tgcheck(sg,e,tp,mg)
	local rg1,rg2=sg:Split(function(c)return c:IsControler(tp)end,nil)
	return rg1:GetClassCount(Card.GetLocation)==#rg1 and rg2:GetClassCount(Card.GetLocation)==#rg2
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
		Duel.ConfirmCards(tp,Duel.GetFieldGroup(tp,0,LOCATION_EXTRA))
		local rg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_DECK|LOCATION_EXTRA,LOCATION_EXTRA,nil)
		if #rg<=0 then return end
		local sg
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			sg=aux.SelectUnselectGroup(rg,e,tp,1,3,s.tgcheck,1,tp,HINTMSG_TOGRAVE)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			sg=rg:Select(tp,1,1,nil)
		end
		Duel.SendtoGrave(sg,REASON_EFFECT)
		Duel.ShuffleExtra(1-tp)
		rg:DeleteGroup()
		sg:DeleteGroup()
	end
end
