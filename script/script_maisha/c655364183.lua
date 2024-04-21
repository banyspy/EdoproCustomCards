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
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_ALL)
	e0:SetValue(655364181)
	c:RegisterEffect(e0)
end
s.listed_names={655364181}
function s.matfilter(c,scard,sumtype,tp)
	return  c:IsCode(655364181) 
            and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,655364188)
            and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,655364189)
end