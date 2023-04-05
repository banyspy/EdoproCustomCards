--Light of Hope Utopia Reoyin
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,8,2,s.xyzfilter,aux.Stringid(id,0))
	c:EnableReviveLimit()
	--Negate attack/destroy/inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--attach the activating card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.attachcon)
	e2:SetCost(aux.dxmcostgen(1,1,nil))
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.xyzfilter(c)
	return c:IsMonster() and c:IsType(TYPE_XYZ) and (c:GetRank()==4)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetAttacker()
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:IsDestructable(e) then
		e:SetCategory(e:GetCategory()|CATEGORY_DAMAGE)
		local dam=g:GetAttack()
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetAttacker()
	Duel.NegateAttack()
	if g:IsRelateToEffect(e) then
		local atk=g:GetAttack()
		if atk<0 then atk=0 end
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRelateToEffect(re) and ( loc&LOCATION_ONFIELD > 0 )
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return rc:IsMonster() and rc:IsOnField() and rc:IsRelateToEffect(re)
		and rc~=e:GetHandler() and not rc:IsType(TYPE_TOKEN) and rc:IsCanBeXyzMaterial(e:GetHandler(),tp,REASON_EFFECT) end
	Duel.SetTargetCard(rc)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and rc and rc:IsRelateToEffect(e) and not rc:IsImmuneToEffect(e) 
	and not rc:IsType(TYPE_TOKEN) and rc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
		Duel.Overlay(c,rc)
	end
end
