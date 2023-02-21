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
	--Unaffected by effect that your opponent response to
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_IMMUNE_EFFECT)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(LOCATION_ALL,0)
	e2a:SetTarget(s.UnaffectedFilter)
	e2a:SetValue(s.efilter)
	c:RegisterEffect(e2a)
	--Cannot be negated continuously
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
s.listed_names={CARD_UMI}
function s.chainfilter(e,ct)
	local p=e:GetHandlerPlayer()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	local tc=te:GetHandler()
	return p==tp and Nethersea.NetherseaCardOrWQ(tc)
end
function s.UnaffectedFilter(e,c) --Check if in previous chain link there is your card activated and which card is it
	local ch=Duel.GetCurrentChain(true)
	local che,chcode=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_CODE)
	--[[Debug.Message("UnaffectedFilter")
	Debug.Message(chcode)
	Debug.Message(Duel.GetCurrentChain(true))
	Debug.Message(c:GetCode())]]
	return Nethersea.NetherseaCardOrWQ(c) and ch>1 and che:IsActivated() and (c == che:GetHandler())
end
function s.efilter(e,re) --Check if card in current chain link is your opponent's activated effect and which card is it
	local ch=Duel.GetCurrentChain(true)
	local che,chcode=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_CODE)
	--[[Debug.Message("efilter")
	Debug.Message(chcode)
	Debug.Message(Duel.GetCurrentChain(true))]]
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated() and (re:GetHandler() == che:GetHandler())
end
function s.distarget(e,c)
	return Nethersea.NetherseaCardOrWQ(c)
end
function s.tgtg(e,c)
	return Nethersea.NetherseaCardOrWQ(c) and c:IsFaceup() and c~=e:GetHandler()
end