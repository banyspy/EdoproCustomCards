--Tori-No-Kami Kurohime
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),1,99)
	c:EnableReviveLimit()
	Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add to your hand 1 "Tori-No-Kami" card from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CANNOT_DIS_NEG_INA)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e2:SetTarget(s.thrmtg)
	e2:SetOperation(s.thrmop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TORINOKAMI}
s.listed_card_types={TYPE_SPIRIT}
--s.synchro_nt_required=1
--s.synchro_tuner_required=1
function s.rescon(sg,e,tp,mg)
	local c=e:GetHandler()
	return c:IsSynchroSummonable(sg) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
function s.rescon2(sg,e,tp,mg) -- for cancel
	local c=e:GetHandler()
	return  #sg==0
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPIRIT)
end
function s.summonfilter(c,tp,e)
	return c:IsOriginalCode(id)--Must be actual card. Cannot use IsOriginalCodeRule() here.
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true) and not c:IsDisabled()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.AdjustInstantly(c)

	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil)
	Debug.Message(#g)
	Debug.Message(c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true))
	return #g>1 and s.summonfilter(c,tp,e) --and Duel.GetCurrentChain(true)==0
		and aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.AdjustInstantly(c)

	if not ToriNoKami.KurohimeDontAskMoreThanOnce(tp,e,s.summonfilter) then return end

	local ag=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil)
	if #ag>1 and aux.SelectUnselectGroup(ag,e,tp,1,#ag,s.rescon,0) then

		local g=Group.CreateGroup() --Group of card that will be returned
		Duel.Hint(HINT_CARD,tp,id)
		repeat
		g:Clear()
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			g=aux.SelectUnselectGroup(ag,e,tp,1,#ag,s.rescon,1,tp,HINTMSG_RTOHAND,s.rescon2,nil,true)
		else
			g:DeleteGroup()
			return
		end
		until(#g>0 and c:IsSynchroSummonable(g) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
		c:SetMaterial(g)
		Duel.SendtoHand(g,nil,REASON_MATERIAL)
		Duel.SpecialSummon(c,SUMMON_TYPE_SYNCHRO,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()

		ToriNoKami.ResetKurohimeFlag(tp)
		g:DeleteGroup()
	end
end

function s.thrmfilter(c)
	return c:IsSetCard(SET_TORINOKAMI) and c:IsAbleToHand()
end
function s.sumfilter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsSummonable(true,nil)
end
function s.thrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thrmfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,g,1,0,0)
end
function s.thrmop(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if not Duel.IsPlayerAffectedByEffect(1-tp,30459350) 
	and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) 
		then
			opt=Duel.SelectOption(1-tp,aux.Stringid(EFFECT_MARKER_TORINOKAMI,11),aux.Stringid(EFFECT_MARKER_TORINOKAMI,12))
		end
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,s.thrmfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
		if sc then
			Duel.SendtoHand(sc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sc)
			local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
			if #sg>0 and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
				if tc then
					Duel.Summon(tp,tc,true,nil)
				end
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	end
end