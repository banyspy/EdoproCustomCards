-- Evilswarm Winda
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    -- Apply "Infestation" Spell/Trap effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.efcost)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
    --Set 1 activated "Infestation" instead of sending it to GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_INFESTATION}
function s.thfilter(c)
	return c:IsSetCard(SET_INFESTATION) and c:IsSpellTrap() and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
        local tg=g:GetFirst()
        aux.ToHandOrElse(tg,tp,
        function()
            return tg:IsSSetable()
        end,
        function()
            Duel.SSet(tp,tg)
            if tg:IsTrap() then
                local e1=Effect.CreateEffect(e:GetHandler())
		        e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		        e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		        e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		        tg:RegisterEffect(e1)
            end
            if tg:IsQuickPlaySpell() then
                local e2=Effect.CreateEffect(e:GetHandler())
		        e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		        e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		        e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		        tg:RegisterEffect(e2)
            end
        end,
        aux.Stringid(id,2))
	end
end
function s.effilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsSetCard(SET_INFESTATION) and c:CheckActivateEffect(false,true,false)~=nil 
		and (c:IsNormalSpell() or c:IsQuickPlaySpell() or c:IsNormalTrap() or c:IsCounterTrap())
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.effilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		if not te then return end
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.effilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_COST)==0 then return end
	local te=g:GetFirst():CheckActivateEffect(false,true,false)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
end
--When a "Infestation" Spell/Trap is resolving
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	return rp==tp and re:GetActiveType()&(TYPE_TRAP|TYPE_SPELL)~=0 and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and rc:IsSetCard(SET_INFESTATION) and Duel.GetFlagEffect(tp,id)==0
end
	--Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanTurnSet() and e:GetHandler():IsAbleToRemove() end
end
	--Set 1 activated "Infestation" Spell/Trao instead of sending it to GY
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsOnField() then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
	end
end