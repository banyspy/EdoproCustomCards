--Traptrix Photouris
-- scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
    --Unaffected by "Hole" normal trap cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	-- set hole Spell/Trap effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TRAPTRIX,SET_HOLE,SET_TRAP_HOLE}
function s.efilter(e,te)
	local c=te:GetHandler()
	return c:GetType()==TYPE_TRAP and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE))
end
function s.cfilter(c)
	return c:IsFacedown() or not c:IsRace(RACE_INSECT|RACE_PLANT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and (c:IsSetCard(SET_HOLE) or c:IsSetCard(SET_TRAP_HOLE)) and c:IsSSetable()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		return ct>=2 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=2
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if ct>=2 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=2 then
		local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SET,nil,nil,true)
		if Duel.SSet(tp,tg)~=0 then
			local c=e:GetHandler()
			local tgt=tg:GetFirst()
			--Can be activated the turn they are seted
			for tgt in aux.Next(tg) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tgt:RegisterEffect(e1)
			end
			-- Cannot Special Summon monsters from the Extra Deck, except Insect or Plant monsters
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT|RACE_PLANT) end)
			e2:SetTargetRange(1,0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,Duel.IsTurnPlayer(tp) and 2 or 1)
			Duel.RegisterEffect(e2,tp)
			-- Lizard check
			aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalRace(RACE_INSECT|RACE_PLANT) end)
		end
	end
end