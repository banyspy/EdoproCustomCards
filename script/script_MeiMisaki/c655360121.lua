--Mei Misaki
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("MeiMisakiAux.lua")
function s.initial_effect(c)
	--Can also normal summon by tribute 1 card on the field
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0)) 
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(MeiMisaki.NormalSummonCondition)
	e0:SetTarget(MeiMisaki.NormalSummonTarget)
	e0:SetOperation(MeiMisaki.NormalSummonOperation)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_ONFIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetTarget(s.desreptg)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--Negate an activated effect that targets 1 "Dinomist" card
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_ONFIELD)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)-- This effect HOPT is handle in operation
	c:RegisterEffect(e2)
	-- Search 1 card that mention "Mei Misaki" card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND|LOCATION_ONFIELD)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Special summon from S/T zone
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
	--place in Szone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,{id,3})
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
	--Add to hand then can normal summon
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e7:SetCountLimit(1,{id,4})
	e7:SetCondition(s.revcon)
	e7:SetTarget(s.revtg)
	e7:SetOperation(s.revop)
	c:RegisterEffect(e7)
end
s.listed_names={id}
function s.tributefilter(c)
	return c:IsReleasableByEffect() and not c:IsStatus(STATUS_BATTLE_DESTROYED) and not c:IsStatus(STATUS_BATTLE_RESULT)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=Duel.SelectMatchingCard(tp,s.tributefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.Release(g,REASON_EFFECT)
		return true
	else return false end
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return e:GetHandler():GetFlagEffect(id)==0 and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) 
		and g and g:IsContains(e:GetHandler()) and Duel.IsChainDisablable(ev)
		and Duel.IsExistingMatchingCard(s.tributefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
		local g=Duel.SelectMatchingCard(tp,s.tributefilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		Duel.Release(g,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1) -- Register use for once per turn effect
		Duel.NegateEffect(ev)
	end
end
function s.thfilter(c)
	return c:ListsCode(id) and c:IsAbleToHand() and c:IsSpellTrap()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.BreakEffect()
		if c:IsRelateToEffect(e) then
			Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
--ss from Szone
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_SZONE) and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_SZONE)) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--place in Szone
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLocation(LOCATION_MZONE) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		c:RegisterEffect(e1)
	end
end
function s.revfilter(c,tp)
	return c:ListsCode(id) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:GetReasonPlayer()==1-tp
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,0,1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0 and c:IsSummonable(true,nil) then
		--repeat
		if Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			Duel.Summon(tp,c,true,nil)
		--else
			--return
		end
		--until c:IsSummonType(SUMMON_TYPE_NORMAL)
	end
end


--Legacy Code
--[[function s.ttcon2(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	--if minc>3 then return false end
    --Debug.Message("Bruh")
	local tp=c:GetControler()
    local sg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_ONFIELD,e:GetHandler())
	--Temporarily register ADD_EXTRA_TRIBUTE
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(0,LOCATION_ONFIELD)
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--Temporarily made player unable to tribute own card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(function(e,c) return c:IsControler(e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1)
	if Duel.CheckTribute(c,1,3,sg,1-tp) then--Duel.CheckTribute(c,1,3,mg,1-tp,zone)
		e0:Reset()
		e1:Reset()
		return true
	else
		e0:Reset()
		e1:Reset()
		return false
	end
end
function s.tttg2(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_ONFIELD,nil,e)
	--Temporarily register ADD_EXTRA_TRIBUTE and limit tribute your own card
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(0,LOCATION_ONFIELD)
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--Temporarily made player unable to tribute own card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRIBUTE_LIMIT)
	e1:SetValue(function(e,c) return c:IsControler(e:GetHandlerPlayer()) end)
	c:RegisterEffect(e1)
	local g=Duel.SelectTribute(tp,c,1,3,mg,1-tp,0x7f,true)
	if g and #g>0 then
		e0:Reset()
		e1:Reset()
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	e0:Reset()
	e1:Reset()
	return false
end
function s.ttop2(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
	g:DeleteGroup()
end]]