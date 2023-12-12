--HaunTale Phantasmal Focalor
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
    --Destroy 1 monster and change monsters to face-down
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
    e2:SetCost(s.takecost)
	e2:SetTarget(s.taketg)
	e2:SetOperation(s.takeop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_HAUNTALE}
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_HAUNTALE,lc,sumtype,tp)
end
function s.thfilter(c)
	return c:IsSetCard(SET_HAUNTALE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
    local max=1
    if Duel.IsTurnPlayer(1-tp) then max=2 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,max,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local th=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #th>0 then
        Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
end
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost()
    and Duel.IsExistingMatchingCard(s.takefilter,tp,LOCATION_DECK,0,1,nil,c)
end
function s.takefilter(c,card)
	return c:IsSetCard(SET_HAUNTALE) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
    and c:IsAttribute(card:GetAttribute()) and not c:IsCode(card:GetCode())
end
function s.takecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
    e:SetLabelObject(g:GetFirst())
end
function s.taketg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.takeop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc=Duel.SelectMatchingCard(tp,s.takefilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabelObject()):GetFirst()
	aux.ToHandOrElse(tc,tp)
end