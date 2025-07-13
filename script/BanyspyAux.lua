--Banyspy Aux File
--Duel.LoadScript("BanyspyAux.lua") 


--Load Constant file
Duel.LoadScript("BanyspyConstant.lua")

--------------------------------------------------------------------
----------------------------  Magikular  ---------------------------
--------------------------------------------------------------------

Magikular = {}

function Magikular.SummonSpellTrap(c,tp,attribute,e)
	c:AddMonsterAttribute(TYPE_NORMAL)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(attribute)
	c:RegisterEffect(e2,true)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_SPELLCASTER)
	c:RegisterEffect(e3,true)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetValue(1500)
	c:RegisterEffect(e4,true)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e5,true)
	local e6=e1:Clone()
	e6:SetCode(EFFECT_ADD_SETCODE)
	e6:SetValue(SET_MAGIKULAR)
	c:RegisterEffect(e6,true)
	c:AddMonsterAttributeComplete()
end

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
-----------------------------  Amalgam  ----------------------------
--------------------------------------------------------------------

Amalgam = {}

function Amalgam.AllTypeFromGroup(sg)
	local AllType = 0
	for tc in sg:Iter() do
		AllType = AllType|tc:GetRace() -- bit OR with all card in group
		--Debug.Message("AllType "..AllType)
	end
	return AllType
end

function Amalgam.TypeAmountFromGroup(sg)
	local Amount = 0
	local AllType =  Amalgam.AllTypeFromGroup(sg)
	while AllType > 0 do -- Check each least significant bit, then keep right shift to check other bit, until their are no more to check
		Amount = Amount + (AllType%2) -- Amount value increase by the least significant bit
		AllType = AllType >> 1 --Right shift by 1, basically divide by 2
		--Debug.Message("Amount "..Amount)
	end
	return Amount
end

--------------------------------------------------------------------
----------------------------  Pyrostar  ----------------------------
--------------------------------------------------------------------

Pyrostar = {}

function Pyrostar.HandQuickDestroySummon(c)
	-- destroy and special summon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(655360161,0))--Anyone would use the same string
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,c:GetOriginalCodeRule())
	e1:SetTarget(Pyrostar.HandQuickDestroySummonTarget)
	e1:SetOperation(Pyrostar.HandQuickDestroySummonOperation)
	c:RegisterEffect(e1)
end
function Pyrostar.HandDestroyFilter(c,e,tp)
	return c:IsSetCard(SET_PYROSTAR) and c:IsDestructable(e) and Duel.GetMZoneCount(tp,c)>0
end
function Pyrostar.HandQuickDestroySummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Pyrostar.HandDestroyFilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,c,e,tp)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function Pyrostar.HandQuickDestroySummonOperation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Pyrostar.HandDestroyFilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c,e,tp)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function Pyrostar.AddDestroyBothEffect(c)
	-- destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPosition(POS_FACEUP_ATTACK) end)
	e1:SetTarget(Pyrostar.DestroyBothTarget)
	e1:SetOperation(Pyrostar.DestroyBothOperation)
	c:RegisterEffect(e1)
end
function Pyrostar.DestroyBothTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local t=Duel.GetAttackTarget()
	if chk==0 then
		return (t==c and a:IsDestructable())
			or (a==c and t~=nil and t:IsDestructable())
	end
	local g=Group.CreateGroup()
	if a:IsRelateToBattle() then g:AddCard(a) end
	if t~=nil and t:IsRelateToBattle() then g:AddCard(t) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function Pyrostar.DestroyBothOperation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	Duel.Destroy(rg,REASON_EFFECT)
end

Pyrostar.CreateDestroyTriggerEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
    if category then
	    e1:SetCategory(category)
    end
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
    if property then
        e1:SetProperty(property|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	else
		e1:SetProperty(EFFECT_FLAG_DELAY)
    end
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(target)
	e1:SetOperation(operation)
	-- 655360172 = Pyrostar Short Fuse
	--Also, trigger when used as Fusion, Synchro or Link material when condition is met
	local e2=e1:Clone()
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(function (e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsPlayerAffectedByEffect(tp,655360172) and r&(REASON_FUSION|REASON_SYNCHRO|REASON_LINK)~=0
	end)
	c:RegisterEffect(e2)
	--Also, trigger if detach from Xyz material when condition is met
	local e3=e1:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function (e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsPlayerAffectedByEffect(tp,655360172) and c:IsPreviousLocation(LOCATION_OVERLAY)
	end)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)

	return e1
end,"handler","handlerid","category","property","functg","funcop")

