--DAL Spirit - Judgement
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Link Summon
  Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DAL),2)
  c:EnableReviveLimit()
  --(1) To hand
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCondition(s.thcon)
  e1:SetTarget(s.thtg)
  e1:SetOperation(s.thop)
  c:RegisterEffect(e1)
  --(2) Inflict damge
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id,3))
  e2:SetCategory(CATEGORY_DAMAGE)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCondition(s.damcon)
  e2:SetTarget(s.damtg)
  e2:SetOperation(s.damop)
  c:RegisterEffect(e2)
  --(3) Indestructable battle/effect
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e3:SetRange(LOCATION_MZONE)
  e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e3:SetCondition(s.indescon)
  e3:SetValue(1)
  c:RegisterEffect(e3)
  local e4=e3:Clone()
  e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  c:RegisterEffect(e4)
  --(4) Special Summon 1 Level 3 "DAL" monster from your hand.
  DAL.CreateSummonLv3OnDestroyByEffectEff(c)
end
--(1) To hand
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
  return (re and re:GetHandler():IsSetCard(SET_DAL)) or e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
  if chk==0 then return lg:GetCount()>0 end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,lg,#lg,0,0)
end
function s.thfilter2(c)
  return c:IsSetCard(SET_DAL) and c:GetLevel()==3 and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
  local lg=e:GetHandler():GetLinkedGroup():Filter(Card.IsAbleToHand,nil)
  local rec=0
  if lg:GetCount()>0 then
    for tc in aux.Next(lg) do
      if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        rec=rec+tc:GetAttack()//2
      end
    end
  end
  if Duel.Recover(tp,rec,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) 
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
      Duel.SendtoHand(g,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,g)
    end
  end   
end
--(2) Inflic damage
function s.damconfilter(c,g)
  return c:IsFaceup() and g:IsContains(c)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  local lg=e:GetHandler():GetLinkedGroup()
  return lg and eg:IsExists(s.damconfilter,1,nil,lg)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local lg=c:GetLinkedGroup()
  if not lg then return end
  local dam=0
  local g=eg:Filter(s.damconfilter,nil,lg)
  for tc in aux.Next(g) do
    dam=dam+tc:GetBaseAttack()//2
  end
  Duel.Damage(1-tp,dam,REASON_EFFECT)
end
--(3) Indestructable battle/effect
function s.indesfil(c)
  return c:IsFaceup() and c:IsSetCard(SET_DAL)
end
function s.indescon(e)
  return e:GetHandler():GetLinkedGroup():IsExists(s.indesfil,1,nil)
end