--Traptrix Sinensis
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro material
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_PLANT+RACE_INSECT),1,99,s.matfilter)
	--Unaffected by effect of trap and your opponent card in same column as this card or your set card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
    --search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
    e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.negcon)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
    --Activate(effect)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.condition2)
	e4:SetTarget(s.target2)
	e4:SetOperation(s.activate2)
    e4:SetCountLimit(1,{id,1})
	c:RegisterEffect(e4)
end
s.synchro_nt_required=1
function s.matfilter(c,scard,sumtype,tp)
	return c:IsSetCard(0x108a)
end
function s.cfilter(c,seq,p,itself)
	return ((c == itself) or c:IsFacedown()) and c:IsColumn(seq,p,LOCATION_ONFIELD)
end
--Unaffected by trap effects and opponent card in same column
function s.efilter(e,te)
	local th=te:GetHandler()
	if th:IsType(TYPE_TRAP) then return true end
	local p=th:GetControler()
	local c=e:GetHandler()
	if p == c:GetControler() or not (th:IsLocation(LOCATION_ONFIELD)) then return end
	local seq=th:GetSequence()
	return Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil,seq,p,c)
end
function s.thfilter(c)
	return c:IsSetCard(0x108a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
        if Duel.SendtoHand(g,nil,REASON_EFFECT) then
            Duel.ConfirmCards(1-tp,g) 
		    if  Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.Summon(tp,g:GetFirst(),true,nil)
            end
        end
	end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local h=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local rc=re:GetHandler()
	return rp~=tp and (h & LOCATION_ONFIELD)~=0 and not (rc:IsLocation(LOCATION_ONFIELD) and rc:IsFaceup()) and Duel.IsChainDisablable(ev)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not re or re:GetHandler()==e:GetHandler() then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) or re:IsHasCategory(CATEGORY_SUMMON)
end
function s.thfilter2(c)
	return (c:IsSetCard(0x4c) or c:IsSetCard(0x89)) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function s.facedowncount(c)
    return c:IsFacedown()
end
function s.traptrix(c)
    return c:IsSetCard(0x108a)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
    return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
        local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e1)
    end
    local FD = Duel.GetMatchingGroupCount(s.facedowncount,tp,LOCATION_ONFIELD,0,nil)
    local sg = Duel.GetMatchingGroup(s.traptrix,tp,LOCATION_MZONE,0,nil,e)
    local tg = sg:GetFirst()
    for tg in aux.Next(sg) do
        --Increase ATK/DEF
	    local e1=Effect.CreateEffect(c)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_UPDATE_ATTACK)
	    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	    e1:SetValue(FD * 300)
	    tg:RegisterEffect(e1)
    end
	local rc = re:GetHandler()
	local activateLocation = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION)
	if ep~=tp and re:IsActiveType(TYPE_MONSTER) and (activateLocation==LOCATION_MZONE) and not rc:IsImmuneToEffect(e)
	 and Duel.GetLocationCount(1-tp,LOCATION_SZONE) > 0 and (rc:IsCanTurnSet() or rc:IsType(TYPE_LINK))
	 and rc:IsLocation(LOCATION_MZONE) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.MoveToField(rc,tp,1-tp,LOCATION_SZONE,POS_FACEDOWN,true)
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP)
		rc:RegisterEffect(e1)
	end
end