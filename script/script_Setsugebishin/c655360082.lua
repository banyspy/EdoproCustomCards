--Setsugebishin the Wind Sword
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("SetsugebishinAux.lua")
function s.initial_effect(c)
	--Special 1 level 4 or 8 plant upon being target
	local e1,e2=Setsugebishin.CreateTargetFlipEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_SPECIAL_SUMMON,
		functg=s.sptg,
		funcop=s.spop})
	c:RegisterEffect(e1)
	c:RegisterEffect(e2)
    --Special summon itself
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,{id,1})
	--e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--s.listed_series={SET_SETSUGEBISHIN}
function s.spfilter(c,e,tp)
	return (c:IsLevel(4) or c:IsLevel(8)) and c:IsRace(RACE_PLANT) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then 
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.isplant(c)
    return c:IsMonster() and c:IsRace(RACE_PLANT) and c:HasLevel() and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.isplant(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.isplant,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.isplant,tp,LOCATION_MZONE,0,1,1,nil)
	--Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:HasLevel() and tc:GetLevel()~=c:GetOriginalLevel() and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
		    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		    e2:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		    e2:SetValue(c:GetOriginalLevel())
		    tc:RegisterEffect(e2)
		end
	end
end
