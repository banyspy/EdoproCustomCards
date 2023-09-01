--Ghost Ship Cannon
--Script by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    --Total Immunity
    Boss.TotalImmunity(c)

	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and (not e:GetHandler():HasFlagEffect(id)) end)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
function s.sendfilter(c,g)
	return c:IsAbleToGrave() and g:IsContains(c)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local cg=c:GetColumnGroup()
    cg:Sub(c)
    if Duel.IsExistingMatchingCard(s.sendfilter,tp,0,LOCATION_ONFIELD,1,nil,cg) then
        e:SetCategory(CATEGORY_TOGRAVE)
        if cg:IsExists(Card.IsInExtraMZone,1,nil) then
            local em=cg:Filter(Card.IsInExtraMZone,nil)
            Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,em,#em,0,0)
        elseif cg:IsExists(Card.IsInMainMZone,1,nil) then
            local mm=cg:Filter(Card.IsInMainMZone,nil)
            Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,mm,#mm,0,0)
        elseif cg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE) then
            local st=cg:Filter(Card.IsLocation,nil,LOCATION_SZONE)
            Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,st,#st,0,0)
        end
    elseif Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_FZONE,1,nil) then
        local f=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_FZONE,nil)
        e:SetCategory(CATEGORY_TOGRAVE)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,f,#f,0,0)
    else
        e:SetCategory(CATEGORY_DAMAGE)
	    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
    end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local cg=c:GetColumnGroup()
    cg:Sub(c)
    if Duel.IsExistingMatchingCard(s.sendfilter,tp,0,LOCATION_ONFIELD,1,nil,cg) then
        if cg:IsExists(Card.IsInExtraMZone,1,nil) then
            local em=cg:Filter(Card.IsInExtraMZone,nil)
            Duel.SendtoGrave(em,REASON_EFFECT)
        elseif cg:IsExists(Card.IsInMainMZone,1,nil) then
            local mm=cg:Filter(Card.IsInMainMZone,nil)
            Duel.SendtoGrave(mm,REASON_EFFECT)
        elseif cg:IsExists(Card.IsLocation,1,nil,LOCATION_SZONE) then
            local st=cg:Filter(Card.IsLocation,nil,LOCATION_SZONE)
            Duel.SendtoGrave(st,REASON_EFFECT)
        end
    elseif Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_FZONE,1,nil) then
        local f=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_FZONE,nil)
        Duel.SendtoGrave(f,REASON_EFFECT)
    else
	    Duel.Damage(1-tp,2000,REASON_EFFECT)
    end
end