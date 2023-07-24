-- Amalgam - Transformation
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Activate
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
    --Special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.revcon)
	e4:SetTarget(s.revtg)
	e4:SetOperation(s.revop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_AMALGAM}
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_AMALGAM),tp,LOCATION_MZONE,0,1,nil)
end
function s.tgfilter(c)
	return c:IsFaceup() and (not c:GetRace()~=RACE_ALL)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)
    local tg=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local label=Duel.AnnounceRace(tp,1,(~tg:GetFirst():GetRace()&RACE_ALL))
    e:SetLabel(label)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
    if not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	-- Change monster type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function s.revfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_AMALGAM) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:GetReasonPlayer()==1-tp and c:GetReason()&REASON_EFFECT~=0
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.spfilter(c,e,tp,eg)
	return c:IsMonster() and c:IsSetCard(SET_AMALGAM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    and not eg:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,eg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,eg)
    if #tg>0 then
        Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
    end
end