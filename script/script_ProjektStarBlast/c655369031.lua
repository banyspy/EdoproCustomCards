-- ProjektStarBlast Dimension Disorder
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
	local active = true
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{active,aux.Stringid(id,0)},
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
		local OnlyOpponent
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			OnlyOpponent=Duel.SelectYesNo(tp,aux.Stringid(id,2))
		else
			OnlyOpponent=false
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
		if OnlyOpponent then
			e1:SetTargetRange(0,0xff)
			e1:SetTarget(function(e,c)return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)end)
		else
			e1:SetTargetRange(0xff,0xff)
		end
		e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		e1:SetValue(LOCATION_REMOVED)
		Duel.RegisterEffect(e1,tp)
		if OnlyOpponent then
			aux.RegisterClientHint(c,0,tp,0,1,aux.Stringid(id,0),ProjektStarBlast.ResetPhaseValue(tp),1)
		else
			aux.RegisterClientHint(c,0,tp,1,1,aux.Stringid(id,0),ProjektStarBlast.ResetPhaseValue(tp),1)
		end
	elseif op==3 then
		local OnlyOpponent
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then
			OnlyOpponent=Duel.SelectYesNo(tp,aux.Stringid(id,2)) 
		else
			OnlyOpponent=false
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_REMOVE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		if OnlyOpponent then
			e1:SetTargetRange(0,1)
		else
			e1:SetTargetRange(1,1)
		end
		e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e1,tp)
		--30459350 chk
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(30459350)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		if OnlyOpponent then
			e2:SetTargetRange(0,1)
		else
			e2:SetTargetRange(1,1)
		end
		e2:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e2,tp)
		if OnlyOpponent then
			aux.RegisterClientHint(c,0,tp,0,1,aux.Stringid(id,1),ProjektStarBlast.ResetPhaseValue(tp),1)
		else
			aux.RegisterClientHint(c,0,tp,1,1,aux.Stringid(id,1),ProjektStarBlast.ResetPhaseValue(tp),1)
		end
	end
end