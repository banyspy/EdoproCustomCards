if not aux.MeiMisakiProcedure then
	aux.MeiMisakiProcedure = {}
	MeiMisaki = aux.MeiMisakiProcedure
end

if not MeiMisaki then
	MeiMisaki = aux.MeiMisakiProcedure
end

--Card Variable
CARD_MEI_MISAKI = 655360121

MeiMisaki.CreateActivateDiscardEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	--Activate card normally
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(CARD_MEI_MISAKI,10))--"Activate"
	if category then
	    e1:SetCategory(category)
    end
    if property then
        e1:SetProperty(property)
    end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	--Discard from hand to apply activate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(CARD_MEI_MISAKI,11))--"Discard from hand to apply activate effect"
	if category then
	    e2:SetCategory(category)
    end
    if property then
        e2:SetProperty(property)
    end
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return e:GetHandler():IsDiscardable() end
        Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
    end)
	e2:SetTarget(target)
	e2:SetOperation(operation)

	return e1,e2
end,"handler","handlerid","category","property","functg","funcop")

function MeiMisaki.ResetPhaseValue(tp) --tp can be pass just fine
    local phase = Duel.GetCurrentPhase()
    if phase >= PHASE_BATTLE_START and phase <= PHASE_BATTLE then phase = PHASE_BATTLE end
    return RESET_PHASE+phase
end

function MeiMisaki.NormalSummonCondition(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return ((Duel.GetMZoneCount(tp)<=0 and #mg1>0) or #mg2>0)
end

function MeiMisaki.NormalSummonTarget(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc
	local cancel=(Duel.IsSummonCancelable() or Duel.GetMZoneCount(tp)>0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if(Duel.GetMZoneCount(tp)<=0) then
		tc=mg1:SelectUnselect(nil,tp,false,cancel,1,1)
	else
		tc=mg2:SelectUnselect(nil,tp,false,cancel,1,1)
	end
	if tc then
		g1=Group.CreateGroup()
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	else return false end
end

function MeiMisaki.NormalSummonOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Release(sg,REASON_COST)
	sg:DeleteGroup()
end

function MeiMisaki.NotActivatedYet(c,tp)
	
	if not (c:ListsCode(CARD_MEI_MISAKI) and c:IsSpellTrap()) then return end
	local ACT1=c:GetCardEffect()
	--local Count1,Count2,Count3,Count4,Count5,Count6 = ACT1:GetCountLimit()
	--local Count4,Count5,Count6 = ACT2:GetCountLimit()
	local ACTbool = ACT1:CheckCountLimit(tp)
	--Debug.Message("Card ID: " .. c:GetOriginalCode() ) --These are for checking if things work as intended
	--Debug.Message("Count1 Count: " ..Count1)
	--Debug.Message("Count2 Count: " ..Count2)
	--Debug.Message("Count3 Count: " ..Count3)
	--Debug.Message("Count4 Count: " ..Count4)
	--Debug.Message("Count5 Count: " ..Count5)
	--Debug.Message("Count6 Count: " ..Count6)
	--Debug.Message("ACTbool: " ..tostring(ACTbool))
	return ACTbool
end

function MeiMisaki.CreateShuffleAddEff(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST) 
	end)
	e1:SetTarget(function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) 
	end)
	e1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
		if not Duel.IsExistingMatchingCard(MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) then return end
		local tc=Duel.SelectMatchingCard(tp,MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,1,nil,tp)
		if tc then 
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end 
	end)
	c:RegisterEffect(e1)
end