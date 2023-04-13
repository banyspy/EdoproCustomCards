--HN Gust
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Copy effect
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
  e1:SetCountLimit(1,id)
  e1:SetCost(s.cecost)
  e1:SetTarget(s.cetg)
  e1:SetOperation(s.ceop)
  c:RegisterEffect(e1)
end
--(1) Copy effect
function s.cpfiltercost(c)
  return c:IsSetCard(SET_HN) and c:GetType()==TYPE_SPELL and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
function s.cecost(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.cpfiltercost,tp,LOCATION_GRAVE,0,1,nil) end
  Duel.SendtoGrave(e:GetHandler(),REASON_COST)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
  local g=Duel.SelectMatchingCard(tp,s.cpfiltercost,tp,LOCATION_GRAVE,0,1,1,nil)
  Duel.Remove(g,POS_FACEUP,REASON_COST)
  e:SetLabelObject(g:GetFirst())
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
  if chkc then
  	local te=e:GetLabelObject()
  	local tg=te:GetTarget()
  	return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
  end
  if chk==0 then return true end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  local g=e:GetLabelObject()
  local te,ceg,cep,cev,cre,cr,crp=g:CheckActivateEffect(false,true,true)
  Duel.ClearTargetCard()
  g:CreateEffectRelation(e)
  local tg=te:GetTarget()
  if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
  te:SetLabelObject(e:GetLabelObject())
  e:SetLabelObject(te)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
  local te=e:GetLabelObject()
  if not te then return end
  if not te:GetHandler():IsRelateToEffect(e) then return end
  e:SetLabelObject(te:GetLabelObject())
  local op=te:GetOperation()
  if op then op(e,tp,eg,ep,ev,re,r,rp) end
end