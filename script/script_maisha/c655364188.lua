--Blade of Truth
--scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,id)
	aux.AddEquipProcedure(c,0)
	--Prevent effect negation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISEFFECT)
	e1:SetRange(LOCATION_SZONE)
	e1:SetValue(s.eqv)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.eqv)
	c:RegisterEffect(e2)
    --equip from hand as quick effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,{id,0})
    e3:SetRange(LOCATION_HAND)
	e3:SetTarget(s.eqhtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
    --Destroy cards from both side
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_DESTROY)
	e3a:SetType(EFFECT_TYPE_QUICK_O)
	e3a:SetCode(EVENT_FREE_CHAIN)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCountLimit(1)
	e3a:SetTarget(s.destg)
	e3a:SetOperation(s.desop)
    --Inflict damage at the end phase
	local e3b=Effect.CreateEffect(c)
	e3b:SetDescription(aux.Stringid(id,2))
	e3b:SetCategory(CATEGORY_DAMAGE)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3b:SetCode(EVENT_PHASE+PHASE_END)
	e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3b:SetRange(LOCATION_MZONE)
	e3b:SetCountLimit(1)
	e3b:SetTarget(s.dmgtg)
	e3b:SetOperation(s.dmgop)
    --Grant effect to equipped monster
	local e3c=Effect.CreateEffect(c)
	e3c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3c:SetRange(LOCATION_SZONE)
	e3c:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3c:SetTarget(s.eftg)
	e3c:SetLabelObject(e3a)
	c:RegisterEffect(e3c)
	local e3d=e3c:Clone()
	e3d:SetLabelObject(e3b)
	c:RegisterEffect(e3d)
	--equip
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
end
s.listed_names={655364181}
function s.eqv(e,ct)
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return (te:GetHandler() == e:GetHandler():GetEquipTarget())
end
function s.eqfilter2(c)
	return c:IsFaceup() and c:IsCode(655364181)
end
function s.eqhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter2(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp) and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter2(chkc) end
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp) and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) and Duel.IsExistingMatchingCard(s.eqfilter2,tp,LOCATION_MZONE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	    local tc=Duel.SelectMatchingCard(tp,s.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
        if tc then 
            Duel.HintSelection(tc,true)
            Duel.Equip(tp,c,tc:GetFirst())
        end
	end
end
function s.eftg(e,c)
	return (c == e:GetHandler():GetEquipTarget()) and c:IsCode(655364181)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil)
    and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	    local g1=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	    local g2=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	    g1:Merge(g2)
        Duel.HintSelection(g1,true)
		Duel.Destroy(g1,REASON_EFFECT)
	end
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)*100
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)*100
	Duel.Damage(p,dam,REASON_EFFECT)
end