function Pyrostar.SynchroQuickDestroy(c)
	-- destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,c:GetOriginalCodeRule())
	e1:SetTarget(Pyrostar.SynchroQuickDestroyTarget)
	e1:SetOperation(Pyrostar.SynchroQuickDestroyOperation)
	c:RegisterEffect(e1)
end
function Pyrostar.SynchroQuickDestroyFilter(c)
	return c:IsSetCard(SET_PYROSTAR) and c:IsMonster()
end
function Pyrostar.SynchroQuickDestroyTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Pyrostar.SynchroQuickDestroyFilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function Pyrostar.SynchroQuickDestroyOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Pyrostar.SynchroQuickDestroyFilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil)
	if #g>0 then
        Duel.Destroy(g,REASON_EFFECT)
    end
end

--------------------------------------------------------------------
----------------------------  HaunTale  ----------------------------
--------------------------------------------------------------------

HaunTale = {}

function HaunTale.ShuffleFromExtraToReviveSelf(c,id)
	-- Shuffle "HaunTale" pendulum from extra deck to special summon self
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,0})
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(HaunTale.ShuffleFromExtraToReviveSelfTarget)
	e1:SetOperation(HaunTale.ShuffleFromExtraToReviveSelfOperation)
	c:RegisterEffect(e1)
end
function HaunTale.ShuffleFromExtraToReviveSelfFilter(c)
	return c:IsSetCard(SET_HAUNTALE) and c:IsType(TYPE_PENDULUM) and c:IsFaceup()
