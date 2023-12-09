--HaunTale Necromancer Echo
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    Pendulum.AddProcedure(c)
    --Destroy this card to send zombie from Deck to GY
	HaunTale.DestroyToSendZombie(c,id)
    --Send up to 2 "HaunTale" pendulum to Extra Deck
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

function s.thfilter(c,pc)
	return c:IsSetCard(SET_HAUNTALE) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
	local th=tg:Filter(Card.IsRelateToEffect,nil,e)
	if #th>0 then
        Duel.SendtoHand(th,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,th)
	end
end