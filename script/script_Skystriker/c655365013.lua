--Sky striker Ace - Arashi
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
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
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
s.listed_series={SET_SKY_STRIKER_ACE}
function s.xyzfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE)
end
function s.xyzlinkfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_WIND)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.HintSelection(g)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		return
	end
	if(Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2))) then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end

	--If sent as link material
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE)
end
	--A "Sky Striker Ace" link monster using this card can make a second attack during each battle phase
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end