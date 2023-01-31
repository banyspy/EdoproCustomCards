--The Endspeaker, Will of We Many
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript('NetherseaAux.lua')
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(0)
	c:RegisterEffect(e0)
	--special summon (ignoring condition and revivelimit, essentially make above condition become "cannot be special summon by other way")
	local e1a=Effect.CreateEffect(c)
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
	--summon cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
end
function s.tokentributecheck(c)
	return c:IsSetCard(SET_NETHERSEA) and c:IsMonster() and c:IsType(TYPE_TOKEN) and c:IsReleasable()
end
function s.checkcode(c,tem)
	return c:IsOriginalCode(tem)
end
function s.summonfilter(c,tp,e)
	return c:IsOriginalCode(id)  and Duel.IsExistingMatchingCard(s.tokentributecheck,tp,LOCATION_MZONE,0,1,nil) 
	and c:IsCanBeSpecialSummoned(e,0,tp,true,true) and not c:IsDisabled()
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
    
	if not Nethersea.WeManyDontAskMoreThanOnce(tp,e,s.summonfilter) then return end
	
	if Duel.IsExistingMatchingCard(s.tokentributecheck,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFlagEffect(1,id)==0 and 
	c:IsCanBeSpecialSummoned(e,0,tp,true,true) then
		if Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,0)) then
			Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1)
			Nethersea.ResetWeManyFlag()
			local tg
			if(Duel.GetMatchingGroupCount(s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,tp,e) == 1) then
				tg = c
			else
				tg = Duel.SelectMatchingCard(tp,s.summonfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,tp,e):GetFirst()
			end
			local g=Duel.SelectReleaseGroup(tp,s.tokentributecheck,1,6,nil)
			Duel.Release(g,REASON_RELEASE)
		    if Duel.SpecialSummon(tg,0,tp,tp,true,true,POS_FACEUP)>0 then

				local tem = 400100110
				while tem <= 400100610 do
					if g:IsExists(s.checkcode,1,nil,tem) then
						local temcard = Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_ALL,0,nil,tem-10)
						local code = temcard:GetOriginalCode()
						local e1=Effect.CreateEffect(tg)
						e1:SetDescription(aux.Stringid(id,9 + math.floor((tem - 400100010)/100)))
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
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