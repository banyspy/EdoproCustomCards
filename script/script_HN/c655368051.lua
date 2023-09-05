--HN UD Neptune
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_SPSUMMON_PROC)
  e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.spcon)
  c:RegisterEffect(e1)
  --(2) Xyz Summon
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1,{id,1})
  e2:SetCondition(s.xyzcon)
  e2:SetTarget(s.xyztg)
  e2:SetOperation(s.xyzop)
  c:RegisterEffect(e2)
  --(3) Gain ATK
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_ATKCHANGE)
  e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_ATTACK_ANNOUNCE)
  e3:SetCondition(s.atkcon)
  e3:SetTarget(s.atktg)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3)
end
--s.listed_names={99980010}
--(1) Special Summon from hand
function s.hspconfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_HN_HDD) and c:GetRank()==4 and c:IsType(TYPE_XYZ)
end
function s.spcon(e,c)
  if c==nil then return true end
  return not Duel.IsExistingMatchingCard(s.hspconfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
  and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
--(2) Xyz Summon
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
  return not Duel.IsExistingMatchingCard(s.hspconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.xyzfilter(c,e,tp)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN_HDD) and c:GetRank()==4 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
  and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if Duel.GetLocationCountFromEx(tp)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
  local tc=g:GetFirst()
  if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)~=0 and c:IsRelateToEffect(e) then
    Duel.Overlay(tc,Group.FromCards(c))
    tc:CompleteProcedure()
  end
end
--(3) Gain ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsSetCard(SET_HN)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  if c:IsRelateToEffect(e) and c:IsFaceup() then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_DAMAGE)
    e1:SetValue(500)
    c:RegisterEffect(e1)
  end
end