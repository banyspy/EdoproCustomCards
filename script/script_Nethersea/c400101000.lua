--Nethersea Approaching
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e1:SetTarget(s.activatetarget)
	e1:SetOperation(s.activateoperation)
	c:RegisterEffect(e1)
    
    --destroy 1 from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.DoNotRepeatAsk)
	e2:SetTarget(s.gravetarget)
	e2:SetOperation(s.graveoperation)
	c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e3)
    local e4=e2:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.gravecon)
    c:RegisterEffect(e4)
end
function s.spfilter(c,e,tp)
	return Nethersea.NetherseaMonsterOrWQ(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activatetarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) 
	 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.activateoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sp=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #sp>0 then Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP) end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	--Duel.Hint(HINT_CARD,0,id)
	Duel.Destroy(tc,REASON_EFFECT)
end
function s.gravecon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.DoNotRepeatAsk(e,tp,eg,ep,ev,re,r,rp)
    return not (e:GetHandler():IsLocation(LOCATION_GRAVE) and (r&REASON_EFFECT)~=0)
end
function s.gravefilter(c)
	return Nethersea.NetherseaCardOrWQ(c) and not c:IsCode(id) 
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end