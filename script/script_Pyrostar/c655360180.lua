-- Pyrostar Dust
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_SEARCH|CATEGORY_TOHAND)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --destroy 1 from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.gravetarget)
	e2:SetOperation(s.graveoperation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PYROSTAR}
function s.addfilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsAbleToHand()
end
function s.shufflefilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.shufflefilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,math.min(6,#g),0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,math.min(6,#g)//2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.shufflefilter),tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,6,nil)
	if #sg>0 then
		local sc=Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		if (sc//2)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local ac=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,sc//2,nil)
			if #ac>0 then
            	Duel.SendtoHand(ac,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,ac)
			end
		end
	end
end
function s.gravefilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsSpellTrap()
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then 
		Duel.Destroy(g,REASON_EFFECT)
	end
end