end
function HaunTale.ShuffleFromExtraToReviveSelfTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and
		Duel.IsExistingMatchingCard(HaunTale.ShuffleFromExtraToReviveSelfFilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function HaunTale.ShuffleFromExtraToReviveSelfOperation(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,HaunTale.ShuffleFromExtraToReviveSelfFilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

function HaunTale.DestroyToSendZombie(c,id)
	--Destroy this card to send zombie from Deck to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(HaunTale.DestroyToSendZombieTarget)
	e1:SetOperation(HaunTale.DestroyToSendZombieOperation)
	c:RegisterEffect(e1)
end
function HaunTale.DestroyToSendZombieFilter(c)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function HaunTale.DestroyToSendZombieTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(HaunTale.DestroyToSendZombieFilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function HaunTale.DestroyToSendZombieOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,HaunTale.DestroyToSendZombieFilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function HaunTale.AddTrapIfDestroyed(c,id)
	--If destroyed add "HaunTale" Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1,{id,2})
	e2:SetTarget(HaunTale.AddTrapIfDestroyedTarget)
	e2:SetOperation(HaunTale.AddTrapIfDestroyedOperation)
	c:RegisterEffect(e2)
end
function HaunTale.AddTrapIfDestroyedFilter(c)
	return c:IsSetCard(SET_HAUNTALE) and c:IsTrap() and c:IsAbleToHand()
end
function HaunTale.AddTrapIfDestroyedTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(HaunTale.AddTrapIfDestroyedFilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function HaunTale.AddTrapIfDestroyedOperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,HaunTale.AddTrapIfDestroyedFilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function HaunTale.SendZombieCostFilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function HaunTale.SendZombieCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(HaunTale.SendZombieCostFilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,HaunTale.SendZombieCostFilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
end

--------------------------------------------------------------------
----------------------------  Grimoire  ----------------------------
--------------------------------------------------------------------

Grimoire = {}

function Grimoire.GetLevelRank(c)
	if c:IsType(TYPE_LINK) then return end
	if c:IsType(TYPE_XYZ) then
		return c:GetRank()
	else
		return c:GetLevel()
	end
end

function Grimoire.DeductLevelRank(itself,c,lv)
	if c:IsType(TYPE_XYZ) then
		local e1=Effect.CreateEffect(itself)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_UPDATE_RANK)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	    e1:SetValue(lv*-1)
	    c:RegisterEffect(e1)
	else
		local e1=Effect.CreateEffect(itself)
	    e1:SetType(EFFECT_TYPE_SINGLE)
	    e1:SetCode(EFFECT_UPDATE_LEVEL)
	    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	    e1:SetValue(lv*-1)
	    c:RegisterEffect(e1)
	end
end

--------------------------------------------------------------------
--------------------------  Tori-No-Kami  --------------------------
--------------------------------------------------------------------

ToriNoKami = {}

function ToriNoKami.ToriNoKamiDontAskMoreThanOnce(tp,e,f)
	if(Duel.GetFlagEffect(tp,REGISTER_FLAG_TORINOKAMI)>0) then 
		if(Duel.GetFlagEffect(tp,REGISTER_FLAG_TORINOKAMI) ==  Duel.GetMatchingGroupCount(f,tp,LOCATION_EXTRA,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(tp,REGISTER_FLAG_TORINOKAMI)
		else
			Duel.RegisterFlagEffect(tp,REGISTER_FLAG_TORINOKAMI,RESET_CHAIN,0,1) 
		end
		return false
	end
	Duel.RegisterFlagEffect(tp,REGISTER_FLAG_TORINOKAMI,RESET_CHAIN,0,1) 
	
	if(Duel.GetMatchingGroupCount(f,tp,LOCATION_EXTRA,0,nil,tp,e) == 1) then
		Duel.ResetFlagEffect(tp,REGISTER_FLAG_TORINOKAMI)
	end

	return true
end

function ToriNoKami.ResetToriNoKamiFlag(tp)
	Duel.ResetFlagEffect(tp,REGISTER_FLAG_TORINOKAMI)
end

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
	e1:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),4))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,{c:GetOriginalCodeRule(),4})
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
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_NETHERSEA_TOKEN,SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function Nethersea.GenerateTokenOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,CARD_NETHERSEA_TOKEN,SET_NETHERSEA,TYPES_TOKEN,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
		local token=Duel.CreateToken(tp,CARD_NETHERSEA_TOKEN+c:GetOriginalCodeRule()-655369001)
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
		for tem=CARD_NETHERSEA_TOKEN,c:GetOriginalCodeRule()+14,1 do
			token:RegisterFlagEffect(REGISTER_FLAG_WEMANY,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		Duel.SpecialSummonComplete()
	end
end

function Nethersea.QuickTributeProc(c)
	--summon with nethersea card on field or s/t
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e0:SetTargetRange(LOCATION_HAND+LOCATION_ONFIELD,0)
	e0:SetTarget(aux.AND(aux.OR(aux.TargetBoolFunction(Card.IsCode,CARD_UMI),aux.AND(aux.TargetBoolFunction(Card.IsRace,RACE_AQUA),aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))),aux.NOT(aux.TargetBoolFunction(Card.IsCode,c:GetOriginalCodeRule()))))
	e0:SetValue(POS_FACEUP)
	c:RegisterEffect(e0)
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetCountLimit(1,{c:GetOriginalCodeRule(),0})
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
------------------------  ProjektStarBlast  ------------------------
--------------------------------------------------------------------

ProjektStarBlast = {}

ProjektStarBlast.CreateActivateDiscardEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation)
	--Activate card normally
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,10))--"Activate"
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
	e1:SetCost(ProjektStarBlast.EffectLimitCost)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	--Discard from hand to apply activate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,11))--"Discard from hand to apply activate effect"
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
		ProjektStarBlast.EffectLimitCost(e,tp,eg,ep,ev,re,r,rp,chk)
    end)
	e2:SetTarget(target)
	e2:SetOperation(operation)

	return e1,e2
end,"handler","handlerid","category","property","functg","funcop")

function ProjektStarBlast.EffectLimitCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(CARD_PROJEKTSTARBLAST_KIANA,14))
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,tp)return not re:GetHandler():IsSetCard(SET_PROJEKTSTARBLAST) end)
	e1:SetReset(ProjektStarBlast.ResetPhaseValue(tp,false))
	Duel.RegisterEffect(e1,tp)
end

function ProjektStarBlast.ResetPhaseValue(tp,extendchk) --tp can be pass just fine
    local phase = Duel.GetCurrentPhase()
	if extendchk==nil then extendchk=true end
    if phase >= PHASE_BATTLE_START and phase <= PHASE_BATTLE then phase = PHASE_BATTLE end
    return RESET_PHASE+phase
end

function ProjektStarBlast.NotActivatedYet(c,tp)
	
	if not (c:IsSetCard(SET_PROJEKTSTARBLAST) and c:IsSpellTrap()) then return end
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

