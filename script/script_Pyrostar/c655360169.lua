-- Charci The Gold Pyrostar
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    -- Special summon Synchro
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.syntg)
	e1:SetOperation(s.synop)
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
