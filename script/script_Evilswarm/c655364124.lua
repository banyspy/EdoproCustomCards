-- Evilswarm Suprebellium
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	-- 3 Level 12 monsters
	Xyz.AddProcedure(c,nil,12,3)
	--Enable pendulum summon
	Pendulum.AddProcedure(c,false)
	--cannot be target
	local pe1=Effect.CreateEffect(c)
	pe1:SetType(EFFECT_TYPE_FIELD)
	pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	pe1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetTargetRange(LOCATION_MZONE,0)
	pe1:SetTarget(function (e,c) return c:IsSetCard(SET_LSWARM) end)
	pe1:SetValue(aux.tgoval)
	c:RegisterEffect(pe1)
	--special summon
	local pe2=Effect.CreateEffect(c)
	pe2:SetDescription(aux.Stringid(id,0))
	pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	pe2:SetType(EFFECT_TYPE_IGNITION)
	pe2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	pe2:SetRange(LOCATION_PZONE)
	pe2:SetCountLimit(1,id)
	pe2:SetTarget(s.sptg)
	pe2:SetOperation(s.spop)
	c:RegisterEffect(pe2)
	--spsummon limit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.xyzlimit)
	c:RegisterEffect(e0)
	-- Can use "lswarm" Xyz or Link monster as Level 12 materials
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0b:SetCode(EFFECT_XYZ_LEVEL)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0b:SetTarget(function(e,c) return c:IsSetCard(SET_LSWARM) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)) end)
	e0b:SetValue(function(e,_,rc) return rc==e:GetHandler() and 12 or 0 end)
	c:RegisterEffect(e0b)
	--Remove upon Xyz summon with xyz and/or link
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--place in pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE|LOCATION_REMOVED|LOCATION_EXTRA)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsFaceup() end)
	e3:SetTarget(s.pctg)
	e3:SetOperation(s.pcop)
	c:RegisterEffect(e3)
	--Either change level or disable field, until the end of the turn
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER)
	e4:SetCountLimit(1,{id,3})
	e4:SetCost(s.effcost)
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_INFESTATION,SET_LSWARM}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_LSWARM) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,math.max(3,#g),0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g,true)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_XYZ|TYPE_LINK,c,SUMMON_TYPE_XYZ,e:GetHandlerPlayer()) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckPendulumZones(tp) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.CheckPendulumZones(tp)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.costchk(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_LSWARM) and sg:IsExists(Card.IsSetCard,1,nil,SET_INFESTATION)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,e:GetHandler())
	sg=sg:Filter(Card.IsSetCard,nil,{SET_LSWARM,SET_INFESTATION})
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and aux.SelectUnselectGroup(sg,e,tp,2,2,s.costchk,0) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=aux.SelectUnselectGroup(sg,e,tp,2,2,s.costchk,1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_SZONE,PLAYER_NONE,0)>0
	if chk==0 then return true end
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,4)},
        {b2,aux.Stringid(id,5)})
	Duel.SetTargetParam(op)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if op==1 then s.lvop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then s.zoneop(e,tp,eg,ep,ev,re,r,rp)end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp)
	--Change level
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetTargetRange(0,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED)
	e1:SetValue(lv)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.zoneop(e,tp,eg,ep,ev,re,r,rp)
    local dis=Duel.SelectDisableField(tp,2,0,LOCATION_ONFIELD,0)
	Duel.Hint(HINT_ZONE,tp,dis)
	--Disable the chosen zone
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(dis)
	e1:SetOperation(function(e) return e:GetLabel() end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	Duel.RegisterEffect(e1,tp)
end