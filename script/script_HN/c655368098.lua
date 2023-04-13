--HN Planeptune Nation
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  c:SetUniqueOnField(1,0,id)
  --(1) Search
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --(2) Gain ATK
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetCategory(CATEGORY_ATKCHANGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(s.atkcon)
  e2:SetTarget(s.atktg)
  e2:SetOperation(s.atkop)
  c:RegisterEffect(e2)
end
s.listed_names={id}
--(1) Search
function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
  if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoHand(sg,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,sg)
  end
end
--(2) Gain ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetAttacker()
  local bc=Duel.GetAttackTarget()
  if not bc then return false end
  if tc:IsControler(1-tp) then bc,tc=tc,bc end
  return bc:IsFaceup() and tc:IsFaceup() and tc:IsSetCard(SET_HN) and tc:IsType(TYPE_XYZ)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local tc=Duel.GetAttacker()
  if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
  if tc:IsFaceup() and tc:IsRelateToBattle() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(tc:GetBaseAttack()/2)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    tc:RegisterEffect(e1)
  end
end