--Tori-No-Kami Kurabe
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- Apply Effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DIS_NEG_INA)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2,false,EFFECT_MARKER_TORINOKAMI)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={SET_TORINOKAMI}
function s.counterfilter(c) --Counter will count the summon that does not fit this condition
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.rmvfilter(c,tp)
	if not (c:IsSetCard({SET_TORINOKAMI}) and not c:IsPublic() and not c:IsCode(id)
		and c:IsHasEffect(EFFECT_MARKER_TORINOKAMI)) then
		return false
	end
	local eff=c:GetCardEffect(EFFECT_MARKER_TORINOKAMI)
	local te=eff:GetLabelObject()
	local con=te:GetCondition()
	local tg=te:GetTarget()
	if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0))
		and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,eff,REASON_EFFECT,PLAYER_NONE,0)) then
		return true
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 --Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		 and not e:GetHandler():IsPublic()
		 and Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
	sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	e:SetLabelObject(sc:GetCardEffect(EFFECT_MARKER_TORINOKAMI):GetLabelObject())
	--Cannot special summon the turn you activate
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	e1:SetTarget(function(e,c) return not c:IsLocation(LOCATION_EXTRA)end)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(EFFECT_MARKER_TORINOKAMI,10))
	e2:SetReset(RESET_PHASE|PHASE_END,2)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	local te=e:GetLabelObject()
	local tg=te and te:GetTarget() or nil
	if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return true end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	--local opt=0
	--local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	--if not Duel.IsPlayerAffectedByEffect(1-tp,30459350) 
	--and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) 
	--	then
	--		opt=Duel.SelectOption(1-tp,aux.Stringid(EFFECT_MARKER_TORINOKAMI,11),aux.Stringid(EFFECT_MARKER_TORINOKAMI,12))
	--	end
	--if opt==0 then
		local te=e:GetLabelObject()
		if not te then return end
		local sc=te:GetHandler()
		if sc:GetFlagEffect(id)==0 then
			e:SetLabel(0)
			e:SetLabelObject(nil)
			return
		end
		e:SetLabel(te:GetLabel())
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then
			op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
		end
		e:SetLabel(0)
		e:SetLabelObject(nil)
	--else
	--	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	--	local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
	--	Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	--end
end