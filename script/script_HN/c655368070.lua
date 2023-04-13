--HN Next Green
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --Xyz Summon
  Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_HN),5,3)
  c:EnableReviveLimit()
  --(1) Gain additional effect
  --(1.1) Cannot chain
  --(3) Special Summon
  HN.HDDNextCommonEffect(c,id,CARD_HN_HDD_GREEN_HEART)
  --(2) Inflict damage
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_BATTLE_CONFIRM)
  e3:SetCountLimit(1)
  e3:SetCondition(s.damcon)
  e3:SetCost(s.damcost)
  e3:SetTarget(s.damtg)
  e3:SetOperation(s.damop)
  c:RegisterEffect(e3,false,1)
end
s.listed_names={CARD_HN_HDD_GREEN_HEART}
--(2) Inflict damage
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetBaseAttack()>0
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  if chk==0 then return true end
  local bc=c:GetBattleTarget()
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
  Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,bc:GetBaseAttack()/2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  local atk=bc:GetBaseAttack()
  if bc:IsFaceup() and atk>0 then
    local rec=Duel.Damage(1-tp,atk,REASON_EFFECT)
    if rec>0 then
      Duel.Recover(tp,rec/2,REASON_EFFECT)
    end
  end
end