--Reoyin Arsenal
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('ReoyinAux.lua')
function s.initial_effect(c)
	--Fusion
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=Fusion.OnFieldMat,extrafil=s.fextra})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.costhint)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Synchro
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e2:SetCost(s.costhint)
	e2:SetTarget(s.synchrotarget)
	e2:SetOperation(s.synchroactivate)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e2)
	--Xyz
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetTarget(s.xyztarget)
	e3:SetOperation(s.xyzactivate)
	c:RegisterEffect(e3)
	--Link
	local e4=e2:Clone()
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetTarget(s.linktarget)
	e4:SetOperation(s.linkactivate)
	c:RegisterEffect(e4)
end
s.listed_series={SET_REOYIN}

function s.costhint(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.checkextra(tp,sg,fc)
	return sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsSetCard,SET_REOYIN),aux.FilterBoolFunction(Card.IsControler,tp)),1,nil)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil),s.checkextra
end
function s.scfilter1(c,e,tp,g)
	--local mg=Group.FromCards(c,mc)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.scfilter2,tp,LOCATION_EXTRA,0,1,nil,c,g)
end
function s.scfilter2(c,mc,mg)
	return c:IsSynchroSummonable(mc,mg)
end
function s.synchrotarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_REOYIN)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.scfilter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,g) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.synchroactivate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local ryg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,SET_REOYIN) -- ryg= reoyin group (Group of your reoyin monster)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.scfilter1,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,ryg) -- g = the summon monster (group)
	local tc=g:GetFirst() -- tc = g but become card variable
	if not tc or not Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then return end -- Negate its effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e2)
	Duel.SpecialSummonComplete()
	local exg=Duel.GetMatchingGroup(s.scfilter2,tp,LOCATION_EXTRA,0,nil,tc,ryg)
	--Debug.Message("ryg amount: "..#ryg) 
	--Debug.Message("g amount: "..#g) 
	--Debug.Message("exg amount: "..#exg) 
	if #exg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=exg:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst(),tc,ryg)
	end
end
function s.xyzfilter1(c,e,tp)
	local rk
	local XyzBool
	if(c:HasLevel()) then
		rk=c:GetLevel()
		XyzBool = true
	else
		rk=c:GetRank()
		local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
		XyzBool = (#pg<=0 or (#pg==1 and pg:IsContains(c)))
	end
	return rk>0 and c:IsFaceup() and c:IsSetCard(SET_REOYIN) and XyzBool
		and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk) 
end
function s.xyzfilter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
		and mc:IsCanBeXyzMaterial(c,tp)	and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.xyzfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.xyzfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzactivate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	local rk
	if(tc:HasLevel()) then rk=tc:GetLevel() else rk=c:GetRank() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,rk)
	local sc=g:GetFirst()
	if sc then
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.CardIncludeInGroup(c,g)
	return g:IsContains(c)
end
function s.rescon(tc--[[,ExtraG,exclimit]])
	return function(sg,e,tp,mg)
		local b=(sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsSetCard,SET_REOYIN),aux.FilterBoolFunction(Card.IsControler,tp)),1,nil)) 
		and tc:IsLinkSummonable(nil,sg,#sg,#sg) and Duel.GetLocationCountFromEx(tp,tp,sg,tc)>0
		--[[and (ExtraG==nil or (ExtraG:FilterCount(s.CardIncludeInGroup,nil,sg) <= exclimit))

		if(ExtraG~=nil) then ExtraG:DeleteGroup() end]]

		return b
	end
end
function s.chkcon(tc--[[,ExtraG,exclimit]])
	return function(sg,e,tp,mg)
		local b=(sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsSetCard,SET_REOYIN),aux.FilterBoolFunction(Card.IsControler,tp)),1,nil)) 
		and tc:IsLinkSummonable(nil,sg,#sg,#sg) and Duel.GetLocationCountFromEx(tp,tp,sg,tc)>0
		--[[and (ExtraG==nil or (ExtraG:FilterCount(s.CardIncludeInGroup,nil,sg) <= exclimit))

		if(ExtraG~=nil) then ExtraG:DeleteGroup() end]]

		return b
	end
end
function s.breakcon(tc--[[,ExtraG,exclimit]])
	return function(sg,e,tp,mg)
		local b=(sg:IsExists(aux.AND(aux.FilterBoolFunction(Card.IsSetCard,SET_REOYIN),aux.FilterBoolFunction(Card.IsControler,tp)),1,nil)) 
		and tc:IsLinkSummonable(nil,sg,#sg,#sg) and Duel.GetLocationCountFromEx(tp,tp,sg,tc)>0
		--[[and (ExtraG==nil or (ExtraG:FilterCount(s.CardIncludeInGroup,nil,sg) <= exclimit))

		if(ExtraG~=nil) then ExtraG:DeleteGroup() end]]

		return b
	end
end
function s.linkfilter(c,g,e,tp)
	if not (c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)) then return end
	--local exclimit=0
	--local ExtraG = nil
	g:Filter(Card.IsCanBeLinkMaterial,nil,c,tp)
	--[[Had to hardcode for underworld goddess, lol, until there is solution that can handle card like this
	if(c:IsOriginalCode(98127546)) then 
		ExtraG = Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		g:Merge(ExtraG)
		exclimit=1
	end
	g:Filter(Card.IsCanBeLinkMaterial,nil,c,tp)]]
	--[[
	local ExtramatEff = c:GetCardEffect(EFFECT_EXTRA_MATERIAL)
	local ExtraG
	if( ExtramatEff~=nil and ExtramatEff:GetHandler()==c) then 
		local Valuef = ExtramatEff:GetValue()
		ExtraG = Valuef(0,SUMMON_TYPE_LINK,e,tp,c)
		g1:Merge(ExtraG)
	end]]

	local b = aux.SelectUnselectGroup(g,e,tp,1,c:GetLink(),s.rescon(c),0)
	--if(ExtraG~=nil) then ExtraG:DeleteGroup() end
	g:DeleteGroup()
	return b
end
function s.linktarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil,g,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.linkactivate(e,tp,eg,ep,ev,re,r,rp)
	--local exclimit=0
	--local ExtraG = nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ag=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_ONFIELD|LOCATION_HAND,0,nil)
	
	local g=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil,ag,e,tp)
	local tc=g:GetFirst()
	--[[Had to hardcode for underworld goddess, lol, until there is solution that can handle card like this
	if(tc:IsOriginalCode(98127546)) then 
		ExtraG = Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		ag:Merge(ExtraG)
		exclimit=1
	end]]

	if tc and tc:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) then
		--e:SetLabel(tc:GetLink())
		local sg=aux.SelectUnselectGroup(ag,e,tp,1,tc:GetLink(),s.rescon(tc),1,tp,HINTMSG_LMATERIAL,s.chkcon(tc),s.breakcon(tc))
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_MATERIAL+REASON_LINK)
		tc:SetMaterial(sg)
		Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
	end
	g:DeleteGroup()
	ag:DeleteGroup()
	--if(ExtraG~=nil) then ExtraG:DeleteGroup() end
end
