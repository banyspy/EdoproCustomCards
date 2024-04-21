--Whispers of Purgation
--scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- Add 1 card that mention back to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={655364181}
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsLevel(4) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.extgfilter(c,mention)
	return c:IsAbleToGrave() and c:ListsCode(mention:GetCode())
end
function s.exthfilter(c,mention)
	return c:IsAbleToHand() and c:ListsCode(mention:GetCode())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	local thchk=tc:IsAbleToHand()
	local tgchk=tc:IsAbleToGrave()
	if not (thchk or tgchk) then return end
	local op=Duel.SelectEffect(tp,
		{thchk,aux.Stringid(id,1)},
		{tgchk,aux.Stringid(id,2)})
	
	if op==1 and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)
		if Duel.IsExistingMatchingCard(s.extgfilter,tp,LOCATION_DECK,0,1,nil,tc) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local tc2=Duel.SelectMatchingCard(tp,s.extgfilter,tp,LOCATION_DECK,0,1,1,nil,tc):GetFirst()
			Duel.SendtoGrave(tc2,REASON_EFFECT)
		end
	end
		
	if op==2 and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.exthfilter,tp,LOCATION_DECK,0,1,nil,tc) 
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
		local tc2=Duel.SelectMatchingCard(tp,s.exthfilter,tp,LOCATION_DECK,0,1,1,nil,tc):GetFirst()
		Duel.SendtoHand(tc2,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc2)
	end
end
function s.thfilter(c)
	return c:ListsCode(655364181) and c:IsAbleToHand() and not c:IsCode(id)
	and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	--if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end