-- Amalgam - Dryades, The Mythical
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Special Summon this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
    --Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.sscon)
	e2:SetTarget(s.sstarget)
	e2:SetOperation(s.ssoperation)
	c:RegisterEffect(e2)
end
s.listed_series={SET_AMALGAM}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_AMALGAM),tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return Amalgam.TypeAmountFromGroup(cg)>3
end
function s.ssfilter(c,e,tp,nt)
	return c:IsSetCard(SET_AMALGAM) and c:GetRace()&nt==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sstarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local nt=Amalgam.AllTypeFromGroup(cg)
	if chkc then return chkc:IsLocation(LOCATION_HAND) and chkc:IsControler(tp) and s.ssfilter(chkc,e,tp,nt) end
	if chk==0 then 
        return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_HAND,0,1,nil,e,tp,nt)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.ssoperation(e,tp,eg,ep,ev,re,r,rp,chk)
	if Duel.GetMZoneCount(tp)<1 then return end
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local nt=Amalgam.AllTypeFromGroup(cg)
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,nt)
	if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end