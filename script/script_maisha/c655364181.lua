-- Maisha, Hero of Purgation
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(function () return Duel.IsMainPhase() end)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--destroy
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
    --Add to hand then can normal summon
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCategory(CATEGORY_TOHAND)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e7:SetCountLimit(1,{id,2})
	e7:SetCondition(s.revcon)
	e7:SetTarget(s.revtg)
	e7:SetOperation(s.revop)
	c:RegisterEffect(e7)
end
s.listed_names={id}
function s.cfilter(c,e,tp)
	return c:ListsCode(id) and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	local g=e:GetLabelObject()
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.cfilter(c)
	return c:ListsCode(id) and c:IsDiscardable()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) 
            and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
		Duel.SpecialSummonComplete()
	end
end
--destroy and take Spell/Trap
function s.thfilter(c)
	return c:IsSpellTrap() and c:ListsCode(id) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	if #g>0 then
		Duel.HintSelection(g,true)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
			if not tc then return end
			aux.ToHandOrElse(tc,tp,
				Card.IsSSetable,
				function(c)
					Duel.SSet(tp,tc)
				end,
				aux.Stringid(id,3)
			)
		end
	end
end
--Add self to hand
function s.revfilter(c,tp)
	return c:ListsCode(id) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
	and c:GetReasonPlayer()==1-tp
end
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.revfilter,1,nil,tp)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
