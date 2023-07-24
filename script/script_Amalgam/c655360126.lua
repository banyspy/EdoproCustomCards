-- Amalgam - Seraphym, The Hollowed
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_AMALGAM),1,1,Synchro.NonTuner(nil),1,1)
	--Immune to monster that share the same type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immune)
	c:RegisterEffect(e1)
    --negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.synchro_nt_required=1
s.listed_series={SET_AMALGAM}
function s.immune(e,te)
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
    local race=Amalgam.AllTypeFromGroup(cg)
    return te:IsMonsterEffect() and te:GetOwner():GetRace()&race~=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
    local race=Amalgam.AllTypeFromGroup(cg)
	return re:GetOwnerPlayer()~=tp and re:IsActiveType(TYPE_MONSTER) and rc:GetRace()&race~=0 and rc~=c 
    and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end