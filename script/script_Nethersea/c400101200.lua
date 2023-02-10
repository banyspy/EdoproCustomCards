--Nethersea Evolution Discharge
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCost(s.handcost)
	e1:SetCondition(s.negActCondition)
    e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.negActTarget)
	e1:SetOperation(s.negActOperation)
	c:RegisterEffect(e1)
	--Activate(summon)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetCost(s.handcost)
	e2:SetCondition(s.negSummonCondition)
    e2:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.negSummonTarget)
	e2:SetOperation(s.negSummonOperation)
	c:RegisterEffect(e2)
	--tohand or set
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Can be activated from hand
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetValue(function(e,c) e:SetLabel(1) end)
	e4:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.costfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil) end)
	c:RegisterEffect(e4)
	e1:SetLabelObject(e4)
	e2:SetLabelObject(e4)
end
function s.costfilter(c)
	return Nethersea.NetherseaCardOrWQ(c) and (c:IsReleasable() or Nethersea.WorkaroundTributeSTinHandCheck(c,tp))
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then e:GetLabelObject():SetLabel(0) return true end
	if e:GetLabelObject():GetLabel()>0 then
		e:GetLabelObject():SetLabel(0)
		local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler()):GetFirst()
		Duel.Release(tc,REASON_COST)
	end
end
function s.cfilter(c)
    return c:IsFaceup() and Nethersea.NetherseaCardOrWQ(c)
end
function s.negActCondition(e,tp,eg,ep,ev,re,r,rp)
	return re and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.negActTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.negActOperation(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.IsPlayerCanSendtoDeck(tp,rc) and (not rc:IsHasEffect(EFFECT_CANNOT_TO_DECK))then
        rc:CancelToGrave()
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.negSummonCondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain(true)==0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.negSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,#eg,0,0)
end
function s.negSummonOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil):GetFirst()
	Duel.Release(tc,REASON_COST)
end
function s.thfilter(c)
	return c:IsSetCard(SET_NETHERSEA) and c:IsSpellTrap() and (c:IsSSetable() or c:IsAbleToHand()) and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if not tc then return end
	aux.ToHandOrElse(tc,tp,function(c) return tc:IsSSetable() end,
				function(c) Duel.SSet(tp,tc) 
					if tc:IsType(TYPE_QUICKPLAY) then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
					if tc:IsType(TYPE_TRAP) then
						local e1=Effect.CreateEffect(e:GetHandler())
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
				end,
				aux.Stringid(id,3)
	)
end
