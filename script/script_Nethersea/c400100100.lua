--Nethersea Founder
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Search 1 "Nethersea" card, then tribute 1 "Nethersea" card from hand or field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.handefftarget)
	e1:SetOperation(s.handeffoperation)
	c:RegisterEffect(e1)

	Nethersea.GenerateToken(c)
end
function s.tributecheck(c)
	return c:IsSetCard(SET_NETHERSEA) and c:IsReleasableByEffect()
end
function s.thfilter(c)
	return c:IsSetCard(SET_NETHERSEA) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.handefftarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
	and Duel.IsExistingMatchingCard(s.tributecheck,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	--Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,1)
end
function s.handeffoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		local sg=Group.CreateGroup()
		sg:Merge(g)
		sg:AddCard(c)
		local g=Duel.SelectReleaseGroupEx(tp,s.tributecheck,1,1,sg)
		if #g>0 then Duel.Release(g,REASON_EFFECT) end
		sg:DeleteGroup()
	end
end