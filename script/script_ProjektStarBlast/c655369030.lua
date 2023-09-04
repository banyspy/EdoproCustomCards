-- ProjektStarBlast Solar Storm
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Plus sign Negate
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
function s.placeKiana(c)
	return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) and not c:IsForbidden()
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local place = Duel.IsExistingMatchingCard(s.placeKiana,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	local active = true
	if chk==0 then return place or active end
	local op=Duel.SelectEffect(tp,
		{place,aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,12)},
		{active,aux.Stringid(id,0)})
	if op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
		local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_ONFIELD&~LOCATION_EMZONE --[[~filter<<16]])
		Duel.Hint(HINT_ZONE,tp,zone)
		Duel.Hint(HINT_ZONE,1-tp,zone>>16)
		e:SetLabel(zone)
		local sg=groupfrombit(zone>>16,1-tp)
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	end
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
		local zone=e:GetLabel()
		local g=groupfrombit(zone>>16,1-tp)

		--Negate the effects of all face-up monsters your opponent currently controls, until the end of this turn
		for tc in g:Iter() do
			tc:NegateEffects(c,ProjektStarBlast.ResetPhaseValue(tp))
		end

		if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_PROJEKTSTARBLAST_KIANA),tp,LOCATION_ONFIELD,0,1,nil) then return end

		--Opponent main monster zone = 0x1F0000
		--Opponent spell/trap zone = 0x1F000000
		--Debug.Message(zone)
		zone=adjzone(zone)

		--Debug.Message(zone)
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(0,LOCATION_ONFIELD)
		e1:SetTarget(s.distg)
		e1:SetLabel(zone)
		e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAIN_SOLVING)
		e3:SetOperation(s.disop)
		e3:SetReset(ProjektStarBlast.ResetPhaseValue(tp))
		e3:SetLabel(zone)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.distg(e,c)
	local seq=e:GetLabel()
	--Check if the card is in the Seq zone, could be more organized code
	if seq&0x01000000~=0 and c:IsLocation(LOCATION_SZONE) and c:IsSequence(0) then return true end
	if seq&0x02000000~=0 and c:IsLocation(LOCATION_SZONE) and c:IsSequence(1) then return true end
	if seq&0x04000000~=0 and c:IsLocation(LOCATION_SZONE) and c:IsSequence(2) then return true end
	if seq&0x08000000~=0 and c:IsLocation(LOCATION_SZONE) and c:IsSequence(3) then return true end
	if seq&0x10000000~=0 and c:IsLocation(LOCATION_SZONE) and c:IsSequence(4) then return true end
	if seq&0x00010000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(0) then return true end
	if seq&0x00020000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(1) then return true end
	if seq&0x00040000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(2) then return true end
	if seq&0x00080000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(3) then return true end
	if seq&0x00100000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(4) then return true end
	if seq&0x00200000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(5) then return true end
	if seq&0x00400000~=0 and c:IsLocation(LOCATION_MZONE) and c:IsSequence(6) then return true end
	return false
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local cseq=e:GetLabel()
	local rc=re:GetHandler()
	local p,loc,seq=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE)
	if p==tp then return end 
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		if loc&LOCATION_SZONE==0 or rc:IsControler(1-p) then
			if rc:IsLocation(LOCATION_SZONE) and rc:IsControler(p) then
				seq=rc:GetSequence()
			else
				seq=rc:GetPreviousSequence()
			end
		end
		if loc&LOCATION_SZONE==0 then
			local val=re:GetValue()
			if val==nil or val==LOCATION_SZONE or val==LOCATION_FZONE or val==LOCATION_PZONE then
				loc=LOCATION_SZONE
			end
		end
	end

	if s.disopchk(cseq,loc,seq) then
		Duel.NegateEffect(ev)
	end
end
function s.disopchk(cseq,loc,seq)
	--Check if the card is in the Seq zone, could be more organized code
	if cseq&0x01000000~=0 and loc&LOCATION_SZONE~=0 and seq==0 then return true end
	if cseq&0x02000000~=0 and loc&LOCATION_SZONE~=0 and seq==1 then return true end
	if cseq&0x04000000~=0 and loc&LOCATION_SZONE~=0 and seq==2 then return true end
	if cseq&0x08000000~=0 and loc&LOCATION_SZONE~=0 and seq==3 then return true end
	if cseq&0x10000000~=0 and loc&LOCATION_SZONE~=0 and seq==4 then return true end
	if cseq&0x00010000~=0 and loc&LOCATION_MZONE~=0 and seq==0 then return true end
	if cseq&0x00020000~=0 and loc&LOCATION_MZONE~=0 and seq==1 then return true end
	if cseq&0x00040000~=0 and loc&LOCATION_MZONE~=0 and seq==2 then return true end
	if cseq&0x00080000~=0 and loc&LOCATION_MZONE~=0 and seq==3 then return true end
	if cseq&0x00100000~=0 and loc&LOCATION_MZONE~=0 and seq==4 then return true end
	if cseq&0x00200000~=0 and loc&LOCATION_MZONE~=0 and seq==5 then return true end
	if cseq&0x00400000~=0 and loc&LOCATION_MZONE~=0 and seq==6 then return true end
	return false
end