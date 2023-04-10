--NGNL Hatsuse Izuna
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Scale change
  NGNL.ForceChangeScaleEffect(c)
  --(2) Cannot set
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_CANNOT_MSET)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetRange(LOCATION_PZONE)
  e2:SetTargetRange(0,1)
  e2:SetTarget(aux.TRUE)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EFFECT_CANNOT_SSET)
  c:RegisterEffect(e3)
  local e4=e2:Clone()
  e4:SetCode(EFFECT_CANNOT_TURN_SET)
  c:RegisterEffect(e4)
  local e5=e2:Clone()
  e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
  e5:SetTarget(s.csetlimit)
  c:RegisterEffect(e5)
  --(3) Special Summon
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,2))
  e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e6:SetCode(EVENT_DRAW)
  e6:SetRange(LOCATION_PZONE)
  e6:SetCondition(s.spcon)
  e6:SetTarget(s.sptg)
  e6:SetOperation(s.spop)
  c:RegisterEffect(e6)
  --Monster Effects
  --(1) Special Summon from hand
  local e7=Effect.CreateEffect(c)
  e7:SetType(EFFECT_TYPE_FIELD)
  e7:SetCode(EFFECT_SPSUMMON_PROC)
  e7:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e7:SetRange(LOCATION_HAND)
  e7:SetCondition(s.hspcon)
  c:RegisterEffect(e7)
  --(2) Shuffle 1
  local e8=Effect.CreateEffect(c)
  e8:SetDescription(aux.Stringid(id,3))
  e8:SetCategory(CATEGORY_TODECK)
  e8:SetType(EFFECT_TYPE_QUICK_O)
  e8:SetCode(EVENT_FREE_CHAIN)
  e8:SetRange(LOCATION_MZONE)
  e8:SetCountLimit(1)
  e8:SetCondition(s.tdcon1)
  e8:SetTarget(s.tdtg1)
  e8:SetOperation(s.tdop1)
  c:RegisterEffect(e8)
  --(3) Shuffle 2
  local e9=Effect.CreateEffect(c)
  e9:SetDescription(aux.Stringid(id,3))
  e9:SetCategory(CATEGORY_TODECK)
  e9:SetType(EFFECT_TYPE_QUICK_O)
  e9:SetCode(EVENT_FREE_CHAIN)
  e9:SetRange(LOCATION_MZONE)
  e9:SetCountLimit(1)
  e9:SetCondition(s.tdcon2)
  e9:SetTarget(s.tdtg2)
  e9:SetOperation(s.tdop2)
  c:RegisterEffect(e9)
  --(4) Avoid battle damage
  local e10=Effect.CreateEffect(c)
  e10:SetType(EFFECT_TYPE_SINGLE)
  e10:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e10:SetValue(1)
  c:RegisterEffect(e10)
end
s.roll_dice=true
--Pendulum Effects
--(1) Scale Change
--Already handled by BanyspyAux file
--(2) Cannot set
function s.csetlimit(e,c,sump,sumtype,sumpos,targetp)
	return (sumpos&POS_FACEDOWN)>0
end
--(3) Special Summon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NGNL) and c:IsType(TYPE_MONSTER) and (c:IsLocation(LOCATION_HAND) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local loc=0
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end   
  if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
  if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local loc=0
  if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_HAND end
  if Duel.GetLocationCountFromEx(tp)>0 then loc=loc+LOCATION_EXTRA end
  if loc==0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp)
  if g:GetCount()>0 then
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
  end
end
--Monster Effects
--(1) Special Summon from hand
function s.hspcon(e,c)
  if c==nil then return true end
  return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
  and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0,nil)<Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE,nil)
end
--(2) Shuffle 1
function s.tdcon1(e)
  return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,2,nil,SET_NGNL)
end
function s.tdtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return e:GetHandler():IsAbleToDeck()
  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,0,LOCATION_MZONE)
end
function s.tdop1(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
  if g:GetCount()>0 then
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  	local sg=g:Select(tp,1,1,nil)
    Duel.HintSelection(sg)
  	if c:IsRelateToEffect(e) and sg then
  	  local sg=Group.FromCards(c,sg:GetFirst())
  	  Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
  	end
  end
end
--(3) Shuffle 2
function s.tdcon2(e)
  return Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,2,nil,SET_NGNL)
end
function s.tdtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return e:GetHandler():IsAbleToDeck()
  and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,0,LOCATION_MZONE)
end
function s.tdop2(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
  if g:GetCount()>0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:Select(tp,1,2,nil)
    Duel.HintSelection(sg)
    if c:IsRelateToEffect(e) and sg then
   	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT,true)
  	Duel.SendtoDeck(c,nil,2,REASON_EFFECT,true)
  	Duel.RDComplete() --Why is this here???
  	end
  end
end