function ProjektStarBlast.CreateShuffleAddEff(c,id)
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
		if chk==0 then return Duel.IsExistingMatchingCard(ProjektStarBlast.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK) 
	end)
	e1:SetOperation(function (e,tp,eg,ep,ev,re,r,rp)
		if not Duel.IsExistingMatchingCard(ProjektStarBlast.NotActivatedYet,tp,LOCATION_DECK,0,1,nil,tp) then return end
		local tc=Duel.SelectMatchingCard(tp,ProjektStarBlast.NotActivatedYet,tp,LOCATION_DECK,0,1,1,nil,tp)
		if tc then 
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end 
	end)
	c:RegisterEffect(e1)
end

--------------------------------------------------------------------
------------------------------  NGNL  ------------------------------
--------------------------------------------------------------------

NGNL = {}

function NGNL.ForceChangeScaleEffect(c)
	--(1) Scale change
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(function(_,tp) return Duel.GetTurnPlayer()==tp end)
	e1:SetTarget(NGNL.ForceChangeScaleEffectTarget)
	e1:SetOperation(NGNL.ForceChangeScaleEffectOperation)
	c:RegisterEffect(e1)
end
function NGNL.ForceChangeScaleEffectTarget(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  op=Duel.SelectOption(tp,aux.Stringid(e:GetHandler():GetOriginalCodeRule(),0),aux.Stringid(e:GetHandler():GetOriginalCodeRule(),1))
  e:SetLabel(op)
  if op==0 then
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
  else
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
  end
end
function NGNL.ForceChangeScaleEffectOperation(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  if e:GetLabel()==0 then
    local dc=Duel.TossDice(tp,1)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LSCALE)
    e1:SetValue(dc)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(e2)
  else
    local d1,d2=Duel.TossDice(tp,2)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_LSCALE)
    e1:SetValue(d1+d2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)--0x1ff0000
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(e2)
  end
end
function NGNL.SpellTrapReturnToHand(c)
	local e2=Effect.CreateEffect(c)
  	e2:SetDescription(aux.Stringid(655368006,1))
  	e2:SetCategory(CATEGORY_TOHAND)
  	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  	e2:SetProperty(EFFECT_FLAG_DELAY)
  	e2:SetCode(EVENT_TO_GRAVE)
  	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT)
		and (e:GetHandler():GetPreviousLocation()==LOCATION_DECK or e:GetHandler():GetPreviousLocation()==LOCATION_HAND) end)
  	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToHand() end
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
	  end)
  	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		if e:GetHandler():IsRelateToEffect(e) and Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)~=0 
		and Duel.ConfirmCards(1-tp,e:GetHandler())~=0 then
		  Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+655368011,e,0,tp,0,0)
		end
	  end)
  	c:RegisterEffect(e2)
end

--------------------------------------------------------------------
-----------------------------  YuYuYu  -----------------------------
--------------------------------------------------------------------

YuYuYu = {}

function YuYuYu.DestroyReplace(c,id)
	local e2=Effect.CreateEffect(c)
  	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  	e2:SetCode(EFFECT_DESTROY_REPLACE)
  	e2:SetRange(LOCATION_GRAVE)
  	e2:SetTarget(YuYuYu.dreptg(id))
  	e2:SetValue(function(e,c) return YuYuYu.drepfilter(c,e:GetHandlerPlayer()) end)
  	e2:SetOperation(YuYuYu.drepop(id))
  	c:RegisterEffect(e2)
end
function YuYuYu.drepfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(SET_YUYUYU) and c:IsRitualMonster() and c:IsControler(tp)
	and c:IsLocation(LOCATION_MZONE) and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function YuYuYu.dreptg(id)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(YuYuYu.drepfilter,1,nil,tp) and eg:GetCount()==1 
		and Duel.GetFlagEffect(tp,id)==0 end
		return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
	end
end
function YuYuYu.drepop(id)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function YuYuYu.DestroyAddRitualSpell(c,id)
	local e1=Effect.CreateEffect(c)
  	e1:SetDescription(aux.Stringid(id,0))
  	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
  	e1:SetType(EFFECT_TYPE_IGNITION)
  	e1:SetRange(LOCATION_PZONE)
  	e1:SetCountLimit(1,id)
  	e1:SetTarget(YuYuYu.destg1)
  	e1:SetOperation(YuYuYu.desop1)
  	c:RegisterEffect(e1)
