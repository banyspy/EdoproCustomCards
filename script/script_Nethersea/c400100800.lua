--The Endspeaker, Will of We Many
--Scripted by bankkyza
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	--[[local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)]]
	--special summon
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_CHAIN_END)
	e1a:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a:SetCondition(s.con)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SUMMON_SUCCESS)
	e1b:SetCondition(s.con2)
	c:RegisterEffect(e1b)
	local e1c=e1b:Clone()
	e1c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1c)
	local e1d=e1b:Clone()
	e1d:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1d)
	--[[
	local e1a2=Effect.CreateEffect(c)
	e1a2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1a2:SetCode(EVENT_CHAIN_SOLVING)
	e1a2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1a2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1a2:SetOperation(s.resetflag)
	c:RegisterEffect(e1a2)
	local e1b2=e1a2:Clone()
	e1b2:SetCode(EVENT_SUMMON)
	c:RegisterEffect(e1b2)
	local e1c2=e1a2:Clone()
	e1c2:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e1c2)
	local e1d2=e1a2:Clone()
	e1d2:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e1d2)]]
end
function s.tokentributecheck(c)
	return c:IsSetCard(0x259) and c:IsMonster() and c:IsType(TYPE_TOKEN) and c:IsReleasable()
end
function s.checkcode(c,tem)
	return c:IsOriginalCode(tem)
end
function s.summonfilter(c,tp,e)
	return c:IsOriginalCode(id)  and Duel.IsExistingMatchingCard(s.tokentributecheck,tp,LOCATION_MZONE,0,1,nil) 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,true) and not c:IsDisabled()
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp,e) and Duel.GetFlagEffect(1,id)==0
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,tp,e) and Duel.GetFlagEffect(1,id)==0
	and Duel.GetCurrentChain(true)==0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    Duel.AdjustInstantly(c)
    if(Duel.GetFlagEffect(0,id)>0) then 
		if(Duel.GetFlagEffect(0,id) ==  Duel.GetMatchingGroupCount(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) - 1)then
			Duel.ResetFlagEffect(0,id)
		else
			Duel.RegisterFlagEffect(0,id,0,0,1) 
		end
		return 
	end
	Duel.RegisterFlagEffect(0,id,0,0,1) 
	
	if(Duel.GetMatchingGroupCount(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
		Duel.ResetFlagEffect(0,id)
	end
	
	if Duel.IsExistingMatchingCard(s.tokentributecheck,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(1,id)==0 and 
	c:IsCanBeSpecialSummoned(e,0,tp,false,true) then
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1)
			local tg
			if(Duel.GetMatchingGroupCount(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
				tg = c
			else
				tg = Duel.SelectMatchingCard(tp,s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,e):GetFirst()
			end
			local g=Duel.SelectReleaseGroup(tp,s.tokentributecheck,1,6,nil)
			Duel.Release(g,REASON_RELEASE)
		    if Duel.SpecialSummon(tg,0,tp,tp,false,true,POS_FACEUP)>0 then

				local tem = 400100110
				while tem <= 400100610 do
					if g:IsExists(s.checkcode,1,nil,tem) then
						local temcard = Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_ALL,0,nil,tem-10)
						local code = temcard:GetOriginalCode()
						local e1=Effect.CreateEffect(tg)
						e1:SetDescription(aux.Stringid(id,9 + math.floor((tem - 400100010)/100)))
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
						tg:RegisterEffect(e1)
						tg:CopyEffect(code,RESET_EVENT+RESETS_STANDARD)
					end
					tem = tem + 100
				end

				if(Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1))) then
					Duel.Recover(tp,g:GetCount()*1000,0)
				end
		    	c:CompleteProcedure()
			end
        end
	end
end
function s.resetflag(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(0,id,0,0,0) 
	return
end