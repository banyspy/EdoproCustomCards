-- Pyrostar Finale Dragon
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PYROSTAR),1,1,Synchro.NonTuner(Card.IsRace,RACE_PYRO),4,4)
	-- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- (Quick Effect): You can destroy 1 "Pyrostar" monster you control or in your hand
    Pyrostar.SynchroQuickDestroy(c)
    -- destroy
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DESTROY+CATEGORY_DAMAGE,
		functg=s.destg,
		funcop=s.desop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
s.synchro_nt_required=4
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*250)
    Duel.SetChainLimit(function(e,ep,tp) return tp==ep end)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        local dc=Duel.Destroy(g,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.Damage(1-tp,dc*250,REASON_EFFECT)
    end
end