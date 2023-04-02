--Unknown Destination
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("MeiMisakiAux.lua")
function s.initial_effect(c)
	--Plus sign banish and zone ban
	local e1,e2=MeiMisaki.CreateActivateDiscardEff({
		handler=c,
		handlerid=id,
		--category=CATEGORY_REMOVE,
		functg=s.bantg,
		funcop=s.banop
	})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)

	MeiMisaki.CreateShuffleAddEff(c,id)
end
s.listed_names={CARD_MEI_MISAKI}
--Get the bits of place denoted by loc and seq as well as its vertically and
--horizontally adjancent zones.
local function adjzone(zone)
	--Opponent main monster zone = 0x1F0000
	--Opponent spell/trap zone = 0x1F000000
	if zone>=0x10000 and zone<=0x100000 then -- Monster zone
		if zone==0x20000 or zone==0x80000 then --Extra monster zone = 0x200000 , 0x400000
			--Own zone and horizontally adjancent | Vertically adjacent S/T zone | Vertically adjacent Extra monster zone
			return ((zone|(zone*2)|(zone/2))&0x1F0000)|(zone*0x100)|(0x200000*(1+((zone-0x20000)/0x60000)))
		else
			--Own zone and horizontally adjancent | Vertically adjacent S/T zone
			return ((zone|(zone*2)|(zone/2))&0x1F0000)|(zone*0x100)
		end
	elseif zone>=0x1000000 and zone<=0x10000000 then--Spell/Trap zone
		--Own zone and horizontally adjancent | Vertically adjacent monster zone
		return ((zone|(zone*2)|(zone/2))&0x1F000000)|(zone/0x100)
	else -- in case want to accept other zone too, but there would be no "adjacent" zone for other case
		return zone
	end
end
--Get a group of cards from a location and sequence (and its adjancent zones)
--that is fetched from a set bit of a zone bitfield integer.
local function groupfrombit(bit,p)
	local loc=(bit&0x7F>0) and LOCATION_MZONE or LOCATION_SZONE
	local seq=(loc==LOCATION_MZONE) and bit or bit>>8
	seq = math.floor(math.log(seq,2))
	local g=Group.CreateGroup()
	local function optadd(loc,seq)
		local c=Duel.GetFieldCard(p,loc,seq)
		if c then g:AddCard(c) end
	end
	optadd(loc,seq)
	if seq<=4 then --No EMZ
		if seq+1<=4 then optadd(loc,seq+1) end
		if seq-1>=0 then optadd(loc,seq-1) end
	end
	if loc==LOCATION_MZONE then
		if seq<5 then
			optadd(LOCATION_SZONE,seq)
			if seq==1 then optadd(LOCATION_MZONE,5) end
			if seq==3 then optadd(LOCATION_MZONE,6) end
		elseif seq==5 then
			optadd(LOCATION_MZONE,1)
		elseif seq==6 then
			optadd(LOCATION_MZONE,3)
		end
	else -- loc == LOCATION_SZONE
		optadd(LOCATION_MZONE,seq)
	end
	return g
end
function s.placeMeiMisaki(c)
	return c:IsCode(CARD_MEI_MISAKI) and not c:IsForbidden()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local place = Duel.IsExistingMatchingCard(s.placeMeiMisaki,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local active = true
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_MEI_MISAKI,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD&~LOCATION_EMZONE --[[~filter<<16]])
		Duel.Hint(HINT_ZONE,tp,zone)
		Duel.Hint(HINT_ZONE,1-tp,zone>>16)
		e:SetLabel(zone)
		local sg=groupfrombit(zone>>16,1-tp)
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,1,0,0)
	end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetTargetParam(op)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
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
		local zone=e:GetLabel()
		local g=groupfrombit(zone>>16,1-tp)
	
		--Banish group of cards face down
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)

		--Opponent main monster zone = 0x1F0000
		--Opponent spell/trap zone = 0x1F000000
		--Debug.Message(zone)
		zone=adjzone(zone)

		--Debug.Message(zone)
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE_FIELD)
		e1:SetLabel(zone)
    	e1:SetOperation(function() return zone end)
		e1:SetReset(MeiMisaki.ResetPhaseValue(tp))
		Duel.RegisterEffect(e1,tp)
	end
end
