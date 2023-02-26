-- Magikular ☆ Extruder
-- Extruder custom card set
local s,id = GetID()
Duel.LoadScript('MagikularAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	-- add from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ritual summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND|LOCATION_EXTRA)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rttg)
	e2:SetOperation(s.rtop)
	c:RegisterEffect(e2)
	-- quick search extruder monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.reccon)
	e3:SetTarget(s.rectg)
	e3:SetOperation(s.recop)
	c:RegisterEffect(e3)
	-- Return this card and 1 card your opponent control
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,3})
	e4:SetTarget(s.btg)
	e4:SetOperation(s.bop)
	c:RegisterEffect(e4)
	-- equip from GY
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,4))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetRange(LOCATION_GRAVE|LOCATION_EXTRA)
	e5:SetCountLimit(1,{id,4})
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
	-- effect gain to equipped target
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,5))
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.sttg)
	e7:SetOperation(s.stop)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetRange(LOCATION_SZONE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetTarget(s.eftg)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
end
function s.thfilter(c)
	return c:IsSetCard(SET_MAGIKULAR) and c:IsLevelBelow(11) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.rtstfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.mfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 and mg:IsContains(c) and c:IsLevelAbove(0) then
		return true
	else return false end
end
function s.lkfilter(c,oc)
	return c:GetLinkedGroup():IsContains(oc)
end
function s.exfilterf(c,tp,mg,rc)
	if c:IsControler(tp) and (c:IsInExtraMZone() or Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)) and
		mg:IsContains(c) and c:IsLevelAbove(0) then
		return true
	else return false end
end
function s.checkrtfilter(c,e,tp,m,ft)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeRitualMaterial(e) and c:IsLevelAbove(0)
end
function s.GetRitualMat(sg,e,tp)
	return Duel.GetLocationCountFromEx(tp,tp)
end
function s.rttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.checkrtfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if chk==0 then
		--if(c:IsLocation(LOCATION_HAND) and not Duel.GetMZoneCount(tp,g)>0) then return end
		--if(c:IsLocation(LOCATION_EXTRA) and not Duel.GetEMZoneCount(tp,g)>0)then return end
		if not (Duel.IsExistingMatchingCard(s.rtstfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		and g:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)) then return end
		if(c:IsLocation(LOCATION_HAND)) then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0) end
		if(c:IsLocation(LOCATION_EXTRA))then return Duel.GetLocationCountFromEx(tp,tp,g,c)>0 end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.checkrtfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,e:GetHandler())
	if not c:IsLocation(LOCATION_HAND|LOCATION_EXTRA) or not g:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c) then return end
	if(c:IsLocation(LOCATION_HAND) and not aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0))then return end
	if(c:IsLocation(LOCATION_EXTRA) and not (Duel.GetLocationCountFromEx(tp,tp,g,c)>0))then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.rtstfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	local mg=Duel.GetRitualMaterial(tp)
	local ft
	if(c:IsLocation(LOCATION_HAND)) then
		ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	else
		ft=Duel.GetLocationCountFromEx(tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	mg=mg:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	local mat=nil
	--Debug.Message(ft)
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,c:GetLevel(),c)
	else
		--Debug.Message("yep")
		if(c:IsLocation(LOCATION_HAND)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=Duel.SelectMatchingCard(tp,s.mfilterf,tp,LOCATION_MZONE,0,1,1,c,tp,mg,c)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=Duel.SelectMatchingCard(tp,s.exfilterf,tp,LOCATION_MZONE,0,1,1,c,tp,mg,c)
		end
		--Duel.HintSelection(mat)
		Debug.Message(mat)
		Duel.SetSelectedCard(mat)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,c:GetLevel(),c)
		mat:Merge(mat2)
	end
	c:SetMaterial(mat)
	Duel.ReleaseRitualMaterial(mat)
	Duel.BreakEffect()
	Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
	c:CompleteProcedure()
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.recfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsSummonableCard() and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE,nil,1,0,LOCATION_GRAVE)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.recfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.btg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) and e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_ONFIELD)
end
function s.bop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_MAGIKULAR)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()~=tp or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	e1:SetValue(s.eqlimit)
	c:RegisterEffect(e1)
end
function s.eqlimit(e,c)
	return c:IsSetCard(SET_MAGIKULAR)
end
function s.eftg(e,c)
	return c == e:GetHandler():GetEquipTarget()
end
function s.stfilter(c)
	return c:GetAttack() > 0
end
function s.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,0)
end
function s.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local g=Duel.GetMatchingGroup(s.stfilter,tp,LOCATION_MZONE,0,e:GetHandler())
		local atk=g:GetSum(Card.GetAttack)
		local tg = g:GetFirst()
		while tg do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			e1:SetValue(0)
			tg:RegisterEffect(e1)
			tg = g:GetNext()
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end