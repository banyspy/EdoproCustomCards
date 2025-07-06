--Tori-No-Kami Kurohime
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),1,99)
	c:EnableReviveLimit()
	Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Duel.SynchroSummon(tp,e:GetHandler(),nil,ryg)
end
s.listed_series={SET_TORINOKAMI}
s.synchro_nt_required=1
s.synchro_tuner_required=1
function s.rescon(sg,e,tp,mg)
	local c=e:GetHandler()
	return c:IsSynchroSummonable(sg) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0
end
function s.rescon2(sg,e,tp,mg) -- for cancel
	local c=e:GetHandler()
	return  #sg==0
end
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_SPIRIT)
end
function s.summonfilter(c,tp,e)
	return c:IsOriginalCode(id)--Must be actual card. Cannot use IsOriginalCodeRule() here.
	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true) and not c:IsDisabled()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.AdjustInstantly(c)

	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil)
	Debug.Message(#g)
	Debug.Message(c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,true))
	return #g>1 and s.summonfilter(c,tp,e) and Duel.GetCurrentChain(true)==0
		and aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.AdjustInstantly(c)

	if not ToriNoKami.KurohimeDontAskMoreThanOnce(tp,e,s.summonfilter) then return end

	local ag=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_MZONE,0,nil)
	if #ag>1 and aux.SelectUnselectGroup(ag,e,tp,1,#ag,s.rescon,0) then

		local g=Group.CreateGroup() --Group of card that will be returned
		repeat
		g:Clear()
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			g=aux.SelectUnselectGroup(ag,e,tp,1,#ag,s.rescon,1,tp,HINTMSG_RTOHAND,s.rescon2,nil,true)
		else
			g:DeleteGroup()
			return
		end
		until(#g>0 and c:IsSynchroSummonable(g) and Duel.GetLocationCountFromEx(tp,tp,g,c)>0)
		c:SetMaterial(g)
		Duel.SendtoHand(g,nil,REASON_COST+REASON_MATERIAL)
		Duel.SpecialSummon(c,SUMMON_TYPE_SYNCHRO,tp,tp,false,true,POS_FACEUP)
		c:CompleteProcedure()

		ToriNoKami.ResetKurohimeFlag(tp)
		g:DeleteGroup()
	end
end