-- Monolith Crabhammer
-- Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,s.mfilter,4,4,s.lcheck)
	--Negate monsters on Link Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function(e)return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)end)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
    --Cards this points to cannot be targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(function(e,c) return e:GetHandler():GetLinkedGroup():IsContains(c) end)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2b:SetValue(aux.imval1)
    c:RegisterEffect(e2b)
    local e2c=e2:Clone()
    e2c:SetCode(EFFECT_UNRELEASABLE_SUM)
    e2c:SetValue(s.sumlimit)
    c:RegisterEffect(e2c)
    local e2d=e2:Clone()
    e2d:SetCode(EFFECT_CANNOT_RELEASE)
    e2d:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_PLAYER_TARGET)
    e2d:SetTargetRange(0,1)
    e2d:SetValue(1)
    c:RegisterEffect(e2d)
    --Special Summon itself from the GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
function s.mfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER)
end
function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentProperty(Card.GetCode,lc,sumtype,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,4,0,0)
    Duel.SetChainLimit(function(e,ep,tp)return tp==ep end)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,4,nil)
    if #g>0 then
        Duel.HintSelection(g,true)
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
function s.sumlimit(e,c)
	if not c then return false end
	return not c:IsControler(e:GetHandlerPlayer())
end
function s.resfilter(c)
	return c:IsReleasable() and (c:IsFaceup() or c:IsControler(tp))
end
function s.costchk(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==4 and Duel.GetMZoneCount(tp,sg)>0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.resfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,4,4,s.costchk,0)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    local sg=aux.SelectUnselectGroup(g,e,tp,4,4,s.costchk,1,tp,HINTMSG_RELEASE)
    Duel.HintSelection(sg,true)
    Duel.Release(sg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
        --Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
        Duel.SpecialSummonComplete()
	end
end