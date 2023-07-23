--Doll Eye
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Set up to spell/trap effect that activated this turn
	local e1,e2=MeiMisaki.CreateActivateDiscardEff({
		handler=c,
		handlerid=id,
		--category=CATEGORY_TOHAND,
		functg=s.settg,
		funcop=s.setop
	})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	MeiMisaki.CreateShuffleAddEff(c,id)
end
s.listed_names={CARD_MEI_MISAKI}
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local place = Duel.IsExistingMatchingCard(s.placeMeiMisaki,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local active = Duel.IsExistingMatchingCard(s.setMentionMeiMisaki,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_MEI_MISAKI,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		--
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.setMentionMeiMisaki(c)
	return ((c:ListsCode(CARD_MEI_MISAKI) and c:IsSpellTrap())) and c:IsSSetable()
end
function s.placeMeiMisaki(c)
	return c:IsCode(CARD_MEI_MISAKI) and not c:IsForbidden()
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local tc=Duel.SelectMatchingCard(tp,s.placeMeiMisaki,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then 
			if Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				tc:RegisterEffect(e1)
			end
		end
	elseif op==2 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)--After resolved register each time effect is activated
		e1:SetCode(EVENT_CHAINING)
		e1:SetCondition(s.regcon)
		e1:SetOperation(s.regop1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)--If it is negated then it shoudn't counted
		e2:SetCode(EVENT_CHAIN_NEGATED)
		e2:SetCondition(s.regcon)
		e2:SetOperation(s.regop2)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)--Apply effect at the end phase
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		e3:SetCondition(s.effcon)
		e3:SetOperation(s.effop)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		e1:SetLabelObject(e3)
		e2:SetLabelObject(e3)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL|TYPE_TRAP)
end
function s.regop1(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(ct+1)
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabelObject():GetLabel()
	if ct==0 then ct=1 end
	e:GetLabelObject():SetLabel(ct-1)
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
function s.sfilter(c)
	return c:ListsCode(CARD_MEI_MISAKI) and c:GetCode()~=id and c:IsSpellTrap() and c:IsSSetable()
end
function s.setcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==#sg
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local rg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK,0,nil)
	if #rg<=0 or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local sg=aux.SelectUnselectGroup(rg,e,tp,1,e:GetLabel(),s.setcheck,1,tp,HINTMSG_TOFIELD)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end
