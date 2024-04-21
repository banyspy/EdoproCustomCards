--Purgation's Blade
--scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={655364181}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,e:GetHandler()) end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(te,rp,tp) return tp~=ep end)
	end
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,655364181),tp,LOCATION_ONFIELD,0,1,nil) then 
		e:SetLabel(1) 
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	local sg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	local c=e:GetHandler()
	--Negate the effects of all face-up cards your opponent currently controls, until the end of this turn
	for tc in g:Iter() do
		tc:NegateEffects(c,RESET_PHASE|PHASE_END)
	end
	--Current Face-down card cannot activated
	for sc in sg:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		--e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		sc:RegisterEffect(e1)
	end
	if e:GetLabel()==1 then
		--Your opponent takes no damage for the rest of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetTargetRange(0,1)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		Duel.RegisterEffect(e2,tp)
	end

	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	if Duel.GetTurnPlayer()==tp then
		e0:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e0:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
	end
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0,tp)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e1,tp)
	local e2=e0:Clone()
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e2,tp)
end
	--Cannot special summon
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsCode(655364181)
end

function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,655364181),tp,LOCATION_MZONE,0,1,nil) 
	and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,655364181),tp,LOCATION_MZONE,0,1,nil) then return end
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,655364181),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(function (e,c)
			local g=Duel.GetMatchingGroup(aux.TRUE,c:GetControler(),LOCATION_GRAVE,0,nil)
			return #g*100
		end)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end 
end