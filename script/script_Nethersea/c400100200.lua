--Nethersea Predator
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	-- Tribute 1 "Nethersea" card from hand or field except this card, and if you do, ss "Nethersea" monster from hand or GY except tributed monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.handefftarget)
	e1:SetOperation(s.handeffoperation)
	c:RegisterEffect(e1)
	
	Nethersea.GenerateToken(c)
end
function s.handeffspfilter(c,e,tp)
	return c:IsSetCard(0x259) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tributechecktarget(c,e,tp)
	return c:IsSetCard(0x259) and c:IsReleasableByEffect() and not c:IsCode(id)
	and Duel.IsExistingMatchingCard(s.handeffspfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
function s.tributecheckoperation(c)
	return c:IsSetCard(0x259) and c:IsReleasableByEffect() and not c:IsCode(id)
end
function s.handefftarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tributechecktarget,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),e,tp) 
	 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.handeffoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectReleaseGroupEx(tp,s.tributecheckoperation,1,1,c)
	if #g>0 and Duel.Release(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sp=Duel.SelectMatchingCard(tp,s.handeffspfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,g,e,tp)
		if #sp>0 then Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP) end
	end
end