--HaunTale Necromancer Belle
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    --Destroy this card to send zombie from Deck to GY
	HaunTale.DestroyToSendZombie(c,id)
    --set 1 "HaunTale" Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
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

function s.setfilter(c)
	return c:IsSetCard(SET_HAUNTALE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if tc then
		Duel.BreakEffect()
		Duel.SSet(tp,tc:GetFirst())
	end
end