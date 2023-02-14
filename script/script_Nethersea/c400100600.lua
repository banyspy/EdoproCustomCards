--Nethersea Reefbreaker
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
	--Immediately attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--gains attack during damage calculation
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.gainatktg)
	e2:SetOperation(s.gainatkop)
	c:RegisterEffect(e2)
	
	Nethersea.GenerateToken(c)
end
function s.atkcheck(c,e)
	return not e:GetHandler():IsImmuneToEffect(e) and not c:IsImmuneToEffect(e) and e:GetHandler():CanAttack()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcheck,tp,0,LOCATION_MZONE,1,nil,e) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e1:SetValue(800)
	c:RegisterEffect(e1)
	
	local g=Duel.SelectMatchingCard(tp,s.atkcheck,tp,0,LOCATION_MZONE,1,1,nil,e)
	if #g>0 then
		local tg=g:GetFirst()
		Duel.HintSelection(tg)
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		c:RegisterEffect(e2)
		Duel.CalculateDamage(c,tg,true)
		
		if tg:IsStatus(STATUS_BATTLE_DESTROYED) then
			Duel.Destroy(tg,REASON_BATTLE)
			tg:SetStatus(STATUS_BATTLE_DESTROYED|STATUS_OPPO_BATTLE,true)
			tg:SetReason(REASON_BATTLE)
			tg:SetReasonCard(c)
		end

		if c:IsStatus(STATUS_BATTLE_DESTROYED) then
			Duel.Destroy(c,REASON_BATTLE)
			c:SetStatus(STATUS_BATTLE_DESTROYED|STATUS_OPPO_BATTLE,true)
			c:SetReason(REASON_BATTLE)
			c:SetReasonCard(tg)
		end
	end
end
function s.gainatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetAttacker()==c and c:GetFlagEffect(CARD_NETHERSEA_REEFBREAKER)==0 end
	c:RegisterFlagEffect(CARD_NETHERSEA_REEFBREAKER,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.gainatkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		e1:SetValue(800)
		c:RegisterEffect(e1)
	end
end
