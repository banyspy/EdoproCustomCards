--HN CPU Neptune
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Search
  HN.AddOrPlaceOnSummon(c,id,CARD_HN_NATION_PLANEPTUNE)
  --(3) Level 4 Xyz
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetCode(EFFECT_XYZ_LEVEL)
  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e3:SetRange(LOCATION_MZONE)
  e3:SetValue(function(e,c,rc) return 4,e:GetHandler():GetLevel() end)
  c:RegisterEffect(e3)
end
s.listed_names={CARD_HN_NATION_PLANEPTUNE}
--(1) Search
--Already handled by BankkyzaAux File