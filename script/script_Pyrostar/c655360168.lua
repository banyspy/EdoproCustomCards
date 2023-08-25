-- Rubi The Violet Pyrostar
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- While this card is in your hand (Quick Effect): You can destroy 1 other "Pyrostar" card
	-- from your hand or your field, and if you do, Special Summon this card.
	Pyrostar.HandQuickDestroySummon(c)
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- Add "Pyrostar" card from GY to hand
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND,
		functg=s.addtg,
		funcop=s.addop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
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