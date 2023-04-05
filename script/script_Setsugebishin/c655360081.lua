--Setsugebishin the Amethyst
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Add 1 "Setsugebishin" upon being target
	local e1,e2=Setsugebishin.CreateTargetFlipEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND|CATEGORY_SEARCH,
		functg=s.thtg,
		funcop=s.thop})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
    --Grant effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.discon)
    e3:SetCountLimit(1)
	e3:SetCost(aux.dxmcostgen(1,1,nil))
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SETSUGEBISHIN}
function s.thfilter(c,e,tp)
	return c:IsSetCard(SET_SETSUGEBISHIN) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then 
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOriginalRace()==RACE_PLANT
		and not c:IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and Duel.IsChainNegatable(ev)
		and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
        e:SetCategory(e:GetCategory()|CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
