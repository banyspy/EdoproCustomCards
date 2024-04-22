--Maisha, Purgation's Vessel
--Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link material
	Link.AddProcedure(c,s.matfilter,1,1)
	--change name to "Maisha, Hero of Purgation"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(655364181)
	c:RegisterEffect(e0)
	--destroy and equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Can Normal Summon 1 additional LIGHT Warrior
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(aux.AND(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR)))
	c:RegisterEffect(e2)
	--Send 3 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.gytg)
	e3:SetOperation(s.gyop)
	c:RegisterEffect(e3)
	local e3b=e3:Clone()
	e3b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3b)
end
s.listed_names={655364181}
function s.matfilter(c,scard,sumtype,tp)
	return  c:IsCode(655364181) 
            and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,655364188)
            and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,655364189)
end
--destroy and take Spell/Trap
function s.eqfilter(c,dc,tc,tp)
	return not c:IsCode(dc:GetCode()) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
	and (c:CheckEquipTarget(tc) or not c:IsEquipSpell())
end
function s.forchk(c,e,tp)
	return Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,e:GetHandler(),tp)
	and (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or c:IsLocation(LOCATION_SZONE))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.forchk,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,e:GetHandler())
	local eg=Duel.GetMatchingGroup(nil,tp,LOCATION_GRAVE,LOCATION_GRAVE,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,eg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.forchk,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.HintSelection(g,true)
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,g:GetFirst(),e:GetHandler(),tp):GetFirst()
			if not tc then return end
			Duel.HintSelection(tc,true)
			if tc:IsEquipSpell() then
				Duel.Equip(tp,tc,e:GetHandler())
			else
				Duel.Equip(tp,tc,e:GetHandler())--s.equipop(e:GetHandler(),e,tp,tc)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				if tc:IsSpellTrap() then
					e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				else
					e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TURN_SET)
				end
				e1:SetValue(true)
				tc:RegisterEffect(e1)
			end
		end
	end
end

function s.gyfilter(c)
	return c:ListsCode(655364181) and c:IsAbleToGrave()
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_DECK,0,nil,c,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,0) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,3,0,0)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_DECK,0,nil,c,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end