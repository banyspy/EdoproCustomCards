--Number S87: Setsugebishin Queen of Manyo
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	Xyz.AddProcedure(c,nil,9,3,s.ovfilter,aux.Stringid(id,0))
	--Change name to "Number 87: Queen of the Night"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e1:SetValue(CARD_NO_87_QUEEN_OF_THE_NIGHT)
	c:RegisterEffect(e1)
	--Negate effect and decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--handes
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.hdcon)
	e3:SetTarget(s.hdtg)
	e3:SetOperation(s.hdop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_NO_87_QUEEN_OF_THE_NIGHT}--Queen of the night
--s.listed_series={0xb05}
s.xyz_number=87
function s.ovfilter(c,tp,xyzc)
	return c:IsFaceup() and c:IsSetCard(SET_NUMBER) and c:IsRace(RACE_PLANT) 
	and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and not c:IsOriginalCode(id)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.disfilter(c)
	return not (c:GetAttack()==0 and c:IsDisabled())
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and (chkc ~= e:GetHandler()) and s.disfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Loses 3200 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-3200)
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY)
		end
		tc:RegisterEffect(e1)
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
	end
end
function s.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK)
end
function s.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DRAW and eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.attachfilter(c,ac,tp)
	return c:IsCanBeXyzMaterial(ac,tp)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsRelateToEffect(e) and c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.attachfilter,tp,0,LOCATION_HAND,1,nil,c,tp) end
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.attachfilter,tp,0,LOCATION_HAND,nil,c,tp)
	if #g>0 and c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) then
		local sg=g:RandomSelect(tp,1)
		Duel.Overlay(c,sg,true)
	end
end
