-- Pyrostar Festive Griffin
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PYROSTAR),1,1,Synchro.NonTuner(Card.IsRace,RACE_PYRO),2,2)
	-- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- (Quick Effect): You can destroy 1 "Pyrostar" monster you control or in your hand
    Pyrostar.SynchroQuickDestroy(c)
    -- destroy
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DESTROY,
		functg=s.destg,
		funcop=s.desop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
s.synchro_nt_required=2
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,math.min(#g,3),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
    if #g>0 then
        Duel.HintSelection(g,true)
        Duel.Destroy(g,REASON_EFFECT)
    end
end