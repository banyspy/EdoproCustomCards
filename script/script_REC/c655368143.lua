--RE:C Meteora Osterreich
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Special Summon from hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1)
  e1:SetTarget(s.hsptg)
  e1:SetOperation(s.hspop)
  c:RegisterEffect(e1)
  --(2) Reveal
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_DISCARD)
  e2:SetCondition(s.excacon)
  e2:SetTarget(s.excatg)
  e2:SetOperation(s.excaop)
  c:RegisterEffect(e2)
  --(3) Indes by effects
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD)
  e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
  e3:SetRange(LOCATION_MZONE)
  e3:SetTargetRange(LOCATION_MZONE,0)
  e3:SetTarget(s.indtg)
  e3:SetValue(s.indval)
  c:RegisterEffect(e3)
  --(4) Effect gain
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
  e4:SetCode(EVENT_BE_MATERIAL)
  e4:SetCondition(s.efgcon)
  e4:SetOperation(s.efgop)
  c:RegisterEffect(e4)
end
--(1) Special Summon from hand
function s.hspfilter(c)
  return c:IsDiscardable(REASON_EFFECT)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) 
  and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
  if Duel.DiscardHand(tp,s.hspfilter,1,1,REASON_EFFECT+REASON_DISCARD,e:GetHandler())~=0 and e:GetHandler():IsRelateToEffect(e) 
  and Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)~=0 then
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
  end
end
--(2) Reveal
function s.excacon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsReason(REASON_EFFECT)
end
function s.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) 
  and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.excaop(e,tp,eg,ep,ev,re,r,rp)
  if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
  Duel.ConfirmDecktop(tp,1)
  local g=Duel.GetDecktopGroup(tp,1)
  local tc=g:GetFirst()
  if tc:IsSetCard(SET_REC) and tc:IsAbleToHand() then
    Duel.DisableShuffleCheck()
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
    Duel.ShuffleHand(tp)
  else
    Duel.DisableShuffleCheck()
    Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
  end
end
--(3) Indes by effect
function s.indtg(e,c)
  return c:IsSetCard(SET_REC)
end
function s.indval(e,re,r,rp)
  if r&REASON_EFFECT~=0 then
    return 1
  else return 0 end
end
--(4) Effect gain
function s.efgcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  return r==REASON_LINK and c:GetReasonCard():IsSetCard(SET_REC)
end
function s.efgop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local rc=c:GetReasonCard()
  if not rc then return end
  --(4.1) Negate attack
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,2))
  e1:SetCategory(CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_BE_BATTLE_TARGET)
  e1:SetCountLimit(1)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
  rc:RegisterEffect(e1,true)
  if not rc:IsType(TYPE_EFFECT) then
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetValue(TYPE_EFFECT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e2,true)
  end
  rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
end
--(4.1) Negate attack
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local a=Duel.GetAttacker()
  local ct=math.floor(a:GetAttack()/1000)
  if Duel.NegateAttack()~=0 and a and ct>0 and Duel.IsPlayerCanDraw(tp,ct)
  and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
    Duel.Draw(tp,ct,REASON_EFFECT)
  end
end