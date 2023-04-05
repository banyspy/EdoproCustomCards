--Number C87: White Queen of the Night
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	Xyz.AddProcedure(c,nil,10,3)
	--half atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function (e,c) return c:GetAttack()//2 end)
	c:RegisterEffect(e1)
	--attach upon card on the field be target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--register when the card is destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.regcon)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--register when the card is banished
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3b)
	--special summon itself and other xyz
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_NO_87_QUEEN_OF_THE_NIGHT}--Queen of the night
--s.listed_series={0xb05}
s.xyz_number=87
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil)
end
function s.matfilter(c,ac,tp)
	return c:IsMonster() and c:IsCanBeXyzMaterial(ac,tp)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_ONFIELD,1,nil,c,tp) and
		Duel.IsExistingTarget(s.matfilter,tp,0,LOCATION_GRAVE,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc1=Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_ONFIELD,1,1,nil,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc2=Duel.SelectTarget(tp,s.matfilter,tp,0,LOCATION_GRAVE,1,1,nil,c,tp)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards(e)
	local fg=g:Filter(Card.IsRelateToEffect,nil,e)
	if c:IsRelateToEffect(e) then
		Duel.Overlay(c,fg,true)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetOverlayCount()>0
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0 
	and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_NO_87_QUEEN_OF_THE_NIGHT)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and 
		Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	if #tc>0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