end
function YuYuYu.thfilter1(c)
  return c:IsSetCard(SET_YUYUYU) and c:IsRitualSpell() and c:IsAbleToHand()
end
function YuYuYu.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsDestructable() and Duel.IsExistingMatchingCard(YuYuYu.thfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function YuYuYu.desop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.Destroy(e:GetHandler(),REASON_EFFECT)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(YuYuYu.thfilter1),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
    end
  end
end
function YuYuYu.TributeAdd(c,id,description)
	local e3=Effect.CreateEffect(c)
  	e3:SetDescription(aux.Stringid(id,description))
  	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  	e3:SetType(EFFECT_TYPE_IGNITION)
  	e3:SetRange(LOCATION_MZONE)
  	e3:SetCountLimit(1)
  	e3:SetCost(YuYuYu.thcost1)
  	e3:SetTarget(YuYuYu.thtg1)
  	e3:SetOperation(YuYuYu.thop1)
  	c:RegisterEffect(e3)
end
function YuYuYu.thcost1(e,tp,eg,ep,ev,re,r,rp,chk)
  	if chk==0 then return e:GetHandler():IsReleasable() end
  	Duel.Release(e:GetHandler(),REASON_COST)
end
function YuYuYu.thfilter2(c)
  	return c:IsSetCard(SET_YUYUYU) and c:IsRitualMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function YuYuYu.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
  	if chk==0 then return Duel.IsExistingMatchingCard(YuYuYu.thfilter2,tp,LOCATION_DECK,0,1,nil) end
  	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function YuYuYu.thop1(e,tp,eg,ep,ev,re,r,rp)
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  	local g=Duel.SelectMatchingCard(tp,YuYuYu.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
  	if g:GetCount()>0 then
    	Duel.SendtoHand(g,nil,REASON_EFFECT)
    	Duel.ConfirmCards(1-tp,g)
  	end
end
function YuYuYu.LeaveFieldAdd(c,id,description)
	local e5=Effect.CreateEffect(c)
  	e5:SetDescription(aux.Stringid(id,description))
  	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  	e5:SetCode(EVENT_LEAVE_FIELD)
  	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  	e5:SetCondition(YuYuYu.thcon2)
  	e5:SetTarget(YuYuYu.thtg2)
  	e5:SetOperation(YuYuYu.thop2)
  	c:RegisterEffect(e5)
end
function YuYuYu.thcon2(e,tp,eg,ep,ev,re,r,rp)
  	local c=e:GetHandler()
  	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
  	and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE)
end
function YuYuYu.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
  	if chk==0 then return Duel.IsExistingMatchingCard(YuYuYu.thfilter1,tp,LOCATION_GRAVE,0,1,nil) end
  	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function YuYuYu.thop2(e,tp,eg,ep,ev,re,r,rp)
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  	local g=Duel.SelectMatchingCard(tp,YuYuYu.thfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
  	if g:GetCount()>0 and Duel.SendtoHand(g,tp,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
    	Duel.ConfirmCards(1-tp,g)
    	Duel.Recover(tp,500,REASON_EFFECT)
  	end
end

--------------------------------------------------------------------
-------------------------------  HN  -------------------------------
--------------------------------------------------------------------

HN = {}

function HN.HasNeptuneInName(c) --Hardcode for card with name in it
	return c:IsCode({	655368041,	--HN CPU Neptune
						655368051,	--HN UD Neptune
						655368056,	--HN Histoire, Planeptune's Oracle
						655368098})	--HN Nation Planeptune (In case it somehow become monster,haha)
end

function HN.HasNoireInName(c) --Hardcode for card with name in it
	return c:IsCode({	655368042})	--HN CPU Noire
end

function HN.HasBlancInName(c) --Hardcode for card with name in it
	return c:IsCode({	655368043})	--HN CPU Blanc
end

function HN.HasVertInName(c) --Hardcode for card with name in it
	return c:IsCode({	655368044})	--HN CPU Vert
end

function HN.LinkReviveOtherOnSummon(c,id)
	local e1=Effect.CreateEffect(c)
  	e1:SetDescription(aux.Stringid(id,0))
  	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
  	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
  	e1:SetTarget(HN.sptg)
  	e1:SetOperation(HN.spop)
  	c:RegisterEffect(e1)
end
function HN.spfilter(c,e,tp,zone)
  return c:IsSetCard(SET_HN) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function HN.spzonefilter(c,e,tp,sc)
  return c:IsSetCard(SET_HN) and c:IsType(TYPE_LINK)
end
function HN.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local zone=0
  local g1=Duel.GetMatchingGroup(HN.spzonefilter,tp,LOCATION_MZONE,0,nil)
  for tc in aux.Next(g1) do
    zone=zone | tc:GetLinkedZone()
  end
  zone = zone & 0x1f
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
  and Duel.IsExistingTarget(HN.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectTarget(tp,HN.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function HN.spop(e,tp,eg,ep,ev,re,r,rp)
  local zone=0
  local g=Duel.GetMatchingGroup(HN.spzonefilter,tp,LOCATION_MZONE,0,nil)
  for tc in aux.Next(g) do
    zone=zone | tc:GetLinkedZone()
  end
  zone = zone & 0x1f
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and zone~=0 then 
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
  end
end
function HN.AddOrPlaceOnSummon(c,id,card) --For Nations card since they have exact repeat effect
	--(1) Search
	local e1=Effect.CreateEffect(c)
  	e1:SetDescription(aux.Stringid(id,0))
  	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  	e1:SetProperty(EFFECT_FLAG_DELAY)
  	e1:SetCode(EVENT_SUMMON_SUCCESS)
  	e1:SetCountLimit(1,id)
  	e1:SetTarget(HN.thtg(card))
  	e1:SetOperation(HN.thop(card))
  	c:RegisterEffect(e1)
  	--(2) Place in S/T Zone
  	local e2=Effect.CreateEffect(c)
  	e2:SetDescription(aux.Stringid(id,1))
  	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  	e2:SetProperty(EFFECT_FLAG_DELAY)
  	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  	e2:SetCountLimit(1,{id,1})
  	e2:SetCondition(function() return Duel.IsBattlePhase() end)
  	e2:SetTarget(HN.stztg(card))
  	e2:SetOperation(HN.stzop(card))
  	c:RegisterEffect(e2)
end
function HN.thfilter_con(c,card)
  	return c:IsCode(card) and c:IsAbleToHand()
end
function HN.thtg(card)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  		if chk==0 then return Duel.IsExistingMatchingCard(HN.thfilter_con,tp,LOCATION_DECK,0,1,nil,card) end
  		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function HN.thop(card)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local tc=Duel.GetFirstMatchingCard(HN.thfilter_con,tp,LOCATION_DECK,0,nil,card)
  		if tc then
    		Duel.SendtoHand(tc,nil,REASON_EFFECT)
    		Duel.ConfirmCards(1-tp,tc)
  		end
	end
end
function HN.stzfilter(c,tp,card)
  	return c:IsCode(card) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function HN.stztg(card)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
  		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
			and Duel.IsExistingMatchingCard(HN.stzfilter,tp,LOCATION_DECK,0,1,nil,tp,card) end
  		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	end
end
function HN.stzop(card)
	return function(e,tp,eg,ep,ev,re,r,rp)
  		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
  		local tc=Duel.GetFirstMatchingCard(HN.stzfilter,tp,LOCATION_DECK,0,nil,tp,card)
  		if tc then
    		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
  		end
	end
end
function HN.HDDNextCommonEffect(c,id,card) 
	--(1) Gain additional effect --Your opponent cannot response if it xyz summon with certain material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1 end)
	e0:SetOperation(function(id) return function(e)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))
	  end end)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(function(card) return function(e,c)
		if c:GetMaterial():IsExists(Card.IsCode,1,nil,card) then
		  	e:GetLabelObject():SetLabel(1)
		else
		  	e:GetLabelObject():SetLabel(0)
		end
	  end end)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--(1.1) Cannot chain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(id) return function (e) return e:GetHandler():GetFlagEffect(id)>0 end end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) 
		if re:GetHandler()==e:GetHandler() then 
			Duel.SetChainLimit(function(e,ep,tp) return ep==tp end) 
		end 
	end)
	c:RegisterEffect(e2)
	--(3) Special Summon 
	-- At the end of the Damage Step, if this card attacked an opponent's monster: 
	-- You can Special Summon 1 [name] from your GY, and if you do, attach this card to it as material. 
	-- (Transfer its materials to that monster.)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCountLimit(1,id)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget() end)
	e4:SetTarget(HN.revtg(card))
	e4:SetOperation(HN.revop(card))
	c:RegisterEffect(e4)
