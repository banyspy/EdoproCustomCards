--Setsugebishin the Floren
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set
	c:EnableUnsummonable()
	--Special summon procedure (from hand)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,1})
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--Add 1 Plant from GY upon being target
	local e1,e2=Setsugebishin.CreateTargetFlipEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND,
		functg=s.thtg,
		funcop=s.thop})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
	--attach s/t
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_names={CARD_NO_87_QUEEN_OF_THE_NIGHT}--Queen of the night
function s.spcfilter(c)
	return c:IsCode(CARD_NO_87_QUEEN_OF_THE_NIGHT) and not c:IsPublic()
end
function s.spcon(e,c)
	local c=e:GetHandler()
	if c==nil then return true end
	local tp=c:GetControler()
	local hg=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_EXTRA,0,nil)
	return #hg>0 and Duel.GetMZoneCount(tp)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_EXTRA,0,0,1,nil)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.ConfirmCards(1-tp,g)
	g:DeleteGroup()
end
function s.thfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsMonster() and c:IsAbleToHand()
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then 
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP_DEFENSE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_PLANT and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.xtarget(c,e)
	return c:IsSpellTrap() and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.xtarget,tp,0,LOCATION_ONFIELD,1,nil,e) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,s.xtarget,tp,0,LOCATION_ONFIELD,1,1,nil,e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
