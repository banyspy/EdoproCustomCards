--Tori-No-Kami Okina Sora
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	--e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_TORINOKAMI}