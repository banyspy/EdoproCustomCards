-- ProjektStarBlast Visel
-- scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Discard and draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
    -- equip
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
    -- effect gain to equipped target
    --Attack directly
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetCode(EFFECT_DIRECT_ATTACK)
    --Unaffected by opponent card
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_SINGLE)
	e3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCode(EFFECT_IMMUNE_EFFECT)
	e3b:SetValue(function (e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
    --Grant effect to equipped monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.eftg)
	e3:SetLabelObject({e3a,e3b})
	c:RegisterEffect(e3)
	--copy effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_PROJEKTSTARBLAST_KIANA}
s.listed_series={SET_PROJEKTSTARBLAST}
function s.cfilter(c)
	return c:IsSetCard(SET_PROJEKTSTARBLAST) and c:IsDiscardable()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_PROJEKTSTARBLAST_KIANA)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE,0,1,nil)
        and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
    if not tc then return end
    Duel.HintSelection(tc,true)
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function (e,c) return c:IsCode(CARD_PROJEKTSTARBLAST_KIANA) end)
	c:RegisterEffect(e1)
end
function s.eftg(e,c)
	return (c == e:GetHandler():GetEquipTarget()) and c:IsCode(CARD_PROJEKTSTARBLAST_KIANA)
end
function s.cpfilter(c)
	return c:IsSetCard(SET_PROJEKTSTARBLAST) and c:IsSpellTrap() and c:IsAbleToDeckAsCost() and c:CheckActivateEffect(false,true,true)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		if not te then return end
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) 
    and e:GetHandler():IsAbleToDeckAsCost() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(g+e:GetHandler(),true)
	if Duel.SendtoDeck(g+e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	te:SetLabel(e:GetLabel())
	te:SetLabelObject(e:GetLabelObject())
end
