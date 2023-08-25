-- Pyrostar Wheel
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    -- Add back to hand
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND,
		functg=s.addtg,
		funcop=s.addop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_PYROSTAR) and c:IsDestructable(e) and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local dg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e,tp)
    local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return #dg>0 and aux.SelectUnselectGroup(sg,e,tp,1,2,s.spcheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_HAND)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PYROSTAR) and Duel.GetMZoneCount(tp,c)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        if Duel.Destroy(sg,REASON_EFFECT)>0 then
            local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
            if #sg<=0 then return end
            local loc=math.min(2,Duel.GetMZoneCount(tp))
            if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then loc=1 end
            local rg=aux.SelectUnselectGroup(sg,e,tp,1,loc,s.spcheck,1,tp,HINTMSG_SPSUMMON)
            Duel.SpecialSummon(rg,0,tp,tp,true,false,POS_FACEUP)
        end
    end
end
function s.addfilter(c,e,tp)
    return c:IsSetCard(SET_PYROSTAR) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,math.min(2,#g),tp,LOCATION_GRAVE)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.addfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end