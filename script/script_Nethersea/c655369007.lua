--The Endspeaker
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Attribute and race cannot be changed as rule
	Nethersea.CannotChangeAttributeRace(c)
	--spsummon limit
	Nethersea.SpecialSummonLimit(c)
	--Cannot be used as Fusion material, except for an WATER Aqua/Thuder/Sea serpent/Fish
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(s.fuslimit)
	c:RegisterEffect(e0)
	--Can be treated as any fusion material
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_SINGLE)
	e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0b:SetCode(511002961)
	e0b:SetRange(LOCATION_ALL)
	c:RegisterEffect(e0b)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,{id,1})
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--tohand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,{id,2})
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_DESTROYED)
    e5:SetCondition(s.con)
    c:RegisterEffect(e5)
    local e6=e5:Clone()
    e6:SetCode(EVENT_RELEASE)
    c:RegisterEffect(e6)
end
s.listed_names={CARD_UMI,id,CARD_ENDSPEAKER_WILLOFWEMANY}
s.listed_series={SET_NETHERSEA}
--Cannot be used as Fusion material, except for an WATER Aqua/Thuder/Sea serpent/Fish
function s.fuslimit(e,c)
	if not c then return false end
	return not (c:IsRace(RACE_AQUA|RACE_THUNDER|RACE_SEASERPENT|RACE_FISH) and c:IsAttribute(ATTRIBUTE_WATER))
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetMZoneCount(c:GetControler())>0
	and ( Duel.IsExistingMatchingCard(Nethersea.NetherseaMonsterOrWQ,c:GetControler(),LOCATION_MZONE,0,1,nil)
	or Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_ONFIELD,0,1,nil,CARD_UMI)
	or Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0 )
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.filter(c)
	return c:IsType(TYPE_EFFECT) and c:IsSetCard(SET_NETHERSEA) and c:IsAbleToRemove() and aux.SpElimFilter(c,true)
	and not (c:IsOriginalCode(CARD_ENDSPEAKER) or c:IsOriginalCode(CARD_ENDSPEAKER_WILLOFWEMANY))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) then
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=1 then return end
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		local bd=tc:GetBaseDefense()
		local lv=tc:GetOriginalLevel()
		local e1=Effect.CreateEffect(c)-- inherit strings from WeMany
		e1:SetDescription(aux.Stringid(CARD_ENDSPEAKER_WILLOFWEMANY,9 + (code - 655369000)))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCode(EFFECT_SET_BASE_ATTACK)
		e2:SetValue(ba)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_BASE_DEFENSE)
		e3:SetValue(bd)
		c:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_CHANGE_LEVEL_FINAL)
		e4:SetValue(lv)
		c:RegisterEffect(e4)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
	end
end
function s.con(e)
    return not e:GetHandler():IsLocation(LOCATION_GRAVE)
end
function s.thfilter(c)
    return (Nethersea.NetherseaMonsterOrWQ(c) or c:IsCode(CARD_UMI)) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thchk(sg,e,tp,mg)
	return sg:IsExists(Nethersea.NetherseaMonsterOrWQ,1,nil) 
	and sg:IsExists(Card.IsCode,1,nil,CARD_UMI)
	and not sg:Filter(aux.NOT(Nethersea.NetherseaMonsterOrWQ),nil):IsExists(aux.NOT(Card.IsCode),1,nil,CARD_UMI)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ag=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local g=aux.SelectUnselectGroup(ag,e,tp,1,2,s.thchk,1,tp,HINTMSG_ATOHAND)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end