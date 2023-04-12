--OTNN Break Burst
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
  --(1) Negate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id,0))
  e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_SPSUMMON)
  e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
  e1:SetCondition(function (e,tp,eg,ep,ev,re,r,rp) return tp~=ep and Duel.GetCurrentChain()==0 end)
  e1:SetTarget(s.negtg)
  e1:SetOperation(s.negop)
  c:RegisterEffect(e1)
end
--(1) Negate
function s.negfilter(c)
  return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_OTNN) and c:GetOverlayCount()>1
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_MZONE,0,1,nil) end
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
  Duel.SelectTarget(tp,s.negfilter,tp,LOCATION_MZONE,0,1,1,nil)
  Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
  Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local tc=Duel.GetFirstTarget()
  if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
  local og=tc:GetOverlayGroup()
  if og:GetCount()==0 then return end
  if Duel.SendtoGrave(og,REASON_EFFECT)~=0 then
    Duel.NegateSummon(eg)
    Duel.Destroy(eg,REASON_EFFECT)
    local dg=Duel.GetOperatedGroup()
    local tc=dg:GetFirst()
    local atk=0
    for tc in aux.Next(dg) do
      local tatk=tc:GetTextAttack()
      if tatk>0 then atk=atk+tatk end
    end
  Duel.Damage(1-tp,atk/2,REASON_EFFECT)
  end
end