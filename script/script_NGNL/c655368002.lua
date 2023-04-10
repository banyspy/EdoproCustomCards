--NGNL Shiro
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  Pendulum.AddProcedure(c)
  --Pendulum Effects
  --(1) Scale Change
  NGNL.ForceChangeScaleEffect(c)
  --(2) Reveal
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,2))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_DRAW)
  e2:SetCountLimit(1)
  e2:SetRange(LOCATION_PZONE)
  e2:SetCondition(s.revcon)
  e2:SetTarget(s.revtg)
  e2:SetOperation(s.revop)
  c:RegisterEffect(e2)
  --(3) Discard
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,3))
  e3:SetCategory(CATEGORY_HANDES)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e3:SetCode(EVENT_DRAW)
  e3:SetRange(LOCATION_PZONE)
  e3:SetCondition(s.discon)
  e3:SetTarget(s.distg)
  e3:SetOperation(s.disop)
  c:RegisterEffect(e3)
  --Monster Effects
  --(1) Special Summon
  local e4=Effect.CreateEffect(c)
  e4:SetDescription(aux.Stringid(id,4))
  e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e4:SetCode(EVENT_LEAVE_FIELD)
  e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e4:SetCondition(s.spcon)
  e4:SetTarget(s.sptg)
  e4:SetOperation(s.spop)
  c:RegisterEffect(e4)
  --(2) Send to GY 
  local e5=Effect.CreateEffect(c)
  e5:SetDescription(aux.Stringid(id,5))
  e5:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
  e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e5:SetRange(LOCATION_MZONE)
  e5:SetCode(EVENT_TO_HAND)
  e5:SetCountLimit(1)
  e5:SetCondition(s.tgcon)
  e5:SetTarget(s.tgtg)
  e5:SetOperation(s.tgop)
  c:RegisterEffect(e5)
  --Avoid battle damage
  local e6=Effect.CreateEffect(c)
  e6:SetType(EFFECT_TYPE_SINGLE)
  e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e6:SetValue(1)
  c:RegisterEffect(e6)
end
s.roll_dice=true
--Pendulum Effects
--(1) Scale Change
--Already handled by BanyspyAux file
--(2) Reveal
function s.revcon(e,tp,eg,ep,ev,re,r,rp)
  return ep==tp
end
function s.revfilter(c,e,tp)
  return c:IsSetCard(SET_NGNL) and c:IsType(TYPE_MONSTER) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgfilter1(c)
  return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and eg:IsExists(s.revfilter,1,nil,e,tp)
  and Duel.IsExistingMatchingCard(s.tgfilter1,tp,LOCATION_DECK,0,1,nil) end
  local g=eg:Filter(s.revfilter,nil,e,tp)
  if g:GetCount()==1 then
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
    Duel.SetTargetCard(g)
  else
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg=g:Select(tp,1,1,nil)
    Duel.ConfirmCards(1-tp,sg)
    Duel.ShuffleHand(tp)
    Duel.SetTargetCard(sg)
  end
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  local tc=Duel.GetFirstTarget()
  if tc:IsLocation(LOCATION_DECK) or (tc:IsLocation(LOCATION_REMOVED) and tc:IsFacedown()) 
  or (tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)<=0 and tc:IsFaceup()) then return end
  if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoGrave(g,REASON_EFFECT)
    end
  end
end
--(3) Discard
function s.discon(e,tp,eg,ep,ev,re,r,rp)
  return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
  if g:GetCount()~=0 then
    local sg=g:RandomSelect(1-tp,1)
    Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
  end
end
--Monster Effects
--(1) Special Summon 
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
  and not e:GetHandler():IsLocation(LOCATION_DECK)
end
function s.spfilter(c,e,tp)
  return c:IsSetCard(SET_NGNL) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanDraw(1-tp,1)
  and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
  Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
  if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
    Duel.Draw(1-tp,1,REASON_EFFECT)
  end
end
--(2) Send to GY
function s.tgconfilter(c,tp)
  return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
  return eg:IsExists(s.tgconfilter,1,nil,1-tp)
end
function s.tgfilter2(c)
  return c:IsSetCard(SET_NGNL) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.disfilter(c,e,tp)
  return c:IsRelateToEffect(e) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
  local g=eg:Filter(s.tgconfilter,nil,1-tp)
  Duel.SetTargetCard(g)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
  Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.tgfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
  local sg=eg:Filter(s.disfilter,nil,e,1-tp)
  if g:GetCount()~=0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
    if sg:GetCount()==0 then
      elseif sg:GetCount()==1 then
        Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
      else
        Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
        local dg=sg:Select(1-tp,1,1,nil)
        Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
    end
  end
end