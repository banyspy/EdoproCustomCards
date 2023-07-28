-- Malefic Axiom Dragon
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(1,0,id)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(s.nontunerfilter),1,99,s.tunerfilter,nil,nil)
	--Self-destruct
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(s.descon)
    c:RegisterEffect(e1)
	--search and add to hand or banish
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
    --Increase its own ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.adval)
	c:RegisterEffect(e3)
	--Tribute 1 "malefic" monster to special summon other ignoring its summoning condition
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_MALEFIC}
s.listed_names={27564031}--Malefic World
s.synchro_nt_required=1
--Can treat a "Malefic" monster as a Tuner
function s.tunerfilter(c,scard,sumtype,tp)
	return c:IsSetCard(SET_MALEFIC,scard,sumtype,tp)
end
function s.nontunerfilter(c)
	return c:GetAttack()+c:GetDefense()>=5000
end
function s.descon(e)
	return not (Duel.IsEnvironment(27564031) or
		Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsFieldSpell),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.cfilter(c)
	return c:IsSetCard(SET_MALEFIC) and (c:IsAbleToHand())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_SEARCH,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.rescon(sg)
	return #sg==1 or (sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) and sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	if #g==0 then 
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
function s.releasefilter(c,e,tp)
	return c:IsSetCard(SET_MALEFIC) and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetCode(),e,tp)
end
function s.releasefilter2(c,code,e,tp)
	return c:IsSetCard(SET_MALEFIC) and c:IsMonster() and (c:GetCode()~=code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		return Duel.CheckReleaseGroupCost(tp,s.releasefilter,1,false,nil,nil,e,tp)
	end
	local rg=Duel.SelectReleaseGroupCost(tp,s.releasefilter,1,1,false,nil,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetCode())
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.releasefilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e:GetLabel(),e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end