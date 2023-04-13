--HN Falcom
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Destroy 1
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DESTROY)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetRange(LOCATION_PZONE)
  e1:SetCondition(s.descon1)
  e1:SetTarget(s.destg1)
  e1:SetOperation(s.desop1)
  c:RegisterEffect(e1)
  --Monster Effects
  --(1) Search
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
  e2:SetCountLimit(1,id)
  e2:SetTarget(s.thtg)
  e2:SetOperation(s.thop)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e3)
  --(2) Destroy 2
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,0))
  e4:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_LEAVE_FIELD)
  e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
  e4:SetCountLimit(1,{id,1})
  e4:SetCondition(s.descon2)
  e4:SetTarget(s.destg2)
  e4:SetOperation(s.desop2)
  c:RegisterEffect(e4)
end
--Pendulum Effects
--(1) Destroy
function s.desconfilter1(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and c:IsType(TYPE_XYZ) and c:GetSummonType()==SUMMON_TYPE_XYZ and c:GetSummonPlayer()==tp 
end
function s.descon1(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.desconfilter1,1,nil,tp) and eg:GetCount()==1
end
function s.desfilter1(c,atk)
  return c:IsFaceup() and c:GetAttack()<atk
end
function s.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local tc=eg:GetFirst()
  if chk==0 then return Duel.IsExistingTarget(s.desfilter1,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack()) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,s.desfilter1,tp,0,LOCATION_MZONE,1,1,nil,tc:GetAttack())
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and tc:IsFaceup() then
    Duel.Destroy(tc,REASON_EFFECT)
  end
end
--Monster Effects
--(1) Search
function s.thfilter1(c,tp)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,c:GetOriginalLevel())
end
function s.thfilter2(c,lvl)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN) and c:GetLevel()<lvl
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_MZONE,0,1,e:GetHandler(),tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local g=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
  local lvl=g:GetFirst():GetOriginalLevel()
  e:SetLabel(lvl)
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local lvl=e:GetLabel()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,lvl)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
    Duel.ConfirmCards(1-tp,g)
  end
end
--(2) Destroy 2
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousPosition(POS_FACEUP) and not e:GetHandler():IsLocation(LOCATION_DECK)
end
function s.desfilter2(c)
  return c:IsSetCard(SET_HN)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_HN) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) 
  and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCountFromEx(tp)>0 and Duel.IsExistingTarget(s.desfilter2,tp,LOCATION_PZONE,0,1,nil) 
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectTarget(tp,s.desfilter2,tp,LOCATION_PZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
    if Duel.GetLocationCountFromEx(tp)<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if g:GetCount()>0 then
      Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
  end
end