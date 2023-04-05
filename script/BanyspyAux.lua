--Banyspy Aux File

--Load Constant file
Duel.LoadScript("BanyspyConstant.lua")

--------------------------------------------------------------------
----------------------------  Zodragon  ----------------------------
--------------------------------------------------------------------

Zodragon = {}

function Zodragon.SummonLimit(c)
    --summon cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCost(Zodragon.summoncost)
	e1:SetOperation(Zodragon.summonop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SUMMON_COST)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetCode(EFFECT_FLIPSUMMON_COST)
    c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_NORMALSUMMON,Zodragon.counterfilter)
    Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_SPSUMMON,Zodragon.counterfilter)
    Duel.AddCustomActivityCounter(LIMIT_COUNTER,ACTIVITY_FLIPSUMMON,Zodragon.counterfilter)
end
function Zodragon.counterfilter(c)
	return c:IsSetCard(SET_ZODRAGON)
end
function Zodragon.summoncost(e,c,tp)
	return Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_NORMALSUMMON)==0
    and Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_SPSUMMON)==0
    and Duel.GetCustomActivityCount(LIMIT_COUNTER,tp,ACTIVITY_FLIPSUMMON)==0
end
function Zodragon.summonop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(LIMIT_COUNTER,15))
	e1:SetTargetRange(1,0)
	e1:SetTarget(Zodragon.summonlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
end
function Zodragon.summonlimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(SET_ZODRAGON)
end

--------------------------------------------------------------------
-----------------------------  Reoyin  -----------------------------
--------------------------------------------------------------------

Reoyin = {}

function Reoyin.MassSummonLegalityCheck(g,tp)
    local MustLink
    if Duel.IsDuelType(DUEL_FSX_MMZONE) then --DUEL_FSX_MMZONE = Fusion/Syncheo/Xyz to Main Monster Zone Rule (MR4 Revision)
        MustLink = TYPE_PENDULUM|TYPE_LINK
    else
        MustLink = TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK
    end
    local ExMustLink    =g:FilterCount(function(c)return c:IsType(MustLink) and c:IsLocation(LOCATION_EXTRA) end,nil )
    local ExNoMustLink  =g:FilterCount(function(c)return (not c:IsType(MustLink)) and c:IsLocation(LOCATION_EXTRA) end,nil)
    local NotEx         =g:FilterCount(function(c)return not c:IsLocation(LOCATION_EXTRA) end,nil)
    local MMZONE= Duel.GetMZoneCount(tp) -- Get Available Main monster zone
    local EXZONE,Masked= Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK) -- Get Available monster zone from extra for monster that require linked zone
    local EMZONE
    Masked = (ZONES_EMZ|ZONES_MMZ) & ~Masked --Need to shift first since apparently, 1 is not available zone, while 0 is opposite
    if (Masked & ZONES_EMZ)>0 then EMZONE=1 else EMZONE=0 end -- If among available monster zone from extra has extra monster zone
    --Debug.Message("ExMustLink: ".. ExMustLink)
    --Debug.Message("ExNoMustLink: ".. ExNoMustLink)
    --Debug.Message("NotEx: ".. NotEx)
    --Debug.Message("MMZONE: ".. MMZONE)
    --Debug.Message("EXZONE: ".. EXZONE)
    --Debug.Message("Masked: ".. Masked)
    --Debug.Message("EMZONE: ".. EMZONE)
    return ExMustLink+ExNoMustLink+NotEx>0 and (EXZONE >= ExMustLink) and (MMZONE+EMZONE >= ExMustLink+ExNoMustLink+NotEx)
    and (ExMustLink+ExNoMustLink+NotEx==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
end

--------------------------------------------------------------------
--------------------------  Setsugebishin  -------------------------
--------------------------------------------------------------------

Setsugebishin = {}

Setsugebishin.CreateTargetFlipEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	--Trigger upon being targeted by card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
    if category then
	    e1:SetCategory(category)
    end
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BECOME_TARGET)
    if property then
        e1:SetProperty(property)
    end
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function (e,tp,eg) return eg:IsContains(e:GetHandler()) end)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	
    --Can be activate as quick effect if being in face-down position
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    if category then
	    e2:SetCategory(category)
    end
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    if property then
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE|property)
    else
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    end
    e2:SetCountLimit(1,{id,0})
    e2:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
    end)
	e2:SetCondition(function(e) return e:GetHandler():IsFacedown() end)
	e2:SetTarget(target)
	e2:SetOperation(operation)

	return e1,e2
