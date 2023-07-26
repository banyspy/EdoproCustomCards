--Traptrix Hermiterra
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT|RACE_PLANT),4,3,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	--Unaffected by effect of trap and your opponent card in same column as this card or your set card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetHandler():IsType(TYPE_TRAP) end)
	c:RegisterEffect(e1)
    --search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
    e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
    --Activate(effect)
	local e4=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCost(aux.dxmcostgen(1,1,nil))
	e4:SetCondition(s.condition2)
	e4:SetTarget(s.target2)
	e4:SetOperation(s.activate2)
    e4:SetCountLimit(1,{id,1})
	c:RegisterEffect(e4)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE,SET_TRAP_HOLE}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_TRAPTRIX,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.thfilter(c)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
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
			local b1=g:GetFirst():IsSummonable(true,nil)
			local b2=g:GetFirst():IsCanBeXyzMaterial(e:GetHandler(),tp,REASON_EFFECT)
			if b1 or b2 then
				local op=Duel.SelectEffect(tp,
				{b1,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)},
				{true,aux.Stringid(id,4)})
		    	if op==1 then
            	    Duel.Summon(tp,g:GetFirst(),true,nil)
				elseif op==2 then
					Duel.Overlay(e:GetHandler(),g:GetFirst(),true)
				end
			end
        end
	end
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not re or re:GetHandler()==e:GetHandler() then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) or re:IsHasCategory(CATEGORY_SUMMON)
end
function s.thfilter2(c)
	return (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE)) and c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function s.facedowncount(c)
    return c:IsFacedown()
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
    local FD = Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
    local sg = Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_TRAPTRIX)
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
		local e2=e1:Clone()
	    e2:SetCode(EFFECT_UPDATE_DEFENSE)
	    tg:RegisterEffect(e2)
    end
	--[[local rc = re:GetHandler()
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
	end]]
end