end
function HN.revfilter(c,e,tp,card)
	return c:IsCode(card) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function HN.revtg(card)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(HN.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,card) end
		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end
function HN.revop(card)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		if Duel.GetMZoneCount(tp)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,HN.revfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,card)
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		and c:IsFaceup() and c:IsRelateToEffect(e) then
	  	local mg=c:GetOverlayGroup()
	  	if #mg>0 then Duel.Overlay(tc,mg) end
	  		Duel.Overlay(tc,Group.FromCards(c))
		end
	end
end

--------------------------------------------------------------------
------------------------------  DAL  -------------------------------
--------------------------------------------------------------------

DAL = {}

function DAL.CreateAddSpaceQuakeOnSummonEffect(c,normal)
	if normal==nil then normal=true end
	--(1) Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,c:GetOriginalCodeRule())
	e1:SetTarget(DAL.CreateAddSpaceQuakeOnSummonTarget)
	e1:SetOperation(DAL.CreateAddSpaceQuakeOnSummonOperation)
	c:RegisterEffect(e1)
	if normal then
		local e2=e1:Clone()
		e2:SetCode(EVENT_SUMMON_SUCCESS)
		c:RegisterEffect(e2)
	end
end
function DAL.CreateAddSpaceQuakeOnSummonFilter(c)
  	return c:IsCode(CARD_DAL_SPACEQUAKE) and c:IsAbleToHand()
