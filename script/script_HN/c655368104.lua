--HN Dimension Zero
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Activate
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_ACTIVATE)
  e0:SetCode(EVENT_FREE_CHAIN)
  c:RegisterEffect(e0)
  --(1) Xyz Summon
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL) -- use to has EFFECT_FLAG_CHAIN_UNIQUE
  e1:SetRange(LOCATION_FZONE)
  e1:SetCountLimit(1)
  e1:SetTarget(s.xyztg1)
  e1:SetOperation(s.xyzop1)
  c:RegisterEffect(e1)
  --(2) Xyz Summon 2
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,0))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL) -- use to has EFFECT_FLAG_CHAIN_UNIQUE
  e2:SetRange(LOCATION_FZONE)
  e2:SetCountLimit(1)
  e2:SetCost(function(e,_,_,_,_,_,_,_,chk) e:SetLabel(1) if chk==0 then return true end end)
  e2:SetTarget(s.xyztg2)
  e2:SetOperation(s.xyzop2)
  c:RegisterEffect(e2)
end
--(3 Xyz Summon
function s.xyzconfilter(c,e,tp)
  local ck=Duel.GetCurrentPhase()
  return c:IsSetCard(SET_HN) and c:GetSummonPlayer()==tp and not c:IsType(TYPE_XYZ) and ck>=PHASE_BATTLE_START and ck<=PHASE_BATTLE
end
function s.mfilter(c)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and not c:IsType(TYPE_TOKEN)
end
function s.xyzfilter1(c,mg)
  return c:IsSetCard(SET_HN) and c:IsXyzSummonable(mg)
end
function s.xyztg1(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then
    local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
    return Duel.IsExistingMatchingCard(s.xyzfilter1,tp,LOCATION_EXTRA,0,1,nil,g)
    and eg:IsExists(s.xyzconfilter,1,nil,e,tp) 
  end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop1(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE,0,nil)
  local xyzg=Duel.GetMatchingGroup(s.xyzfilter1,tp,LOCATION_EXTRA,0,nil,g)
  if xyzg:GetCount()>0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
    Duel.XyzSummon(tp,xyz,g,1,99)
  end
end
--(2)
function s.xyzcostfilter(c)
  return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsSetCard(SET_HN_NATION) and c:IsAbleToGraveAsCost()
end
function s.xyzfilter2(c,e,tp)
  return c:IsSetCard(SET_HN) and c:GetRank()==4 and c:GetSummonPlayer()==tp and c:IsLocation(LOCATION_MZONE)
  and c:IsPreviousLocation(LOCATION_EXTRA) and c:IsCanBeEffectTarget(e) and Duel.GetLocationCountFromEx(tp,tp,c)>0  
  and Duel.IsExistingMatchingCard(s.xyzfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
end
function s.xyzfilter3(c,e,tp,mc,code)
  if c.rum_limit and not c.rum_limit(mc,e) then return false end
  return mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_HN) and c:ListsCode(code) and c:GetRank()==5
  and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then
    if e:GetLabel()==0 then return false end
    e:SetLabel(0)
    return eg:IsExists(s.xyzfilter2,1,nil,e,tp)
    and Duel.IsExistingMatchingCard(s.xyzcostfilter,tp,LOCATION_SZONE,0,1,nil)
  end
  e:SetLabel(0)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.xyzcostfilter,tp,LOCATION_SZONE,0,1,1,nil)
  Duel.SendtoGrave(g,REASON_COST)
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  local sg=eg:FilterSelect(tp,s.xyzfilter2,1,1,nil,e,tp)
  Duel.SetTargetCard(sg)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop2(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp,tp,tc)<=0 then return end
  if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.xyzfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
  local sc=g:GetFirst()
  if sc then
    local mg=tc:GetOverlayGroup()
    if mg:GetCount()~=0 then
      Duel.Overlay(sc,mg)
    end
    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc,Group.FromCards(tc))
    Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
  end
end