-- Graydle Hydra
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
	--Fusion material
	Fusion.AddProcMix(c,true,true,s.ffilter,aux.FilterBoolFunctionEx(Card.IsRace,RACE_AQUA))
    --Aternative Special Summon procedure
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
    --Destroy 1 monster and change monsters to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Can attack all monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
    --spsummon
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.rvtg)
	e4:SetOperation(s.rvop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GRAYDLE}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsSetCard(SET_GRAYDLE,fc,sumtype,tp) and c:IsLevelAbove(5)
end
function s.altspfilter(c,tp,sc)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ag=Duel.GetMatchingGroup(s.altspfilter,tp,LOCATION_MZONE,0,nil)
	return aux.SelectUnselectGroup(ag,e,tp,3,3,s.rescon,0)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local ag=Duel.GetMatchingGroup(s.altspfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(ag,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else
		return false
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
	c:SetMaterial(g)
	g:DeleteGroup()
end
function s.desfilter(c,e)
	return c:IsMonster() and c:IsRace(RACE_AQUA)-- and c:IsDestructable(e) and not c:IsImmuneToEffect(e)
end
function s.filter(c)
	return not c:IsPublic() or c:IsMonster()
end
function s.eqfilter(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsMonster() and c:CheckUniqueOnField(tp) and not c:IsForbidden()
    and Duel.IsExistingMatchingCard(s.eqtcfilter,tp,0,LOCATION_MZONE,1,nil,c,e,tp)
end
function s.eqtcfilter(c,ec,e,tp)
	return c:IsFaceup() and aux.CheckStealEquip(c,e,tp)--and ec:CheckEquipTarget(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e)
	if #g1>0 and Duel.Destroy(g1,REASON_BATTLE)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
        local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
        if not ec then return end
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	    local tc=Duel.SelectMatchingCard(tp,s.eqtcfilter,tp,0,LOCATION_MZONE,1,1,nil,ec,e,tp):GetFirst()
	    if tc and Duel.Equip(tp,ec,tc,true) then
            local c=e:GetHandler()
		    --Add Equip limit
		    local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_EQUIP_LIMIT)
		    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		    e1:SetValue(function (e,c) return c==e:GetLabelObject() end)
		    e1:SetLabelObject(tc)
		    ec:RegisterEffect(e1)
		    --control
		    local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_EQUIP)
		    e2:SetCode(EFFECT_SET_CONTROL)
		    e2:SetValue(tp)
		    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		    ec:RegisterEffect(e2)
	    end
	end
end
function s.rvfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
function s.rvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.rvfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.rvfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end