end
function DAL.CreateAddSpaceQuakeOnSummonTarget(e,tp,eg,ep,ev,re,r,rp,chk)
  	if chk==0 then return Duel.IsExistingMatchingCard(DAL.CreateAddSpaceQuakeOnSummonFilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
  	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function DAL.CreateAddSpaceQuakeOnSummonOperation(e,tp,eg,ep,ev,re,r,rp)
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(DAL.CreateAddSpaceQuakeOnSummonFilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
  	if #g>0 then
    	Duel.SendtoHand(g,nil,REASON_EFFECT)
    	Duel.ConfirmCards(1-tp,g)
  	end
end

function DAL.CreateTributeSummonListedMonsterEffect(c,name,loc)
	if loc==nil then loc = LOCATION_HAND+LOCATION_DECK end
	local e4=Effect.CreateEffect(c)
  	e4:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),1))
  	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
  	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  	e4:SetCode(EVENT_CHAINING)
  	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
  	e4:SetRange(LOCATION_MZONE)
  	e4:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return rp~=tp end)
  	e4:SetCost(function (e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsReleasable() end
		Duel.Release(e:GetHandler(),REASON_COST)
	  end)
  	e4:SetTarget(DAL.CreateTributeSummonListedMonsterTarget(name,loc))
  	e4:SetOperation(DAL.CreateTributeSummonListedMonsterOperation(name,loc))
  	c:RegisterEffect(e4)
end
function DAL.CreateTributeSummonListedMonsterFilter(c,e,tp,name,loc,chk)
	if not (c:IsCode(name) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return end
	local tribute=e:GetHandler()
	if chk then tribute=nil end
	if loc==LOCATIO_EXTRA then
		return Duel.GetLocationCountFromEx(tp,tp,tribute,c)>0
	else
  		return Duel.GetMZoneCount(tp,tribute)>0
	end
end
function DAL.CreateTributeSummonListedMonsterTarget(name,loc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
  		if chk==0 then return Duel.IsExistingMatchingCard(DAL.CreateTributeSummonListedMonsterFilter,tp,loc,0,1,nil,e,tp,name,loc,false) end
  		Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
	end
end
function DAL.CreateTributeSummonListedMonsterOperation(name,loc)
	return function(e,tp,eg,ep,ev,re,r,rp)
  		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  		local g=Duel.SelectMatchingCard(tp,DAL.CreateTributeSummonListedMonsterFilter,tp,loc,0,1,1,nil,e,tp,name,loc,true)
  		if #g>0 then
    		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  		end
	end
end

DAL.CreateOnSummonByDALEff = aux.FunctionWithNamedArgs(
function(c,id,category,property,target,operation,notriggerself)
	if category==nil then category=0 end
	if property==nil then property=0 end
	if notriggerself==nil then notriggerself=false end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(category)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY|property)
	e1:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) 
		return re and re:GetHandler():IsSetCard(SET_DAL) and re:IsHasType(EFFECT_TYPE_ACTIONS)
		and not (notriggerself and re:GetHandler():IsCode(id)) end)
	e1:SetTarget(target)
	e1:SetOperation(operation)
	c:RegisterEffect(e1)
end,"handler","handlerid","category","property","functg","funcop","notriggerself")