end,"handler","handlerid","category","property","functg","funcop")

--------------------------------------------------------------------
----------------------------  Nethersea  ---------------------------
--------------------------------------------------------------------

Nethersea = {}

function Nethersea.NetherseaMonsterOrWQ(c)
	return c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER)
end

function Nethersea.NetherseaCardOrWQ(c)
	return c:IsCode(CARD_UMI) or (c:IsMonster() and c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_WATER))
end

function Nethersea.GenerateToken(c)
    --token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),4))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,{c:GetOriginalCode(),4})
	e1:SetTarget(Nethersea.GenerateTokenTarget)
	e1:SetOperation(Nethersea.GenerateTokenOperation)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCondition(Nethersea.GenerateTokenConditionToNotRepeatAsk)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_RELEASE)
    c:RegisterEffect(e3)
end
function Nethersea.GenerateTokenConditionToNotRepeatAsk(e)
    return not e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function Nethersea.GenerateTokenTarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local id=e:GetHandler():GetOriginalCode()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,Nethersea.TokenID(id),SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function Nethersea.GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
    local id=e:GetHandler():GetOriginalCode()
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,Nethersea.TokenID(id),SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,Nethersea.TokenID(id))
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		--Debug.Message(Nethersea.TokenID(id))
		--Cannot Special Summon monsters except WATER Aqua/Thunder/Fish/Sea serpent
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		--Clock Lizard check
		local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
	end
end

function Nethersea.TokenID(id)
	return 655360100+((id-655360100)*20)
end

function Nethersea.QuickTributeProc(c)
	--summon with nethersea card on field or s/t
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_HAND+LOCATION_ONFIELD,0)
	e0:SetTarget(aux.AND(aux.OR(aux.TargetBoolFunction(Card.IsCode,CARD_UMI),aux.AND(aux.TargetBoolFunction(Card.IsRace,RACE_AQUA),aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))),aux.NOT(aux.TargetBoolFunction(Card.IsCode,c:GetOriginalCode()))))
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCode(),0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,{c:GetOriginalCode(),0})
	e1:SetTarget(Nethersea.QuickTributeProcTarget)
	e1:SetOperation(Nethersea.QuickTributeProcOperation)
	c:RegisterEffect(e1)
