--HaunTale Necromancer Jane
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    --Destroy this card to send zombie from Deck to GY
	HaunTale.DestroyToSendZombie(c,id)
    --Special Summon up to 2 "HaunTale" monsters from hand and/or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
    e1:SetCost(HaunTale.SendZombieCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
    --If destroyed add "HaunTale" Trap
	HaunTale.AddTrapIfDestroyed(c,id)
end
--s.listed_names={id}
s.listed_series={SET_HAUNTALE}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_HAUNTALE) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    local max=2
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max = 1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,max,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local max = math.min(2,Duel.GetMZoneCount(tp))
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then max = math.min(1,max) end
    local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
    local g=tg:Select(tp,1,max,nil)
    if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end