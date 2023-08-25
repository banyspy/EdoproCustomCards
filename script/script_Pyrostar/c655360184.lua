-- Pyrostar Shock and Awe
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    -- Special Summon
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_SPECIAL_SUMMON,
		functg=s.sstg,
		funcop=s.ssop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_PYROSTAR) and c:IsDestructable(e)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,e)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and rp~=tp and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,e)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg+g,2,0,0)
    else
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_PYROSTAR)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ec=re:GetHandler()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=g:Select(tp,1,1,nil)
        if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
            Duel.Destroy(ec,REASON_EFFECT)
        end
    end
end
function s.ssfilter(c,e,tp)
    return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroup(s.ssfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end