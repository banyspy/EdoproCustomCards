--DAL Tokisaki Kurumi
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Search
  DAL.CreateAddSpaceQuakeOnSummonEffect(c,true)
  --(2) Special Summon
  DAL.CreateTributeSummonListedMonsterEffect(c,CARD_DALSPIRIT_NIGHTMARE)
end
s.listed_names={CARD_DAL_SPACEQUAKE,CARD_DALSPIRIT_NIGHTMARE}