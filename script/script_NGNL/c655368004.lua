--NGNL Jibril
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Scale Change
  NGNL.ForceChangeScaleEffect(c)
  --(2) Send to GY
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetCategory(CATEGORY_TOGRAVE)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_CHAINING)
  e2:SetCountLimit(1)
  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCondition(s.tgcon)
  e2:SetTarget(s.tgtg)
  e2:SetOperation(s.tgop)
  c:RegisterEffect(e2)
  --(3) Shuffle
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3))
  e3:SetCategory(CATEGORY_TODECK)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_DRAW)
  e3:SetRange(LOCATION_PZONE)
  e3:SetCondition(s.tdcon)
  e3:SetTarget(s.tdtg)
  e3:SetOperation(s.tdop)
  c:RegisterEffect(e3)
  --Monster Effects
  --(1) Special Summon
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,4))
  e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
  e5:SetType(EFFECT_TYPE_IGNITION)
  e5:SetRange(LOCATION_HAND)
  e5:SetTarget(s.sptg)
  e5:SetOperation(s.spop)
  c:RegisterEffect(e5)
  --(2) Discard
  local e6=Effect.CreateEffect(c)
  e6:SetDescription(aux.Stringid(id,5))
  e6:SetCategory(CATEGORY_TOGRAVE)
  e6:SetType(EFFECT_TYPE_IGNITION)
  e6:SetRange(LOCATION_MZONE)
  e6:SetCountLimit(1,id)
  e6:SetTarget(s.distg)
  e6:SetOperation(s.disop)
  c:RegisterEffect(e6)
  --(3) Avoid battle damage
  local e7=Effect.CreateEffect(c)
  e7:SetType(EFFECT_TYPE_SINGLE)
  e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e7:SetValue(1)
  c:RegisterEffect(e7)
end
s.roll_dice=true
--Pendulum Effects
--(1) Scale Change
--Already handled by BanyspyAux file
--(2) Send to GY 1
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
  return re:IsHasType(EFFECT_TYPE_ACTIVATE) and ep~=tp
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_HAND+LOCATION_DECK,0,nil,re:GetHandler():GetCode())
  if chk==0 then return g:GetCount()>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetMatchingGroup(Card.IsCode,ep,LOCATION_HAND+LOCATION_DECK,0,nil,re:GetHandler():GetCode())
  Duel.SendtoGrave(g,REASON_EFFECT)
end
--(3) Shuffle
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
  local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
  local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
  if sg:GetCount()>0 then
    Duel.HintSelection(sg)
    Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
  end
end
--Monster Effects
--(1) Special Summon
function s.tgfilter2(c)
  return c:IsSetCard(SET_NGNL) and c:IsAbleToGrave()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND,0,1,c)
  and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND,0,1,1,c)
  if Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
    if not c:IsRelateToEffect(e) then return end
      if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
      and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_HAND) then
        Duel.SendtoGrave(c,REASON_RULE)
      end
  end
end
--(2) Discard
function s.disfilter(c)
  return c:IsDiscardable(REASON_EFFECT)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
  and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
  e:SetLabel(Duel.SelectOption(tp,70,71,72))
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
  local ac=e:GetLabel()
  local ty=TYPE_MONSTER
  if ac==1 then ty=TYPE_SPELL
  elseif ac==2 then ty=TYPE_TRAP end
  if Duel.DiscardHand(tp,s.disfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    local sg=g:Filter(Card.IsType,nil,ty)
    if sg:GetCount()>0 then
      Duel.SendtoGrave(sg,REASON_EFFECT)
    end
  end
end