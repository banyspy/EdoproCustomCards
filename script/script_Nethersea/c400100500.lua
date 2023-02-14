--Nethersea Swarmcaller
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	--Attribute and race cannot be changed as rule
	Nethersea.CannotChangeAttributeRace(c)
	--spsummon limit
	Nethersea.SpecialSummonLimit(c)
	--Quick Tribute summon from hand
	Nethersea.QuickTributeProc(c)
	--Cannot negate the activation of your "Nethersea" card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.chainfilter)
	c:RegisterEffect(e1)
	--Cannot negate the effects of your "Nethersea" card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.chainfilter)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ALL,0)
	e3:SetTarget(s.distarget)
	c:RegisterEffect(e3)
	--Prevent effect target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(s.tgtg)
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	
	Nethersea.GenerateToken(c)
end
function s.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and Nethersea.NetherseaCardOrWQ(tc)
end
function s.distarget(e,c)
	return Nethersea.NetherseaCardOrWQ(c)
end
function s.tgtg(e,c)
	return Nethersea.NetherseaCardOrWQ(c) and c:IsFaceup() and c~=e:GetHandler()
end