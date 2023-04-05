--Doom Diva The Melodious Requiem
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Fusion Summon procedure
    c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,84988419,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MELODIOUS))
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--avoid battle damage
	local e3=e1:Clone()
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e3)
    --destroy
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
    --Special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={84988419}--Bloom Diva the Melodious Choire
s.listed_series={SET_MELODIOUS}
s.material_setcode={SET_MELODIOUS}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and (bc:GetSummonType()&SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and c:GetBaseAttack()~=bc:GetBaseAttack()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsRelateToBattle() end
	local atk=bc:GetBaseAttack()
	Duel.SetTargetCard(bc)
    if bc:IsType(TYPE_EFFECT) and bc:IsNegatable() then
        e4:SetCategory(e:GetCategory()|CATEGORY_DISABLE)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,bc,1,0,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if not bc then return false end
    if bc:IsRelateToEffect(e) then
        if bc:IsFaceup() and bc:IsNegatable() then
            local e1=Effect.CreateEffect(c)
		    e1:SetType(EFFECT_TYPE_SINGLE)
		    e1:SetCode(EFFECT_DISABLE)
		    bc:RegisterEffect(e1)
		    local e2=Effect.CreateEffect(c)
		    e2:SetType(EFFECT_TYPE_SINGLE)
		    e2:SetCode(EFFECT_DISABLE_EFFECT)
		    bc:RegisterEffect(e2)
        end
        if Duel.Destroy(bc,REASON_EFFECT)~=0 then
            Duel.Damage(1-tp,bc:GetBaseAttack(),REASON_EFFECT)
        end
    end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.filter2(c,e,tp)
    return c:IsCode(84988419) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter(c,e,tp)
	return (c:IsSetCard(SET_MELODIOUS) and c:IsMonster() and c:IsLevelBelow(4))
    and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
    and Duel.GetMZoneCount(tp)>1 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,g,e,tp)
    g:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,0,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect,nil,e)
	if #tc>=2 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if #tc>0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
