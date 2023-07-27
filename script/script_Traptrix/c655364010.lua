-- Traptrix Ecosystem
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
    --Change its name to "Gunkan Suship Shari"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(12801833)
	c:RegisterEffect(e0)
	--Still treated as "Traptrix" card
	local e0a=e0:Clone()
	e0a:SetCode(EFFECT_ADD_SETCODE)
	e0a:SetValue(SET_TRAPTRIX)
	c:RegisterEffect(e0a)
    --[[Treated as "Traptrip Garden"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(12801833)
	c:RegisterEffect(e0)]]
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
    --Prevent effect target
	local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,3))
	e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_names={12801833}--Traptrip Garden
s.listed_series={SET_TRAPTRIX,SET_HOLE,SET_TRAP_HOLE}
function s.copyfilter(c)
	return c:IsOriginalCodeRule(12801833) and c:IsAbleToRemove()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.copyfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sg=g:Select(tp,1,1,nil)
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        local code=sg:GetFirst():GetOriginalCode()
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
	end
end
function s.tgfilter(c,tp)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
function s.tgtg(e,c)
	return c:GetSequence()<5 and c:IsFacedown() and c:GetColumnGroup():FilterCount(s.tgfilter,nil,c:GetControler())>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b1=s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.xyztg(e,tp,eg,ep,ev,re,r,rp,0)
    local b3=s.linktg(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)},
        {b2,aux.Stringid(id,5)},
		{b3,aux.Stringid(id,6)})
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		s.xyztg(e,tp,eg,ep,ev,re,r,rp,1)
    elseif op==3 then
		s.linktg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	Duel.SetTargetParam(op)
end
-- Check for searcg effect
function s.thfilter(c)
	return (c:IsSetCard(SET_TRAPTRIX) or (c:IsSetCard({SET_HOLE,SET_TRAP_HOLE}) and c:IsNormalTrap()))
    and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- Check for xyz effect
function s.xyzfilter(c)
	return c:IsXyzSummonable() and c:IsSetCard(SET_TRAPTRIX)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- Check for link effect
function s.linkfilter(c)
	return c:IsLinkSummonable() and c:IsSetCard(SET_TRAPTRIX)
end
function s.linktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- Operation part
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.thop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    elseif op==3 then s.linkop(e,tp,eg,ep,ev,re,r,rp) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.XyzSummon(tp,tg:GetFirst())
	end
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.linkfilter,tp,LOCATION_EXTRA,0,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,tg:GetFirst())
	end
end
