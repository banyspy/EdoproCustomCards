if not aux.SetsugebishinProcedure then
	aux.SetsugebishinProcedure = {}
	Setsugebishin = aux.SetsugebishinProcedure
end

if not Setsugebishin then
	Setsugebishin = aux.SetsugebishinProcedure
end

--Archetype code
SET_SETSUGEBISHIN = 0xb05

--Specific card code
CARD_NO_87_QUEEN_OF_THE_NIGHT = 89516305

Setsugebishin.CreateTargetFlipEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	--Trigger upon being targeted by card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    if category then
	    e1:SetCategory(category)
    end
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BECOME_TARGET)
    if property then
        e1:SetProperty(property)
    end
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function (e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	
    --Can be activate as quick effect if being in face-down position
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    if category then
	    e2:SetCategory(category)
    end
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    if property then
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE|property)
    else
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    end
    e2:SetCountLimit(1,{id,0})
    e2:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
    end)
	e2:SetCondition(function(e) return e:GetHandler():IsFacedown() end)
	e2:SetTarget(target)
	e2:SetOperation(operation)

	return e1,e2
end,"handler","handlerid","category","property","functg","funcop")