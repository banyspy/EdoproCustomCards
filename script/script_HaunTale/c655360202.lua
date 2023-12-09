--HaunTale Mourning Spirit
--Scripted by bankkyza
local s,id=GetID()
Duel.LoadScript("BanyspyAux.lua")
function s.initial_effect(c)
    HaunTale.ShuffleFromExtraToReviveSelf(c,id)
	--remove
	local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsSummonLocation(LOCATION_GRAVE) end)
	e2:SetTarget(s.pstg)
	e2:SetOperation(s.psop)
	c:RegisterEffect(e2)
end
--s.listed_names={id}
s.listed_series={SET_HAUNTALE}
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.zfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function s.pstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
    local zgroup=Duel.GetMatchingGroup(s.zfilter,tp,LOCATION_MZONE,0,nil)
    local opgroup=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,opgroup,math.max(#zgroup,#opgroup),0,0)
end
function s.psop(e,tp,eg,ep,ev,re,r,rp)
    local zcount=Duel.GetMatchingGroupCount(s.zfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,zcount,nil)
	if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end