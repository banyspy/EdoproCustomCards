--DAL Gabriel
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Activate effects
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(s.aetg)
  e1:SetOperation(s.aeop)
  c:RegisterEffect(e1)
end
s.listed_series={SET_DAL}
--(1) Activate effects
function s.atkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.aetg(e,tp,eg,ep,ev,re,r,rp,chk)
  local b1=Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) 
  local b2=Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil)
  if chk==0 then return b1 or b2 end
  local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
  e:SetLabel(op)
  if op==1 then
    e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
  elseif op==2 then
    e:SetCategory(CATEGORY_POSITION)
    local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
  end
end
function s.aeop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local op=e:GetLabel()
  if op==1 then
    local g1=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    if g1:GetCount()>0 then
      local atk=g1:GetCount()*200
      for sc1 in aux.Next(g1) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(atk)
        sc1:RegisterEffect(e1)
      end
    end
    Duel.BreakEffect()
    local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    if g2:GetCount()>0 then
      for sc2 in aux.Next(g2) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(-500)
        sc2:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        sc2:RegisterEffect(e2)
      end
    end
  elseif op==2 then
    local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,0,LOCATION_MZONE,nil)
    Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
  end
end