--DAL Rasiel - Tome of Revelation
--Scripted by Raivost
--Fix for compatibility with edopro by banyspy
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --(1) Copy Effect
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,7))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.cetg)
    e1:SetOperation(s.ceop)
    c:RegisterEffect(e1)
end
s.listed_series={SET_DAL}
--(1) Copy Effect
function s.cefilter(c)
    return c:IsSetCard(SET_DAL) and (c:IsNormalSpell() or c:IsQuickPlaySpell()) and c:IsAbleToRemoveAsCost()
    and not c:IsCode(id) and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
    if chk==0 then return g:GetCount()>0 and Duel.IsExistingMatchingCard(s.cefilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cefilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
    local bantg=g:GetFirst()
    if not bantg or Duel.Remove(bantg,POS_FACEUP,REASON_COST)==0 then return end
    g:GetFirst():CreateEffectRelation(e)
    local tg=te:GetTarget()
    if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
end
function s.ceop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
    if g:GetCount()==0 then return end
    local tc=g:RandomSelect(tp,1):GetFirst()
    Duel.ConfirmCards(tp,tc)
    if tc:IsType(TYPE_FUSION) then
      s.lockeff(e,tp,TYPE_FUSION)
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
    end
    if tc:IsType(TYPE_SYNCHRO) then
      s.lockeff(e,tp,TYPE_SYNCHRO)
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
    end
    if tc:IsType(TYPE_XYZ) then
      s.lockeff(e,tp,TYPE_XYZ)
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
    end
    if tc:IsType(TYPE_PENDULUM) then
      s.lockeff(e,tp,TYPE_PENDULUM)
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
    end
    if tc:IsType(TYPE_LINK) then
      s.lockeff(e,tp,TYPE_LINK)
      Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
    end
    --Apply the banished card effect
    local te=e:GetLabelObject()
    if not te then return end
    if not te:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,5))
    e:SetLabelObject(te:GetLabelObject())
    local op=te:GetOperation()
    if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function s.lockeff(e,tp,sumtype)
      local e1=Effect.CreateEffect(e:GetHandler())
      if sumtype==TYPE_FUSION then
        e1:SetDescription(aux.Stringid(id,0))
      elseif sumtype==TYPE_SYNCHRO then
        e1:SetDescription(aux.Stringid(id,1))
      elseif sumtype==TYPE_XYZ then
        e1:SetDescription(aux.Stringid(id,2))
      elseif sumtype==TYPE_PENDULUM then
        e1:SetDescription(aux.Stringid(id,3))
      elseif sumtype==TYPE_LINK then
        e1:SetDescription(aux.Stringid(id,4))
      end
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
      e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
      e1:SetLabel(sumtype)
      e1:SetTargetRange(0,1)
      e1:SetTarget(s.sumlimit)
      e1:SetReset(RESET_PHASE+PHASE_END,2)
    Duel.RegisterEffect(e1,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
    return c:IsType(e:GetLabel())
end