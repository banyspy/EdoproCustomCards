--Floral Scenery
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("SetsugebishinAux.lua")
function s.initial_effect(c)
	--Add
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
	--Special summon back and attach this card to it
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcondition)
	e3:SetTarget(s.sptarget)
	e3:SetOperation(s.spoperation)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_NO_87_QUEEN_OF_THE_NIGHT,id}--Queen of the night
function s.filter(c)
	return c:IsSpellTrap() and c:ListsCode(CARD_NO_87_QUEEN_OF_THE_NIGHT) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.attachfilter(c,tp,mc)
	return c:IsCanBeXyzMaterial(mc,tp,REASON_EFFECT) and c:IsMonster() and c:IsSetCard(0xb05)
end
function s.attachmonster(c,tp)
	return c:IsMonster() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_PLANT) and c:IsFaceup()
	and Duel.IsExistingMatchingCard(s.attachfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,tp,c)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.attachmonster,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	--if not Duel.IsExistingMatchingCard(s.attachmonster,tp,LOCATION_MZONE,0,1,nil,tp) then return end
	local tc=Duel.SelectMatchingCard(tp,s.attachmonster,tp,LOCATION_MZONE,0,1,1,nil,tp)
	if #tc>0 then
		local ac=Duel.SelectMatchingCard(tp,s.attachfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,tp,tc:GetFirst())
		Duel.Overlay(tc:GetFirst(),ac)
	end
end
function s.spcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.spmonster(c,e,tp)
	return c:IsMonster() and c:IsType(TYPE_XYZ) and c:IsRace(RACE_PLANT) and c:GetRank()==8 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spmonster,tp,LOCATION_GRAVE,0,1,nil,e,tp)end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spmonster,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and 
	c:IsRelateToEffect(e) and c:IsCanBeXyzMaterial(tc,tp,REASON_EFFECT) then
		Duel.Overlay(tc,c)
	end
end
