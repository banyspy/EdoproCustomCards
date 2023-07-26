-- Traptrix Campsis
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_INSECT|RACE_PLANT),2)
	--Unaffected by effect of trap and your opponent card in same column as this card or your set card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(function(e,te) return te:GetHandler():IsType(TYPE_TRAP) end)
	c:RegisterEffect(e1)
	--Double damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.linkcondition(1))
	e2:SetTarget(function (e,c) return c:IsSetCard(SET_TRAPTRIX) end)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.linkcondition(2))
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
	--Send from both side
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.linkcondition(3))
	e4:SetTarget(s.sendtg)
	e4:SetOperation(s.sendop)
	c:RegisterEffect(e4)
	--search
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetCost(aux.bfgcost)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
end
s.listed_series={SET_TRAPTRIX}
function s.linkcheck(c,card)
	return card:GetMutualLinkedGroup():IsContains(c) or (c:IsMonster() and c:IsSetCard(SET_TRAPTRIX))
end
function s.linkcondition(num)
	return function(e,tp,eg,ep,ev,re,r,rp)
		local lg=e:GetHandler():GetLinkedGroup()
		return lg:FilterCount(s.linkcheck,nil,e:GetHandler()) >= num
	end
end
function s.cfilter(c,seq,p,itself)
	return ((c == itself) or c:IsFacedown()) and c:IsColumn(seq,p,LOCATION_ONFIELD)
end
--Unaffected by opponent card in same column
function s.efilter(e,te)
	local th=te:GetHandler()
	local p=th:GetControler()
	local c=e:GetHandler()
	if p == c:GetControler() or not (th:IsLocation(LOCATION_ONFIELD)) then return end
	local seq=th:GetSequence()
	return Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_ONFIELD,0,1,nil,seq,p,c)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local h=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
		local rc=re:GetHandler()
		return rp~=tp and (h & LOCATION_ONFIELD)~=0
		and not (rc:IsLocation(LOCATION_ONFIELD) and rc:IsFaceup()) and Duel.IsChainDisablable(ev)
	end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.sendchk(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp) and sg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.sendtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ag=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		return aux.SelectUnselectGroup(ag,e,tp,2,2,s.sendchk,0)
	end
	local pg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,pg,1,0,0)
	pg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,pg,1,0,0)
end
function s.sendop(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if not aux.SelectUnselectGroup(ag,e,tp,2,2,s.sendchk,0) then return end
	local g=aux.SelectUnselectGroup(ag,e,tp,2,2,s.sendchk,1,tp,HINTMSG_TOGRAVE)
	Duel.HintSelection(g,true) --true show as "select" rather than "target"
	Duel.SendtoGrave(g,REASON_EFFECT)
end
function s.thfilter(c)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end