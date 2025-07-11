--Tori-No-Kami Spirit Gate
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--
	--local e2=Effect.CreateEffect(c)
	--e2:SetType(EFFECT_TYPE_FIELD)
	--e2:SetRange(LOCATION_SZONE)
	--e2:SetTargetRange(LOCATION_MZONE,0)
	--e2:SetCode(EFFECT_UPDATE_ATTACK)
	--e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_TORINOKAMI))
	--e2:SetValue(100)
	--c:RegisterEffect(e2)
end
s.listed_series={SET_TORINOKAMI}
function s.filter(c)
	return c:IsSetCard(SET_TORINOKAMI) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end