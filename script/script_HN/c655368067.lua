--HN Next Purple
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
  HN.HDDNextCommonEffect(c,id,CARD_HN_HDD_PURPLE_HEART)
  --(2) Gain ATK
  local e3=Effect.CreateEffect(c)
  e3:SetDescription(aux.Stringid(id,1))
  e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e3:SetCode(EVENT_BATTLE_CONFIRM)
  e3:SetCountLimit(1)
  e3:SetCondition(s.atkcon)
  e3:SetCost(s.atkcost)
  e3:SetTarget(s.atktg)
  e3:SetOperation(s.atkop)
  c:RegisterEffect(e3,false,1)
end
s.listed_names={CARD_HN_HDD_PURPLE_HEART}
--(2) Gain ATK
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and bc:GetBaseAttack()>0
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
  e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
  local c=e:GetHandler()
  local bc=c:GetBattleTarget()
  local ct=bc:GetBaseAttack()//1500
  if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
  e:GetHandler():GetBattleTarget():CreateEffectRelation(e)
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=c:GetBattleTarget()
  if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() then return end
  if c:IsRelateToEffect(e) and c:IsFaceup() then
    local atk=tc:GetBaseAttack()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetValue(atk)
    c:RegisterEffect(e1)
    local ct=atk//1500
    if ct>0 then
      Duel.Draw(tp,ct,REASON_EFFECT)
    end
  end
end