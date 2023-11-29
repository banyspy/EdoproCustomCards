-- Bujinunification
-- Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --(2) Negate
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,4))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.rttg)
    e2:SetOperation(s.rtop)
    c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_BUJIN}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.copytg(e,tp,eg,ep,ev,re,r,rp,0)
    local b3=s.sptg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
        {b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		s.copytg(e,tp,eg,ep,ev,re,r,rp,1)
    elseif op==3 then
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		s.sptg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
-- Check for searcg effect
function s.thfilter(c)
	return c:IsSetCard(SET_BUJIN) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- Check for copy effect
function s.getcopyfilter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsSetCard(SET_BUJIN) and c:IsFaceup()
    and Duel.IsExistingMatchingCard(s.sendcopyfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.sendcopyfilter(c,e,tp,cc)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsSetCard(SET_BUJIN) and c:IsAbleToGraveAsCost() and not c:IsCode(cc:GetCode())
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.getcopyfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.getcopyfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc2=Duel.SelectMatchingCard(tp,s.sendcopyfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc):GetFirst()
    Duel.SendtoGrave(tc2,REASON_COST)
    e:SetLabel(tc2:GetCode())
end
-- Check for link effect
function s.spmatfilter(c,e,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsSetCard(SET_BUJIN) and c:IsFaceup()
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,mc)
	return c:IsSetCard(SET_BUJIN) and c:IsType(TYPE_XYZ) and mc:IsCanBeXyzMaterial(c,tp) and not c:IsCode(mc:GetCode())
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.spmatfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.spmatfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- Operation part
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.thop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.copyop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==3 then s.spop(e,tp,eg,ep,ev,re,r,rp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
	tc:CopyEffect(e:GetLabel(),RESET_EVENT+RESETS_STANDARD)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
    if sc then
		sc:SetMaterial(tc)
		Duel.Overlay(sc,tc)
        Duel.SpecialSummonStep(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
        if e:GetHandler():IsRelateToEffect(e) then
			e:GetHandler():CancelToGrave()
			Duel.Overlay(sc,e:GetHandler())
		end
        Duel.SpecialSummonComplete()
    end
end
function s.rtfilter(c,tp)
	return c:IsSetCard(SET_BUJIN) and c:GetOwner()==tp and c:IsAbleToHand()
end
function s.rttgfilter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_BUJIN)) then return false end
	local g=c:GetOverlayGroup()
	return g:IsExists(s.rtfilter,1,nil,tp)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.rttgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,s.rttgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local g=tc:GetOverlayGroup()
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=g:FilterSelect(tp,s.rtfilter,1,1,nil,tp):GetFirst()
	if sc then
        Duel.SendtoHand(sc,nil,REASON_EFFECT)
	end
end