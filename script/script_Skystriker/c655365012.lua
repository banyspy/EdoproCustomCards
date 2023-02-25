--Sky striker Ace - Izumi
--Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon procedure
	Xyz.AddProcedure(c,s.xyzfilter,4,2,s.xyzlinkfilter,aux.Stringid(id,0),nil,nil,false,nil)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
    --Can only special summon once per turn
    c:SetSPSummonOnce(id)
    --To hand and possibly damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    --A link monster using this card cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.lkcon)
	e2:SetOperation(s.lkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SKY_STRIKER,SET_SKY_STRIKER_ACE}
function s.xyzfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE)
end
function s.xyzlinkfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_WATER)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.GYfilter(c)
	return c:IsSetCard(SET_SKY_STRIKER) and c:IsSpell()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) 
	and Duel.IsExistingMatchingCard(s.GYfilter,tp,LOCATION_GRAVE,0,1,nil)  end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local ng=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
	local num=Duel.GetMatchingGroupCount(s.GYfilter,tp,LOCATION_GRAVE,0,1,nil)
	if (#ng<=0) or (num<=0) then return end
	local g=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,num,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

	--If sent as link material
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE)
end
	--A "Sky Striker Ace" link monster using this card have their original ATK doubled
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(rc:GetBaseAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end