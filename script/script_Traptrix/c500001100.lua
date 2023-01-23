local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summoning procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FIEND|RACE_INSECT|RACE_PLANT),4,3)
    --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
    local c=e:GetHandler()
	if rp==tp and re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) 
    and rc:IsLocation(LOCATION_ONFIELD) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,true) then
        return true
    end
    return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local rc=re:GetHandler()
    Duel.AdjustInstantly(c)
    if(Duel.GetFlagEffect(0,id)==1)then return end
    Duel.RegisterFlagEffect(0,id,RESET_CHAIN,0,1)
	if rc:IsLocation(LOCATION_ONFIELD) and Duel.GetFlagEffect(1,id)==0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,true) then
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
            Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1)
            rc:CancelToGrave()
            c:SetMaterial(rc)
            Duel.Overlay(c,rc)
		    Duel.SpecialSummon(c,SUMMON_TYPE_XYZ,tp,tp,false,true,POS_FACEUP)
		    c:CompleteProcedure()
        end
	end
end