end
function Nethersea.QuickTributeProcTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil,1) or c:IsMSetable(true,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function Nethersea.QuickTributeProcOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local pos=0
	if c:IsSummonable(true,nil,1) then pos=pos+POS_FACEUP_ATTACK end
	if c:IsMSetable(true,nil,1) then pos=pos+POS_FACEDOWN_DEFENSE end
	if pos==0 then return end
	--Workaround Spell/Trap sent to GY before choose to tribute if you activate quick tribute as chain link 1
	--Make Spell/trap stuck on the field until monster summon
	local g=Duel.GetMatchingGroup(Nethersea.WorkaroundPreventSTtoGYFilter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
	if  ((Duel.GetCurrentChain(true))==1) and (#g>0)then
		local tg=g:GetFirst()
		for tg in aux.Next(g) do
			tg:CancelToGrave()
			local e1=Effect.CreateEffect(tg)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SUMMON)
			e1:SetRange(LOCATION_SZONE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetOperation(Nethersea.WorkaroundSTtoGraveBeforeTributeOperation)
			tg:RegisterEffect(e1)
		end
	end
	if Duel.SelectPosition(tp,c,pos)==POS_FACEUP_ATTACK then
		Duel.Summon(tp,c,true,nil,1)
	else
		Duel.MSet(tp,c,true,nil,1)
	end
end

function Nethersea.WorkaroundPreventSTtoGYFilter(c)
	return c:IsCode(CARD_UMI) and c:IsSpellTrap() and not c:IsType(TYPE_CONTINUOUS|TYPE_FIELD|TYPE_EQUIP)
end

function Nethersea.WorkaroundSTtoGraveBeforeTributeOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoGrave(e:GetHandler(),REASON_RULE)
end

function Nethersea.WeManyDontAskMoreThanOnce(tp,e,f)
	if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY)>0) then 
		if(Duel.GetFlagEffect(tp,REGISTER_FLAG_WEMANY) ==  Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
		else
			Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,RESET_PHASE+PHASE_END,0,1) 
		end
		return false
	end
	Duel.RegisterFlagEffect(tp,REGISTER_FLAG_WEMANY,RESET_PHASE+PHASE_END,0,1) 
	
	if(Duel.GetMatchingGroupCount(f,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
		Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
	end

	return true
end

function Nethersea.ResetWeManyFlag(tp)
	Duel.ResetFlagEffect(tp,REGISTER_FLAG_WEMANY)
end

--This workaround is because apparently IsReleasable() and IsReleasableByEffect() always return false for spell/trap in hand
--So the clostest checking is if it's spell/trap in hand, and if the monster that activated in hand can be tributed
--If monster that also in hand can be tributed, spell/trap in hand also likely can be tributed too
--or if player is not affected by thing like masked of restricted or fog king
--It isn't perfect but it's what can be do, for now
function Nethersea.WorkaroundTributeSTinHandCheck(c,tp)
	return c:IsSpellTrap() and c:IsLocation(LOCATION_HAND)
	and (Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_HAND,0,1,nil) or Duel.IsPlayerCanRelease(tp))
end

--spsummon limit
function Nethersea.SpecialSummonLimit(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not (c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_FISH|RACE_SEASERPENT)) end)
	c:RegisterEffect(e1)
end

--Also treated as "Umi"
function Nethersea.AlsoTreatedAsUmi(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(CARD_UMI)
	c:RegisterEffect(e1)
end

--Attribute and race cannot be changed as rule
function Nethersea.CannotChangeAttributeRace(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return 
		te:GetCode()&EFFECT_ADD_RACE==EFFECT_ADD_RACE or 
		te:GetCode()&EFFECT_REMOVE_RACE==EFFECT_REMOVE_RACE or 
		te:GetCode()&EFFECT_CHANGE_RACE==EFFECT_CHANGE_RACE or 
		te:GetCode()&EFFECT_ADD_ATTRIBUTE==EFFECT_ADD_ATTRIBUTE or
		te:GetCode()&EFFECT_REMOVE_ATTRIBUTE==EFFECT_REMOVE_ATTRIBUTE or
		te:GetCode()&EFFECT_CHANGE_ATTRIBUTE==EFFECT_CHANGE_ATTRIBUTE end)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_ALL)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCondition(function(e) return not (e:GetHandler():GetAttribute() == e:GetHandler():GetOriginalAttribute()) end)
	e2:SetOperation(function(e) 
		local changeAdd = e:GetHandler():GetCardEffect(EFFECT_ADD_ATTRIBUTE)
		local changeChange = e:GetHandler():GetCardEffect(EFFECT_CHANGE_ATTRIBUTE)
		local changeRemove = e:GetHandler():GetCardEffect(EFFECT_REMOVE_ATTRIBUTE)
		if(changeAdd~=nil and changeAdd:GetType()&EFFECT_TYPE_SINGLE~=0 and changeAdd:GetHandler()==e:GetHandler()) then
			changeAdd:Reset() end
		if(changeChange~=nil and changeChange:GetType()&EFFECT_TYPE_SINGLE~=0 and changeChange:GetHandler()==e:GetHandler()) then
			changeChange:Reset() end
		if(changeRemove~=nil and changeRemove:GetType()&EFFECT_TYPE_SINGLE~=0 and changeRemove:GetHandler()==e:GetHandler()) then
			changeRemove:Reset() end
	end)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_ALL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(function(e) return not (e:GetHandler():GetRace() == e:GetHandler():GetOriginalRace()) end)
	e3:SetOperation(function(e) 
		local changeAdd = e:GetHandler():GetCardEffect(EFFECT_ADD_RACE)
		local changeChange = e:GetHandler():GetCardEffect(EFFECT_CHANGE_RACE)
		local changeRemove = e:GetHandler():GetCardEffect(EFFECT_REMOVE_RACE)
		if(changeAdd~=nil and changeAdd:GetType()&EFFECT_TYPE_SINGLE~=0 and changeAdd:GetHandler()==e:GetHandler()) then
			changeAdd:Reset() end
		if(changeChange~=nil and changeChange:GetType()&EFFECT_TYPE_SINGLE~=0 and changeChange:GetHandler()==e:GetHandler()) then
			changeChange:Reset() end
		if(changeRemove~=nil and changeRemove:GetType()&EFFECT_TYPE_SINGLE~=0 and changeRemove:GetHandler()==e:GetHandler()) then
			changeRemove:Reset() end
	end)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------
---------------------------  Mei Misaki  ---------------------------
--------------------------------------------------------------------

MeiMisaki = {}

MeiMisaki.CreateActivateDiscardEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	--Activate card normally
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(CARD_MEI_MISAKI,10))--"Activate"
	if category then
	    e1:SetCategory(category)
    end
    if property then
        e1:SetProperty(property)
    end
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	--Discard from hand to apply activate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(CARD_MEI_MISAKI,11))--"Discard from hand to apply activate effect"
	if category then
	    e2:SetCategory(category)
    end
    if property then
        e2:SetProperty(property)
    end
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return e:GetHandler():IsDiscardable() end
        Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
    end)
	e2:SetTarget(target)
	e2:SetOperation(operation)

	return e1,e2
