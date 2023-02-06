--Nethersea Hivemind
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --change attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_WATER)
	c:RegisterEffect(e2)
    --change race
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_AQUA)
	c:RegisterEffect(e3)
	--Tribute summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_HAND,0)
	e4:SetCondition(s.otcon)
    e4:SetCountLimit(1,{id,0})
	e4:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e4:SetOperation(s.otop)
	e4:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e4)

	--Set 1 "Nethersea"S/T from deck
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_RELEASE)
	e6:SetCountLimit(1,{id,2})
	e6:SetCondition(s.DoNotRepeatAsk)
	e6:SetTarget(s.gravetarget)
	e6:SetOperation(s.graveoperation)
	c:RegisterEffect(e6)
    local e7=e6:Clone()
    e7:SetCode(EVENT_DESTROYED)
    c:RegisterEffect(e7)
    local e8=e6:Clone()
    e8:SetCode(EVENT_TO_GRAVE)
	e8:SetCondition(s.gravecon)
    c:RegisterEffect(e8)
end
function s.tgfilter(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsSetCard(SET_NETHERSEA)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,e)
end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi>=1
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e)
	if #tc>0 then
        local g1 = Group.CreateGroup()
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
    return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.SendtoGrave(sg,REASON_EFFECT)
	sg:DeleteGroup()
end
function s.gravecon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0
end
function s.DoNotRepeatAsk(e,tp,eg,ep,ev,re,r,rp)
    return not (e:GetHandler():IsLocation(LOCATION_GRAVE) and ((r&REASON_EFFECT)~=0))
end
function s.setcheck(c)
	return c:IsSetCard(SET_NETHERSEA) and c:IsSpellTrap() and c:IsSSetable() and not c:IsCode(id)
end
function s.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setcheck,tp,LOCATION_DECK,0,1,nil) end
end
function s.graveoperation(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setcheck,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tg=g:GetFirst()
		Duel.SSet(tp,tg)
		if tg:IsType(TYPE_QUICKPLAY) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetDescription(aux.Stringid(id,3))
			tg:RegisterEffect(e1)
		end
		if tg:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetDescription(aux.Stringid(id,3))
			tg:RegisterEffect(e1)
		end
	end
end
