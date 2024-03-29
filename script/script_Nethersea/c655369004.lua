--Nethersea Brandguider
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Attribute and race cannot be changed as rule
	Nethersea.CannotChangeAttributeRace(c)
	--spsummon limit
	Nethersea.SpecialSummonLimit(c)
	--Quick Tribute summon from hand
	Nethersea.QuickTributeProc(c)
	--change to def to negate all faceup your opponent card and increase own def
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--set s/t upon ss in def
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)

	Nethersea.GenerateToken(c)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil) end
	local g = Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c = e:GetHandler()
	if (not c:IsRelateToEffect(e)) or c:IsDefensePos() then return end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	local g = Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c:GetAttack())
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(CARD_NETHERSEA_BRANDGUIDER) == 0
end
function s.setcheck(c)
	return c:IsCode(CARD_UMI) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.setcheck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	c:RegisterFlagEffect(CARD_NETHERSEA_BRANDGUIDER,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	c:RegisterEffect(e1)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.setop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setcheck,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		local tg=g:GetFirst()
		Duel.SSet(tp,tg)
		if tg:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetDescription(aux.Stringid(CARD_NETHERSEA_HIVEMIND,3))
			tg:RegisterEffect(e1)
		end
		if tg:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetDescription(aux.Stringid(CARD_NETHERSEA_HIVEMIND,3))
			tg:RegisterEffect(e1)
		end
	end
end
