--Traptrix Poppy
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT|RACE_PLANT),4,3,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)
	--Unaffected by effect of trap
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetHandler():IsType(TYPE_TRAP) end)
	c:RegisterEffect(e1)
	--Traptrix monster you control can attack in defense position
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DEFENSE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function (e,c) return c:IsSetCard(SET_TRAPTRIX) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
    --Activate(effect)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetCondition(s.condition2)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.activate2)
    e3:SetCountLimit(1,{id,1})
	c:RegisterEffect(e3)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE,SET_TRAP_HOLE}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_TRAPTRIX,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	return true
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not re or re:GetHandler()==e:GetHandler() then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	--if e:GetOwner():GetDestination()>0 and e:GetOwner():GetReasonEffect()==te then return true end --Check if self will go any where else
	-- Above Should implement for check other card too
	local ex,tg,tc
	local categroy_list = {
		CATEGORY_DESTROY, --destroy
		CATEGORY_RELEASE, --tributed
		CATEGORY_REMOVE, --banish
		CATEGORY_TOHAND, --to hand
		CATEGORY_TODECK, --to deck
		CATEGORY_TOGRAVE, --send to grave
		CATEGORY_TOEXTRA, --to extra deck 
		CATEGORY_POSITION} --Change battle position
	for nameCount = 1, 8 do
		ex,tg,tc=Duel.GetOperationInfo(ev,categroy_list[nameCount])
		if ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-#tg>0 then return true end
		ex,tg,tc=Duel.GetPossibleOperationInfo(ev,categroy_list[nameCount])
		if ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-#tg>0 then return true end
	end
	return false
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	--This operation will attempt to apply immediately in any phase enter
	--regardless if there is any monster to summoned or any monster to flip
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE_START+PHASE_DRAW) -- Start of Draw Phase
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)

	local e2=e1:Clone()
	e2:SetCode(EVENT_PHASE_START+PHASE_STANDBY) -- Start of Stand by Phase
	local e3=e1:Clone()
	e3:SetCode(EVENT_PHASE_START+PHASE_MAIN1) -- Start of Main Phase 1
	local e4=e1:Clone()
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE_START) -- Start of Battle Phase
	local e5=e1:Clone()
	e5:SetCode(EVENT_PHASE_START+PHASE_MAIN2) -- Start of Main Phase 2
	local e6=e1:Clone()
	e6:SetCode(EVENT_PHASE+PHASE_END) -- End Phase

	e1:SetLabelObject({e2,e3,e4,e5,e6}) -- Reference each other to reset other effect later
	e2:SetLabelObject({e1,e3,e4,e5,e6})
	e3:SetLabelObject({e1,e2,e4,e5,e6})
	e4:SetLabelObject({e1,e2,e3,e5,e6})
	e5:SetLabelObject({e1,e2,e3,e4,e6})
	e6:SetLabelObject({e1,e2,e3,e4,e5})

	Duel.RegisterEffect(e1,tp) -- Register each of their effect
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterEffect(e4,tp)
	Duel.RegisterEffect(e5,tp)
	Duel.RegisterEffect(e6,tp)
end
function s.spfilter(c,e,tp,turn)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMZoneCount(tp)>0 
	and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp)
end
function s.atfilter(c,xyz,tp) --this is to choose card to be attach to xyz monster
	for xyzc in xyz:Iter() do 
		if c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT) then return true end
	end
	return false
end
function s.atfilter2(c,ac,tp) --This is for choose which xyz to get card attached
	return ac:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ft=Duel.GetMZoneCount(tp)
	local dg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)

	if ft>0 and #dg>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		dg=dg:Select(tp,1,math.min(2,ft),nil)
		
		for sc in dg:Iter() do
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		end
		local xyz=dg:Filter(Card.IsType,nil,TYPE_XYZ)
		if #xyz>0 then
			local xyzc=#xyz
			local ac=Group.CreateGroup()
			local ag=Group.CreateGroup()
			while xyzc>0 do
				if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.atfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,xyz,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					ac=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,xyz,tp)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
					ag=xyz:FilterSelect(tp,s.atfilter2,1,1,nil,ac:GetFirst(),tp)
					if #ag>0 then
						Duel.Overlay(ag:GetFirst(),ac,true)
						xyz:Sub(ag)
						ag:Clear()
						xyzc=xyzc-1
					end
				else
					xyzc=0
				end
			end
			ac:DeleteGroup()
			ag:DeleteGroup()
		end
		s.flip(tp)
		Duel.SpecialSummonComplete()
	else
		s.flip(tp)
	end

	for _, res in ipairs(e:GetLabelObject()) do
		res:Reset()
	end
	e:Reset()
end
function s.flip(tp)
	if Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local fgc = Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_MZONE,0,nil)
		local fg=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,LOCATION_MZONE,0,0,fgc,nil)
		Duel.ChangePosition(fg,POS_FACEUP_DEFENSE)
	end
end