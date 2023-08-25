-- Alumi The Silver Pyrostar
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- While this card is in your hand (Quick Effect): You can destroy 1 other "Pyrostar" card
	-- from your hand or your field, and if you do, Special Summon this card.
	Pyrostar.HandQuickDestroySummon(c)
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- destroy and draw
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DESTROY+CATEGORY_DRAW,
		functg=s.drawtg,
		funcop=s.drawop})
	c:RegisterEffect(e1)
end
function s.DestroyFilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.DestroyFilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c,e,tp)
    if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Pyrostar.HandDestroyFilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,e,tp)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end
