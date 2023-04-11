--Magikular - Fusion
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({
		handler=c,
		fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_MAGIKULAR),
		matfilter=s.matfilter,
		extrafil=s.fextra,
		extraop=s.extraop,
		extratg=s.extratg})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Add back to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
function s.matfilter(c)
	return (c:IsLocation(LOCATION_HAND|LOCATION_ONFIELD) and c:IsAbleToGrave()) or (c:IsLocation(LOCATION_GRAVE) and c:IsAbleToRemove())
end
function s.fextra(e,tp,mg)
	local GYmat = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil)
	local Deckmat = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK|LOCATION_EXTRA,0,nil)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD) --Official Evenly match condition code
	local ct=#g-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ct=ct-1 end
	if ct>0 then
		GYmat:Merge(Deckmat)
	end
	return GYmat
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.thcfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcfilter,tp,LOCATION_GRAVE,0,1,1,c)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end