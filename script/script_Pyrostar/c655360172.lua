-- Pyrostar Short Fuse
-- Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Link Summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PYRO),1)
	--Cannot be Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetCondition(s.lkcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- If this Attack position card is involve in battle, destroy both monsters after damage calculation.
	Pyrostar.AddDestroyBothEffect(c)
	-- Enable Material to also trigger destruction effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
    -- Add "Pyrostar" Spell/Trap from GY to hand
	local e1=Pyrostar.CreateDestroyTriggerEff({
		handler=c,
		handlerid=id,
		category=CATEGORY_TOHAND,
		functg=s.addtg,
		funcop=s.addop})
	c:RegisterEffect(e1)
end
s.listed_series={SET_PYROSTAR}
function s.lkcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.addfilter(c,e,tp)
    return c:IsSetCard(SET_PYROSTAR) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,math.min(2,#g),tp,LOCATION_GRAVE)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.addfilter),tp,LOCATION_GRAVE,0,1,2,nil)
	if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
    end
end