end,"handler","handlerid","category","property","functg","funcop")

function MeiMisaki.ResetPhaseValue(tp) --tp can be pass just fine
    local phase = Duel.GetCurrentPhase()
    if phase >= PHASE_BATTLE_START and phase <= PHASE_BATTLE then phase = PHASE_BATTLE end
    return RESET_PHASE+phase
end

function MeiMisaki.NormalSummonCondition(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return ((Duel.GetMZoneCount(tp)<=0 and #mg1>0) or #mg2>0)
end

function MeiMisaki.NormalSummonTarget(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local tc
	local cancel=(Duel.IsSummonCancelable() or Duel.GetMZoneCount(tp)>0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if(Duel.GetMZoneCount(tp)<=0) then
		tc=mg1:SelectUnselect(nil,tp,false,cancel,1,1)
	else
		tc=mg2:SelectUnselect(nil,tp,false,cancel,1,1)
	end
	if tc then
		g1=Group.CreateGroup()
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	else return false end
end

function MeiMisaki.NormalSummonOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Release(sg,REASON_COST)
	sg:DeleteGroup()
end

function MeiMisaki.NotActivatedYet(c,tp)
	
	if not (c:ListsCode(CARD_MEI_MISAKI) and c:IsSpellTrap()) then return end
	local ACT1=c:GetCardEffect()
	--local Count1,Count2,Count3,Count4,Count5,Count6 = ACT1:GetCountLimit()
	--local Count4,Count5,Count6 = ACT2:GetCountLimit()
	local ACTbool = ACT1:CheckCountLimit(tp)
	--Debug.Message("Card ID: " .. c:GetOriginalCode() ) --These are for checking if things work as intended
	--Debug.Message("Count1 Count: " ..Count1)
	--Debug.Message("Count2 Count: " ..Count2)
	--Debug.Message("Count3 Count: " ..Count3)
	--Debug.Message("Count4 Count: " ..Count4)
	--Debug.Message("Count5 Count: " ..Count5)
	--Debug.Message("Count6 Count: " ..Count6)
	--Debug.Message("ACTbool: " ..tostring(ACTbool))
	return ACTbool
end

function MeiMisaki.CreateShuffleAddEff(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetCountLimit(1,{id,1})
	e1:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST) 
	end)
	e1:SetTarget(function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) 
	end)
	e1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
		if not Duel.IsExistingMatchingCard(MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) then return end
		local tc=Duel.SelectMatchingCard(tp,MeiMisaki.NotActivatedYet,tp,LOCATION_DECK,0,1,1,nil,tp)
		if tc then 
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end 
	end)
	c:RegisterEffect(e1)
end