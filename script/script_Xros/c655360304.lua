--Xros Kaze
--scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Place 1 "Xros" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	--e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tftg)
	e2:SetOperation(s.tfop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
    local e4=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
    --Fusion
    --local params = {aux.FilterBoolFunction(Card.IsSetCard,SET_XROS),nil,nil,nil,Fusion.ForcedHandler}
	local params = {aux.FilterBoolFunction(Card.IsSetCard,SET_XROS),nil,nil,nil,nil}
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,2})
	e5:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e5:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e5)
    --Shuffle "Xros" Fusion to Extra and add this card to hand
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_GRAVE)
    e6:SetCountLimit(1,{id,3})
	e6:SetTarget(s.tdtg)
	e6:SetOperation(s.tdop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_XROS}
function s.spconfilter(c)
	return c:IsSetCard(SET_XROS) and c:IsMonster() and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
        (Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0 
        or Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except "Xros" Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(655360301,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(SET_XROS)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard Check
	aux.addTempLizardCheck(c,tp,function(e,c) return not (c:IsSetCard(SET_XROS)) end)
end

function s.tffilter(c,tp)
	return c:IsSetCard(SET_XROS) and not c:IsForbidden() and c:CheckUniqueOnField(tp) and ( 
        (c:IsContinuousSpell()   and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) or
        (c:IsFieldSpell()        and c:GetActivateEffect():IsActivatable(tp,true,true)) or
        (c:IsType(TYPE_PENDULUM) and c:IsMonster() and Duel.CheckPendulumZones(tp))
    )
end
function s.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tfop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
        if tc:IsContinuousSpell() then
		    Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        elseif tc:IsFieldSpell() then   
            Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
        elseif tc:IsType(TYPE_PENDULUM) and tc:IsMonster() then
            Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
	end
end

function s.tdfilter(c)
	return c:IsSetCard(SET_XROS) and c:IsMonster() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() and chkc~=c end
	if chk==0 then return c:IsAbleToHand()
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end