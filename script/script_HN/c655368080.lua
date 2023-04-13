--HN Bouquet
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),2)
  --(1) Shuffle into the Deck
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCode(EVENT_BE_MATERIAL)
  e1:SetCountLimit(1,id)
  e1:SetCondition(s.tdcon)
  e1:SetTarget(s.tdtg)
  e1:SetOperation(s.tdop)
  c:RegisterEffect(e1)
  --(2) Indes by battle or card effects
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e2:SetValue(1)
  e2:SetCondition(function(e) return e:GetHandler():GetMutualLinkedGroupCount()>0 end)
  c:RegisterEffect(e2)
  local e3=e2:Clone()
  e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  c:RegisterEffect(e3)
  --(3) Cannot activate Spells/Traps
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_FIELD)
  e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e4:SetCode(EFFECT_CANNOT_ACTIVATE)
  e4:SetRange(LOCATION_MZONE)
  e4:SetTargetRange(0,1)
  e4:SetValue(s.aclimit)
  e4:SetCondition(s.actcon)
  c:RegisterEffect(e4)
end
--(1)
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(SET_HN)
end
function s.tdfilter(c)
    return c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and c:IsAbleToDeck()
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_HN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
  local b2=Duel.IsPlayerCanDraw(tp,1)
  if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and (b1 or b2) end
  Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)~=0 then
    Duel.ShuffleDeck(tp)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    local b2=Duel.IsPlayerCanDraw(tp,1)
    if b1 and b2 then
      op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
      op=Duel.SelectOption(tp,aux.Stringid(id,2))
    else
      op=Duel.SelectOption(tp,aux.Stringid(id,3))+1
    end
    if op==0 then
      Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
      local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
      if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
      end
    else
      Duel.Draw(tp,1,REASON_EFFECT)
    end
  end
end
--(3) Cannot activate Spells/Traps
function s.actfilter(c,tp)
  return c and c:IsFaceup() and c:IsSetCard(SET_HN) and c:IsType(TYPE_MONSTER) and (c:IsType(TYPE_XYZ) or c:IsType(TYPE_LINK)) and c:IsControler(tp)
end
function s.aclimit(e,re,tp)
  return re:IsHasType(EFFECT_TYPE_ACTIVATE) and not re:GetHandler():IsImmuneToEffect(e)
end
function s.actcon(e)
  local tp=e:GetHandlerPlayer()
  return s.actfilter(Duel.GetAttacker(),tp) or s.actfilter(Duel.GetAttackTarget(),tp)
end