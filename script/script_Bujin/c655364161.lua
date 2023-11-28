--Bujin Iwasaku
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
    --Normal Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(s.desreptg)
	c:RegisterEffect(e2)
    --Special
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={SET_BUJIN}
function s.spcfilter(c)
	return c:IsSetCard(SET_BUJIN) and not c:IsPublic()
end
function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) --and sg:GetClassCount(Card.GetCode)==#sg,sg:GetClassCount(Card.GetCode)~=#sg
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local hg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(hg,e,tp,2,2,s.rescon,0) end
    local g=aux.SelectUnselectGroup(hg,e,tp,2,2,s.rescon,1,tp,HINTMSG_CONFIRM,nil,nil,true)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
    g:DeleteGroup()
end
function s.sumfilter(c)
	return c:IsSetCard(SET_BUJIN) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK,0,1,nil,e) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK,0,1,1,c,e)
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
function s.desfilter(c,e)
	return  not c:IsImmuneToEffect(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) and not c:IsCode(id)
end
	--Check for an Xyz monster to use as material
function s.filter1(c,e,tp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
    Debug.Message("pg: "..#pg) 
	return (#pg<=0 or (#pg==1 and pg:IsContains(c))) and c:IsFaceup() and not c:IsImmuneToEffect(e)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.filter2(c,e,tp,mc)
	return c:IsSetCard(SET_BUJIN) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
	--Xyz summon 1 "Utopia" or "ZW -" monster, that is 1 rank higher than targeted Xyz
function s.spop(e,tp,eg,ep,ev,re,r,rp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
        local og=sc:GetOverlayGroup()
		if Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) and og:IsExists(s.spxyzfilter,1,nil,e,tp) then
            local sog=nil
            local bool
            repeat
                bool = Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3))
                if bool then
                    local sog=og:FilterSelect(tp,s.spxyzfilter,1,1,true,nil,e,tp)
                    if sog then
		                Duel.SpecialSummon(sog,0,tp,tp,false,false,POS_FACEUP)
                        bool = false
                    end
                end
            until(not bool)
        end
        Duel.SpecialSummonComplete()
		sc:CompleteProcedure()
	end
end
function s.spxyzfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_BUJIN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0
end