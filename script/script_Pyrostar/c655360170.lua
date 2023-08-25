-- Charci The Gold Pyrostar
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- While this card is in your hand (Quick Effect): You can destroy 1 other "Pyrostar" card
	-- from your hand or your field, and if you do, Special Summon this card.
	Pyrostar.HandQuickDestroySummon(c)
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    --destroy and special summon synchro
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON,
		functg=s.syntg,
		funcop=s.synop})
	c:RegisterEffect(e1)
end
function s.desfilter(c)
    return c:IsSetCard(SET_PYROSTAR) and c:IsDestructable() and not c:IsType(TYPE_TUNER)
end
function s.synchrofilter(c,e,tp,g)
    return c:IsSetCard(SET_PYROSTAR) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and c:IsType(TYPE_SYNCHRO)
    and c:GetLevel() <= #g+1 -- Destroy to special summon from extra with level equal amount of destroyed + 1
    and Duel.GetLocationCountFromEx(tp,tp,g,c) --Summon only 1 so I can get away with this
end
--Filter2 is for situation where card is not destroyed mid resolution so you can choose other synchro instead
function s.synchrofilter2(c,e,tp,lv)
    return c:IsSetCard(SET_PYROSTAR) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and c:IsType(TYPE_SYNCHRO)
    and c:GetLevel() == lv -- Destroy to special summon from extra with level equal amount of destroyed + 1
    and Duel.GetLocationCountFromEx(tp,tp,nil,c) --Summon only 1 so I can get away with this
end
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.synchrofilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=Duel.SelectMatchingCard(tp,s.synchrofilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g):GetFirst()
    if not sc then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,sc:GetLevel()-1,sc:GetLevel()-1,nil)
    local dc=Duel.Destroy(dg,REASON_EFFECT)
    if dc==#dg then
        Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        sc=Duel.SelectMatchingCard(tp,s.synchrofilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,dc+1)
        if #sc>0 then
            Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
        end
    end
end
