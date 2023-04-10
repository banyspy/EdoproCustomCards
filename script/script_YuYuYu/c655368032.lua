--YuYuYu Jukai (Actually sea of tree?)
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
  --(1) Search
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_FZONE)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.thcost)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --(3) Gain LP
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,2))
  e3:SetCategory(CATEGORY_RECOVER)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetCode(EVENT_PHASE+PHASE_END)
  e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e3:SetRange(LOCATION_FZONE)
  e3:SetCountLimit(1)
  e3:SetTarget(s.rectg)
  e3:SetOperation(s.recop)
  c:RegisterEffect(e3)
  --Counter
  if not s.global_check then
    s.global_check=true
    s[0]=0
    s[1]=0
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetOperation(s.addcount)
    Duel.RegisterEffect(e4,0)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_PHASE_START+PHASE_DRAW)
    e5:SetOperation(s.clearop)
    Duel.RegisterEffect(e5,0)
  end
end
--(1) Search
function s.thcostfilter(c)
  return c:IsSetCard(SET_YUYUYU) and c:IsRace(RACE_FAIRY) and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
  local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
  Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c)
  return c:IsSetCard(SET_YUYUYU) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
  if g:GetCount()>0 then
    Duel.SendtoHand(g,nil,REASON_EFFECT)
  Duel.ConfirmCards(1-tp,g)
  end
end
--(3) Gain LP
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetTargetPlayer(tp)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500*s[tp])
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
  if not e:GetHandler():IsRelateToEffect(e) then return end
  local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
  Duel.Recover(p,500*s[tp],REASON_EFFECT)
end
--Counter
function s.counterfilter(c,tp)
  return c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function s.addcount(e,tp,eg,ep,ev,re,r,rp)
  local tc=eg:GetFirst()
  while tc do
    if tc:IsReason(REASON_BATTLE) then
      local rc=tc:GetReasonCard()
      if rc and rc:IsSetCard(SET_YUYUYU) and bit.band(rc:GetType(),0x81)==0x81 and rc:IsRelateToBattle() then
        local p=rc:GetReasonPlayer()
        s[p]=s[p]+1
      end
    elseif re then
      local rc=re:GetHandler()
      if eg:IsExists(s.counterfilter,1,nil,tp) and rc and rc:IsSetCard(SET_YUYUYU) 
      and bit.band(rc:GetType(),0x81)==0x81 and re:IsActiveType(TYPE_MONSTER) then
        local p=rc:GetReasonPlayer()
        s[p]=s[p]+1
      end
    end
    tc=eg:GetNext()
  end
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
  s[0]=0
  s[1]=0
end