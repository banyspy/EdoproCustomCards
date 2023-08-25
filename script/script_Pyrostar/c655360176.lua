-- Pyrostar Rising Phoenix
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_PYROSTAR),1,1,Synchro.NonTuner(Card.IsRace,RACE_PYRO),1,1)
	-- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- (Quick Effect): You can destroy 1 "Pyrostar" monster you control or in your hand
    Pyrostar.SynchroQuickDestroy(c)
    -- draw then can summon self back
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON,
		functg=s.drawtg,
		funcop=s.drawop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
s.synchro_nt_required=1
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.revealfilter(c)
    return c:IsSetCard(SET_PYROSTAR) and not c:IsPublic()
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.Draw(tp,2,REASON_EFFECT)
    local g=Duel.GetOperatedGroup()
    if #g<=0 then return end
    if g:IsExists(s.revealfilter,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
    and c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE)
    and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local rg=g:FilterSelect(tp,s.revealfilter,1,1,false,nil)
        Duel.ConfirmCards(1-tp,rg)
        Duel.ShuffleHand(tp)
        Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_DEFENSE)
    end
end