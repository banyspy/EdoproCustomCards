--DAL AST Reinforcements
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Activate effect
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.aetg)
  e1:SetOperation(s.aeop)
  c:RegisterEffect(e1)
end
--(1) Activate effect
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
  and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL) and c:IsType(TYPE_XYZ)
end
function s.aetg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
  local pt=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and #ct>0
  local b2=Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil) and #pt>0
  if chk==0 then return b1 or b2 end
  local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
  e:SetLabel(op)
  if op==1 then
  	e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,ct,#ct,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,ct,#ct,0,0)
  elseif op==2 then
  	e:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  	local g=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
  	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,pt,#pt,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,pt,#pt,0,0)
  end
end
function s.aeop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local op=e:GetLabel()
  if op==1 then
  	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  	local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  	if #g1>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
  	  local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
  	  for tc in aux.Next(g2) do
  	    local e1=Effect.CreateEffect(e:GetHandler())
  	    e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
  		  e1:SetValue(-500)
  		  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  		  tc:RegisterEffect(e1)
  		  local e2=e1:Clone()
  		  e2:SetCode(EFFECT_UPDATE_DEFENSE)
  		  tc:RegisterEffect(e2)
  	  end
  	end
  elseif op==2 then
  	local g1=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
  	Duel.ChangePosition(g1,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
  	local g2=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
  	for tc in aux.Next(g2) do
      local e1=Effect.CreateEffect(c)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
  	  e1:SetValue(500)
  	  e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
  	  tc:RegisterEffect(e1)
  	end
  end
end