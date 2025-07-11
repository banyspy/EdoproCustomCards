--Tori-No-Kami Suzume
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- Place 1 "Tori-No-Kami" continuous Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DIS_NEG_INA)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2,false,EFFECT_MARKER_TORINOKAMI)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={SET_TORINOKAMI}
function s.counterfilter(c) --Counter will count the summon that does not fit this condition
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 --Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0
		 and not e:GetHandler():IsPublic() end
	--Cannot special summon the turn you activate
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	e1:SetTarget(function(e,c) return not c:IsLocation(LOCATION_EXTRA)end)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(EFFECT_MARKER_TORINOKAMI,10))
	e2:SetReset(RESET_PHASE|PHASE_END,2)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.tffilter(c,tp)
	return c:IsSpell() and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(SET_TORINOKAMI) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.sumfilter(c)
	return c:IsSetCard(SET_TORINOKAMI) and c:IsSummonable(true,nil)
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and
		Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,tp) end
	local g=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,g,1,0,0)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if not Duel.IsPlayerAffectedByEffect(1-tp,30459350) 
	and g:IsExists(Card.IsAbleToRemove,1,nil,1-tp,POS_FACEDOWN,REASON_RULE) 
		then
			opt=Duel.SelectOption(1-tp,aux.Stringid(EFFECT_MARKER_TORINOKAMI,11),aux.Stringid(EFFECT_MARKER_TORINOKAMI,12))
		end
	if opt==0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local g=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,tp)--:GetFirst()
		if #g>0 and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
			if #sg>0 and Duel.GetMZoneCount(tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
				if tc then
					Duel.Summon(tp,tc,true,nil)
				end
			end
		end
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local sg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil,1-tp,POS_FACEDOWN,REASON_RULE)
		Duel.Remove(sg,POS_FACEDOWN,REASON_RULE,PLAYER_NONE,1-tp)
	end
end