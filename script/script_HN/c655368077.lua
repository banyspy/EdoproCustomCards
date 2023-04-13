--HN HDD Purple Sister
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_HN),3,2)
  c:EnableReviveLimit()
  --(1) Search
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1,id)
  e1:SetHintTiming(TIMING_DAMAGE_STEP)
  e1:SetCondition(s.thcon)
  e1:SetCost(s.thcost)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1,false,1)
end
--(1) Search
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
  and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thfilter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSetCard(SET_HN) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
function s.xyzfilter(c,e,tp)
  return c:IsSetCard(SET_HN_HDD) and c:GetRank()==4  and e:GetHandler():IsCanBeXyzMaterial(c,tp)
  and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local hg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if hg:GetCount()>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0 and hg:GetFirst():IsLocation(LOCATION_HAND) then
  Duel.ConfirmCards(1-tp,hg)
  if Duel.GetLocationCountFromEx(tp,tp,c)<=0  or c:IsFacedown() or not c:IsRelateToEffect(e) or c:IsControler(1-tp) or c:IsImmuneToEffect(e) then return end
  if Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local sc=g:GetFirst()
    if sc then
      local mg=c:GetOverlayGroup()
    if mg:GetCount()~=0 then
      Duel.Overlay(sc,mg)
    end
    sc:SetMaterial(Group.FromCards(c))
    Duel.Overlay(sc,Group.FromCards(c))
    Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
    sc:CompleteProcedure()
    end
    end
  end
end