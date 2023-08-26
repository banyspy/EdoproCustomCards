-- Pyrostar Launcher
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PYRO),1,2,nil,nil,99)
	c:EnableReviveLimit()
    -- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
    --spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.sptarget)
	e1:SetOperation(s.spoperation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    --Destroy and attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.attachtarget)
	e2:SetOperation(s.attachoperation)
	c:RegisterEffect(e2)
    -- Destroy 1 "Pyrostar" monster from Deck
	local e3=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_DESTROY,
		functg=s.gravetarget,
		funcop=s.graveoperation})
	c:RegisterEffect(e3)
end
s.listed_series={SET_PYROSTAR}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.desfilter(c,e)
    return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsDestructable(e)
end
function s.attachfilter(c,ac,tp)
    return c:IsSetCard(SET_PYROSTAR) and c:IsMonster() and c:IsCanBeXyzMaterial(ac,tp,REASON_EFFECT)
end
function s.attachtarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,e:GetHandler(),e)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp) end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.attachoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
        local ag=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler(),tp)
        if #ag>0 then
            Duel.Overlay(e:GetHandler(),ag,true)
        end
	end
end
function s.gravefilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster()
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then 
		Duel.Destroy(g,REASON_EFFECT)
	end
end