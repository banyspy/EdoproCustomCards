--HN CPU Memory
--Scripted by Raivost
local s,id=GetID()
function s.initial_effect(c)
  --(1) Xyz Summon
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetTarget(s.xyztg)
  e1:SetOperation(s.xyzop)
  c:RegisterEffect(e1)
  --(2) Return to Extra Deck
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCost(aux.bfgcost)
  e2:SetTarget(s.rtdtg)
  e2:SetOperation(s.rtdop)
  c:RegisterEffect(e2)
end
--(1) Xyz Summon
function s.xyzfilter1(c,e,tp)
  return c:IsFaceup() and c:IsSetCard(SET_HN) and c:IsLevelAbove(3) and Duel.GetLocationCountFromEx(tp,tp,c)>0 
  and c:IsType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(s.xyzfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.xyzfilter2(c,e,tp,mc)
  if c.rum_limit and not c.rum_limit(mc,e) then return false end
  return mc:IsType(TYPE_MONSTER,c,SUMMON_TYPE_XYZ,tp) and c:IsSetCard(SET_HN_HDD) and c:IsRankBelow(4) 
  and c:IsType(TYPE_MONSTER) and mc:IsCanBeXyzMaterial(c,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.xyzfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.xyzfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if Duel.GetLocationCountFromEx(tp,tp,tc)<=0 then return end
  if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.xyzfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
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
--(2) Return to Extra Deck
function s.rtdfilter(c)
  return c:IsSetCard(SET_HN_HDD) and c:IsType(TYPE_MONSTER) and c:IsAbleToExtra()
end
function s.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.rtdfilter,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
  Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
function s.rtdop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectMatchingCard(tp,s.rtdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
  end
end