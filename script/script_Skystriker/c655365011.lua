local s,id=GetID()
function s.initial_effect(c)
	--Xyz summon procedure
	Xyz.AddProcedure(c,s.xyzfilter,4,2,s.xyzlinkfilter,aux.Stringid(id,0),nil,nil,false,nil)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
    --Can only special summon once per turn
    c:SetSPSummonOnce(id)
    --Double damage and piercing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
    --A link monster using this card cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.lkcon)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_SKY_STRIKER_ACE}
function s.xyzfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE)
end
function s.xyzlinkfilter(c)
    return c:IsMonster() and c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsType(TYPE_LINK) and c:IsAttribute(ATTRIBUTE_FIRE)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetValue(s.damageval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,p)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_SKY_STRIKER_ACE))
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,p)
    aux.RegisterClientHint(c,0,p,1,0,aux.Stringid(id,2),RESET_PHASE|PHASE_END,1)
end
function s.damageval(e,c)
    if c:IsSetCard(SET_SKY_STRIKER_ACE) then 
        return DOUBLE_DAMAGE 
    else
        return Duel.GetBattleDamage(1-e:GetOwnerPlayer())
    end
end
	--If sent as link material
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(SET_SKY_STRIKER_ACE)
end
	--A "Sky Striker Ace" link monster using this card cannot be destroyed by battle
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1)
end