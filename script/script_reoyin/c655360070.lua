--Reoyin x Firewall Dragon
--Scripted by bankkyza
local s,id=GetID()
--Duel.LoadScript('MagikularAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--Return monsters from field/GY to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Special summon upon leave the field
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={655360061,5043010}
function s.thfilter(c)
	return c:IsMonster() and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsMonster() and (c:IsRace(RACE_SPELLCASTER|RACE_CYBERSE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.thfilter(chkc) end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetChainLimit(function (e,ep,tp) return tp==ep end)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSummonType(SUMMON_TYPE_LINK) 
	and c:GetReasonPlayer()==1-tp
end
function s.spfirewallfilter(c,e,tp)
	return c:IsCode(5043010) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spreoyinfilter(c,e,tp)
	return c:IsCode(655360061) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_EXTRA) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(s.spfirewallfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spreoyinfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sm=0
	if Duel.IsExistingMatchingCard(s.spfirewallfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) then sm=sm+1 end
	if Duel.IsExistingMatchingCard(s.spreoyinfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,nil,e,tp) then sm=sm+1 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetMZoneCount(tp)<sm then return end
	local tc1=Duel.SelectMatchingCard(tp,s.spfirewallfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc2=Duel.SelectMatchingCard(tp,s.spreoyinfilter,tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=Group.CreateGroup()
	tc:Merge(tc1)
	tc:Merge(tc2)
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end
