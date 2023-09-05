-- ProjektStarBlast Secure & Prepare
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Banish or Prevent Banish
	local e1,e2=ProjektStarBlast.CreateActivateDiscardEff({
		handler=c,
		handlerid=id,
		--category=CATEGORY_REMOVE,
		functg=s.bantg,
		funcop=s.banop
	})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	ProjektStarBlast.CreateShuffleAddEff(c,id)
end
s.listed_names={CARD_PROJEKTSTARBLAST_KIANA}
s.listed_series={SET_PROJEKTSTARBLAST}
function s.placeKiana(c)
	return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) and not c:IsForbidden()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local place = Duel.IsExistingMatchingCard(s.placeKiana,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local activeBP = Duel.IsAbleToEnterBP() or (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
	local active = true
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{activeBP,aux.Stringid(id,0)},
		{active,aux.Stringid(id,1)})
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		local tc=Duel.SelectMatchingCard(tp,s.placeKiana,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
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
		--Increase battle damage
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetCondition(s.damcon)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			e1:SetOperation(s.damop(4))
		else
			e1:SetOperation(s.damop(2))
		end
		e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e1,tp)

		--For Text
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(0,1)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			e2:SetDescription(aux.Stringid(id,3))
		else
			e2:SetDescription(aux.Stringid(id,2))
		end
		e2:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e2,tp)
	elseif op==3 then
		-- reduce damage
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			e1:SetDescription(aux.Stringid(id,5))
			e1:SetValue(function (e,re,val,r,rp,rc) return val//4 end)
		else
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetValue(function (e,re,val,r,rp,rc) return val//2 end)
		end
		e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return ep~=tp
end
function s.damop(num)
	return function(e,tp,eg,ep,ev,re,r,rp)
  		local dam=Duel.GetBattleDamage(ep)
  		Duel.ChangeBattleDamage(ep,dam*num)
	end
end
