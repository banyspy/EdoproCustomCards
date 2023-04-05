--Allegro The Melodious Siren
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) 
        if c:IsSetCard(SET_MELODIOUS) then return false end
	    return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
	c:RegisterEffect(e1)
    --Prevent trap from activated after pendulum summon for a turn
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,1)
    e2:SetCondition(s.checkcondition)
	e2:SetValue(function (e,re,tp)
        local rc=re:GetHandler()
        return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or rc:IsOnField()) and rc:IsTrap()
    end)
	c:RegisterEffect(e2)
    --Add on summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,0})
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
    local e3b=e3:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
    --Reflect battle damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_MELODIOUS))
	e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetValue(1)
	c:RegisterEffect(e4)
    aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_MELODIOUS}
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	for tc in aux.Next(eg) do
		if tc:IsSetCard(SET_MELODIOUS) and tc:IsSummonType(SUMMON_TYPE_PENDULUM) then
			if tc:GetSummonPlayer()==0 then p1=true else p2=true end
		end
	end
	if p1 then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
function s.checkcondition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetFlagEffect(c:GetControler(),id)>0 and Duel.IsExistingMatchingCard(Card.IsSetCard,c:GetControler(),LOCATION_PZONE,0,1,c,SET_MELODIOUS)
end
function s.cfilter(c,lv)
	return c:GetLevel()==lv
end
function s.filter(c,e,tp)
	return c:IsSetCard(SET_MELODIOUS) and c:IsMonster() and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 then
        local thchk=g:GetFirst():IsAbleToHand()
        local spchk=g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=Duel.SelectEffect(tp,
		{thchk,aux.Stringid(id,1)},
		{spchk,aux.Stringid(id,2)})
        if op==1 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
		    Duel.ConfirmCards(1-tp,g)
        else
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
	end
end
