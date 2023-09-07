--DAL Pendragon - Ellen
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DAL),3,3)
  c:EnableReviveLimit()
  --(1) Unaffected
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1)
  e1:SetCost(aux.dxmcostgen(1,1,nil))
  e1:SetTarget(s.unftg)
  e1:SetOperation(s.unfop)
  c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
  --(2) Gain ATK
  local e3=Effect.CreateEffect(c)
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_CHAIN_SOLVED)
  e3:SetRange(LOCATION_MZONE)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3)
end
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) Unaffected
function s.unffilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.unftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.unffilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.unffilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.unfop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(s.unfilter)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end
function s.unfilter(e,re)
  return e:GetHandler()~=re:GetOwner()
end
--(2) Gain ATK
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(SET_DALSPIRIT) then
    Duel.Hint(HINT_CARD,0,id)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(300)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
  end
end