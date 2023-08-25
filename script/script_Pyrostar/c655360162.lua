-- Calci The Orange Pyrostar
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- While this card is in your hand (Quick Effect): You can destroy 1 other "Pyrostar" card
	-- from your hand or your field, and if you do, Special Summon this card.
	Pyrostar.HandQuickDestroySummon(c)
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- Add "Pyrostar" monster
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_SEARCH+CATEGORY_TOHAND,
		functg=s.addtg,
		funcop=s.addop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
function s.addfilter(c,e,tp)
    return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end