--DAL Irregular Spirit - AI
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum effects
  --(1) Gain LP
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetCategory(CATEGORY_RECOVER)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetRange(LOCATION_PZONE)
  e1:SetCountLimit(1)
  e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer()==tp end)
  e1:SetTarget(s.rectg)
  e1:SetOperation(s.recop)
  c:RegisterEffect(e1)
  --(2) Unaffected by Spell 1
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetRange(LOCATION_PZONE)
  e2:SetTargetRange(LOCATION_MZONE,0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_DAL))
  e2:SetValue(s.unsfilter)
  c:RegisterEffect(e2)
  --Monster effects
  --(1) Gain ATK
  DAL.CreateOnSummonByDALEff({
    handler=c,
    handlerid=id,
    category=CATEGORY_ATKCHANGE,
    property=EFFECT_FLAG_CARD_TARGET,
    functg=s.revtg,
    funcop=s.revop})
  --(2) Unaffected by Spell 2
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE)
  e4:SetCode(EFFECT_IMMUNE_EFFECT)
  e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetValue(s.unsfilter)
  c:RegisterEffect(e4)
  --(3) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
s.listed_series={SET_DAL}
--Pendulum effects
--(1) Gain LP
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local rec=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
  Duel.SetTargetPlayer(tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec*300)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  local rec=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
  Duel.Recover(p,rec*300,REASON_EFFECT)
end
--(2) Unaffected Spell
function s.unsfilter(e,te)
  return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end
--Monster effects
--(1) Gain ATK
function s.revfilter1(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.revfilter2(c)
  return c:IsSetCard(SET_DAL) and c:IsType(TYPE_MONSTER)
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.revfilter1,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.revfilter1,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler() 
  local tc=Duel.GetFirstTarget()
  Duel.ConfirmDecktop(tp,5)
  local g=Duel.GetDecktopGroup(tp,5)
  local ct=g:FilterCount(s.revfilter2,nil)
  Duel.ShuffleDeck(tp)
  if ct>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(ct*500)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
  end
end