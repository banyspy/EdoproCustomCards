--Tori-No-Kami Uguisuoh
--scripted by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SPIRIT),1,99)
	c:EnableReviveLimit()
end
s.listed_series={SET_TORINOKAMI}