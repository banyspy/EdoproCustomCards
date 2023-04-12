--OTNN Attribute Boost
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Double rank
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_ATKCHANGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetTarget(s.rktg)
  e1:SetOperation(s.rkop)
  c:RegisterEffect(e1)
end
function s.rkfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_OTNN) and c:IsType(TYPE_XYZ)
end
function s.rktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.rkfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.rkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.rkop(e,tp,eg,ep,ev,re,r,rp)    
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_RANK_FINAL)
    e1:SetValue(tc:GetRank()*2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
  end
  if Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,RACE_WARRIOR) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then 
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,RACE_WARRIOR)
    if g:GetCount()>0 and not g:GetFirst():IsHasEffect(EFFECT_NECRO_VALLEY) and Duel.Overlay(tc,g)~=0 then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_ATTACK)
      e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
      e1:SetValue(g:GetFirst():GetAttack()/2)
      tc:RegisterEffect(e1)
    end
  end
end