function DAL.CreateSummonLv3OnDestroyByEffectEff(c)
	--(3) Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(c:GetOriginalCodeRule(),3))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(DAL.CreateSummonLv3OnDestroyByEffectTarget)
	e3:SetOperation(DAL.CreateSummonLv3OnDestroyByEffectOperation)
	c:RegisterEffect(e3)
end
function DAL.CreateSummonLv3OnDestroyByEffectFilter(c,e,tp)
	return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function DAL.CreateSummonLv3OnDestroyByEffectTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsExistingMatchingCard(DAL.CreateSummonLv3OnDestroyByEffectFilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function DAL.CreateSummonLv3OnDestroyByEffectOperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,DAL.CreateSummonLv3OnDestroyByEffectFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
	  Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--------------------------------------------------------------------
--------------------------  Boss Battle  ---------------------------
--------------------------------------------------------------------

Boss = {}

function Boss.TotalImmunity(c)
	--Unnafected by any cards' effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_ALL)
	e1:SetValue(function (e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e1)
    --cannot remove
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_ALL)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(function (e,c,p)return e:GetHandler()==c end)
	c:RegisterEffect(e3)
    --indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetRange(LOCATION_ALL)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e3)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
    --cannot release
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_ALL)
	e6:SetCode(EFFECT_UNRELEASABLE_SUM)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e7)
    --Cannot used as material
    local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e8:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK,SUMMON_TYPE_RITUAL))
	c:RegisterEffect(e8)
    --Cannot be send to GY
    local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9:SetRange(LOCATION_ALL)
	e9:SetCode(EFFECT_CANNOT_TO_GRAVE)
	e9:SetValue(1)
	c:RegisterEffect(e9)
    local e9b=e9:Clone()
	e9b:SetType(EFFECT_TYPE_FIELD)
	e9b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e9b:SetTargetRange(1,1)
	e9b:SetTarget(function (e,c,p)return e:GetHandler()==c end)
	c:RegisterEffect(e9b)
    --Cannot be send to GY as cost
    local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e10:SetRange(LOCATION_ALL)
	e10:SetCode(EFFECT_CANNOT_TO_GRAVE_AS_COST)
	e10:SetValue(1)
	c:RegisterEffect(e10)
    local e10b=e10:Clone()
	e10b:SetType(EFFECT_TYPE_FIELD)
	e10b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e10b:SetTargetRange(1,1)
	e10b:SetTarget(function (e,c,p)return e:GetHandler()==c end)
	c:RegisterEffect(e10b)
	--Cannot be send to hand
    local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11:SetRange(LOCATION_ALL)
	e11:SetCode(EFFECT_CANNOT_TO_HAND)
	e11:SetValue(1)
	c:RegisterEffect(e11)
    local e11b=e11:Clone()
	e11b:SetType(EFFECT_TYPE_FIELD)
	e11b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e11b:SetTargetRange(1,1)
	e11b:SetTarget(function (e,c,p)return e:GetHandler()==c end)
	c:RegisterEffect(e11b)
	--Cannot be send to Deck
    local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_SINGLE)
	e12:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e12:SetRange(LOCATION_ALL)
	e12:SetCode(EFFECT_CANNOT_TO_DECK)
	e12:SetValue(1)
	c:RegisterEffect(e12)
    local e12b=e12:Clone()
	e12b:SetType(EFFECT_TYPE_FIELD)
	e12b:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e12b:SetTargetRange(1,1)
	e12b:SetTarget(function (e,c,p)return e:GetHandler()==c end)
	c:RegisterEffect(e12b)
end

--Legacy Code
--[[
function ProjektStarBlast.NormalSummonCondition(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg1=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return ((Duel.GetMZoneCount(tp)<=0 and #mg1>0) or #mg2>0)
end

function ProjektStarBlast.NormalSummonTarget(e,tp,eg,ep,ev,re,r,rp,c)
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

function ProjektStarBlast.NormalSummonOperation(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Release(sg,REASON_COST)
	sg:DeleteGroup()
end
]]