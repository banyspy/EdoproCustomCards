--Moon Sublimation
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_NO_87_QUEEN_OF_THE_NIGHT}--Queen of the night
function s.costfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.egfilter(c,tp)
	return not c:IsSummonPlayer(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsCode(CARD_NO_87_QUEEN_OF_THE_NIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.attachfilter(c,tp,tc)
	return c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.egfilter,nil,tp)
	if chk==0 then return #g>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Group.CreateGroup()
		local c=e:GetHandler()
		if c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) then 
			g:AddCard(c)
			c:CancelToGrave()
		end
		local ag=eg:Filter(s.egfilter,nil,tp):Filter(Card.IsRelateToEffect,nil,e):Filter(s.attachfilter,nil,tp,tc)
		g:Merge(ag)
		Duel.Overlay(tc,g)
		g:DeleteGroup()
	end
end