--DAL Mayuri
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Cannot Normal Summon
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetCode(EFFECT_CANNOT_SUMMON)
  c:RegisterEffect(e1)
  --(2) Special Summon from hand
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_SPSUMMON_PROC)
  e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e2:SetRange(LOCATION_HAND)
  e2:SetCondition(s.hspcon)
  c:RegisterEffect(e2)
  --(3) Search
  DAL.CreateAddSpaceQuakeOnSummonEffect(c,false)
  --(4) Special Summon
  DAL.CreateTributeSummonListedMonsterEffect(c,CARD_DALSPIRIT_JUDGEMENT,LOCATION_EXTRA)
end
s.listed_names={CARD_DAL_SPACEQUAKE,CARD_DALSPIRIT_JUDGEMENT}
--(2) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DALSPIRIT)
end
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
  Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,2,nil)
end