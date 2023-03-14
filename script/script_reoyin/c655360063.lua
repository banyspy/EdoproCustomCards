--Reo-Whelp - Bone Dragon
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('ReoyinAux.lua')
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--Revive and add to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.revcon)
	e4:SetCost(s.revcost)
	e4:SetTarget(s.revtg)
	e4:SetOperation(s.revop)
	c:RegisterEffect(e4)
end
s.listed_names={655360061}
function s.cfilter(c)
	return c:IsMonster() and not c:IsFacedown() and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)==Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.thfilter(c)
	return c:IsCode(655360061) or (c:IsSetCard(SET_REOYIN) and c:IsSpellTrap())
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
function s.revfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_REOYIN) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:GetReasonPlayer()==1-tp
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	--Debug.Message("Player: "..tp) 
	--Debug.Message("Chekc exist: " .. tostring(eg:IsExists(s.revfilter,1,nil,tp)) ) 
	--Debug.Message("Chekc player: ".. tostring(rp==1-tp)) 
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		--Debug.Message("Chekc cost: "..tostring(Duel.CheckLPCost(tp,1000))) 
		return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_REOYIN) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) 
	and c:GetReasonPlayer()==1-tp and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local sg=eg:Filter(s.spfilter,nil,e,tp)
		return Reoyin.MassSummonLegalityCheck(sg,tp)
			--Reoyin.SummonLegalityCheck(sg,tp)
	end
	local g=eg:Filter(s.spfilter,nil,e,tp)
	--Debug.Message("Amount: "..#g) 
	Duel.SetTargetCard(eg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.spfilter2(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_REOYIN) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD) 
	and c:GetReasonPlayer()==1-tp and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsRelateToEffect(e)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=eg:Filter(s.spfilter2,nil,e,tp)
	--Debug.Message("Amount eg: "..#eg) 
	--Debug.Message("Amount: "..#sg) 
	if not Reoyin.MassSummonLegalityCheck(sg,tp) then return end
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e) and c:IsAbleToHand() then
		Duel.BreakEffect()
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end