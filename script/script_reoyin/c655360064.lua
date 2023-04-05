--Reoyin the Dimension Dragon Knight
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,nil,nil,nil,s.matfilter)
	--Decrease ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(function(e,c) return Duel.GetMatchingGroupCount(Card.IsAttribute,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_DARK) * (-300) end)
	c:RegisterEffect(e1)
	--Destroy 1 monster and negate monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.sumcon)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
end
s.synchro_nt_required=1
function s.cfilter(c,sc,tp)
	return c:IsRace(RACE_SPELLCASTER,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.matfilter(g,sc,tp)
	return g:IsExists(s.cfilter,1,nil,sc,tp)
end
function s.filter(c)
	return not c:IsPublic() or c:IsMonster()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	local dg=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	if not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_HAND+LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g1>0 and Duel.Destroy(g1,REASON_EFFECT)~=0 then
		local g2=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
		if #g2>0 then
			for tc in aux.Next(g2) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
		end
	end
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
	and e:GetHandler():GetReasonPlayer()==1-tp
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) and Duel.GetMZoneCount(tp)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetMZoneCount(tp)>0) then return end
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	if #tg>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)
	end
end
