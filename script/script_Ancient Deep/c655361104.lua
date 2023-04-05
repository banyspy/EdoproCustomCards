--Ancient Deep Megalo
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Summon limit to you after summon successfully
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(s.limit)
	c:RegisterEffect(e0)
	local e0a=e0:Clone()
	e0a:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e0a)
	local e0b=e0:Clone()
	e0b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e0b)
	--[[
	--cannot summon this card if you summon anything other than WATER
	local e0c=Effect.CreateEffect(c)
	e0c:SetType(EFFECT_TYPE_SINGLE)
	e0c:SetCode(EFFECT_CANNOT_SUMMON)
	e0c:SetCondition(s.excon)
	c:RegisterEffect(e0c)
	local eod=e0c:Clone()
	eod:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(eod)
	local eoe=Effect.CreateEffect(c)
	eoe:SetType(EFFECT_TYPE_SINGLE)
	eoe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	eoe:SetCode(EFFECT_SPSUMMON_CONDITION)
	eoe:SetValue(s.splimit)
	c:RegisterEffect(eoe)]]
	--Apply effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)--[[
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		c:RegisterEffect(ge2)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(ge3)
	end)]]
end
--[[
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if(not tc:IsAttribute(ATTRIBUTE_WATER)) then Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id) end
end]]
function s.limit(e,tp,eg,ep,ev,re,r,rp,chk)
	local sp=e:GetHandler():GetSummonPlayer()
	--Cannot Summon monsters, except WATER monster for the entire duel
	local e0a=Effect.CreateEffect(e:GetHandler())
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_CANNOT_SUMMON)
	e0a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0a:SetDescription(aux.Stringid(id,0))
	e0a:SetTargetRange(1,0)
	e0a:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e0a,sp)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e0b,sp)
	local e0c=e0a:Clone()
	e0c:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e0c,sp)
end
function s.sumlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
--[[
function s.excon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.splimit(e,se,sp,st,spos,tgp)
	return Duel.GetFlagEffect(tp,id)<=0
end]]

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,4,nil) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.thfilter(c)
	return c:IsSetCard(SET_ANCIENTDEEP) and c:IsMonster() and c:IsAbleToHand()
end
function s.setfilter(c)
	return c:IsSetCard(SET_ANCIENTDEEP) and c:IsSpellTrap() and c:IsSSetable()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
	if #ct<1 then return end
	local c=e:GetHandler()
	local break_chk=false
	--1+: Increase ATK by twice
	if #ct>=1 and c:IsFaceup() and c:IsRelateToEffect(e) then
		break_chk=true
		--Increase ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
		--Increase DEF
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		e2:SetValue(c:GetDefense())
		c:RegisterEffect(e2)
	end
	--2+: Search 1 "Ancient Deep" Monster
	if #ct>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then 
			if break_chk then Duel.BreakEffect() end
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
			break_chk=true
		end
	end
	--3+: Set 1 "Ancient Deep" Spell/Trap from your deck
	if #ct>=3 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then 
			if break_chk then Duel.BreakEffect() end
			Duel.SSet(tp,g)
		end
	end
end
