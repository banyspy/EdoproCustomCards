--Reoyin x Dark Magician
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('ReoyinAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.matfilter1,s.matfilter2)
	--Negate the activation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.drawcon)
	e1:SetTarget(s.drawtg)
	e1:SetOperation(s.drawop)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,{id,1})
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_MAGICIAN}
s.listed_series={SET_REOYIN}
s.material_setcode={SET_REOYIN}--This include both mentioning archetype and specific name
function s.matfilter1(c,fc,sumtype,tp)
	return c:IsSetCard(SET_REOYIN) and c:IsMonster()
end
function s.matfilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_SPELLCASTER,fc,sumtype,tp) and c:IsMonster()
end
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local dc=Duel.GetOperatedGroup():GetFirst()--Card that is drawn
		Duel.ConfirmCards(1-p,dc)
		if dc:IsMonster() and (dc:IsAttribute(ATTRIBUTE_DARK) or dc:IsRace(RACE_SPELLCASTER)) then
			local bc = Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
			local tc
			repeat
				if #bc>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					tc=aux.SelectUnselectGroup(bc,e,tp,1,1,aux.TRUE,1,tp,HINTMSG_REMOVE,aux.TRUE,nil,true)
				else
					bc:DeleteGroup()
					Duel.ShuffleHand(p)
					return
				end
			until (#tc>0)
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			bc:DeleteGroup()
			tc:DeleteGroup()
		end
		Duel.ShuffleHand(p)
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and (c:GetAttack()==2500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetMZoneCount(tp)>1
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,2,e:GetHandler(),e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	--Must special summon both targets, not only one
	if #sg<#g or Duel.GetMZoneCount(tp)<2 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end
