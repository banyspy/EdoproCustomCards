--DAL CR-unit - Origami
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,SET_DAL),3,2)
  c:EnableReviveLimit()
  --(1) To hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) end)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --(2) Send to GY
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetCountLimit(1)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCost(aux.dxmcostgen(1,1,nil))
  e2:SetTarget(s.tgtg)
  e2:SetOperation(s.tgop)
  c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_names={CARD_DAL_AST_REINFORCEMENT}
s.listed_series={SET_DAL,SET_DALSPIRIT}
--(1) To hand
function s.thfilter(c)
  return c:IsCode(CARD_DAL_AST_REINFORCEMENT) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local tc=Duel.GetFirstMatchingCard(s.thfilter,tp,LOCATION_DECK,0,nil)
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--(2) Send to GY
function s.tgfilter(c,e,tp,ft)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,card)
  return c:IsSetCard(SET_DALSPIRIT) and card:ListsCode(c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,ft) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ft)
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    if Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,tc) then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,tc)
      if g:GetCount()>0 then
        Duel.BreakEffect()
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    end
  end
end