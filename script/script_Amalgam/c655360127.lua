-- Amalgam - Fafnir, The Despoiler
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon Procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_AMALGAM),1,1,Synchro.NonTuner(nil),1,1)
	--Immune to monster that share the same type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.immune)
	c:RegisterEffect(e1)
    --negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.shcon)
	e2:SetTarget(s.shtg)
	e2:SetOperation(s.shop)
	c:RegisterEffect(e2)
end
s.synchro_nt_required=1
s.listed_series={SET_AMALGAM}
function s.immune(e,te)
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
    local race=Amalgam.AllTypeFromGroup(cg)
    return te:IsMonsterEffect() and te:GetOwner():GetRace()&race~=0
end
function s.shcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.shtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local cg=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE,0,nil)
    local race=Amalgam.TypeAmountFromGroup(cg)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) and race>=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,math.floor(race/3),nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
