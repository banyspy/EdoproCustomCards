--HaunTale Necromancer Amy
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    --Destroy this card to send zombie from Deck to GY
	HaunTale.DestroyToSendZombie(c,id)
    --Place 2 "HaunTale" pendulum from Deck to Pendulum zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
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

function s.pfilter(c,pc)
	return c:IsSetCard(SET_HAUNTALE) and and c:IsType(TYPE_PENDULUM) c:IsMonster() and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) and
        g:GetClassCount(Card.GetCode)>1 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
    if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)) then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TOFIELD)
    local sc=sg:GetFirst()
	for sc in sg:Iter() do
		Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end