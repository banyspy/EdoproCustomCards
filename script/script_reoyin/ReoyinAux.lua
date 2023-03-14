if not aux.ReoyinProcedure then
	aux.ReoyinProcedure = {}
	Reoyin = aux.ReoyinProcedure
end

if not Zodragon then
	Reoyin = aux.ReoyinProcedure
end

--Archetype code
SET_REOYIN = 0xb04

--Specific Card
CARD_SILENCER_REOYIN = 655360061

function Reoyin.MassSummonLegalityCheck(g,tp)
    local MustLink
    if Duel.IsDuelType(DUEL_FSX_MMZONE) then --DUEL_FSX_MMZONE = Fusion/Syncheo/Xyz to Main Monster Zone Rule (MR4 Revision)
        MustLink = TYPE_PENDULUM|TYPE_LINK
    else
        MustLink = TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_PENDULUM|TYPE_LINK
    end
    local ExMustLink    =g:FilterCount(function(c)return c:IsType(MustLink) and c:IsLocation(LOCATION_EXTRA) end,nil )
    local ExNoMustLink  =g:FilterCount(function(c)return (not c:IsType(MustLink)) and c:IsLocation(LOCATION_EXTRA) end,nil)
    local NotEx         =g:FilterCount(function(c)return not c:IsLocation(LOCATION_EXTRA) end,nil)
    local MMZONE= Duel.GetMZoneCount(tp) -- Get Available Main monster zone
    local EXZONE,Masked= Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK) -- Get Available monster zone from extra for monster that require linked zone
    local EMZONE
    Masked = (ZONES_EMZ|ZONES_MMZ) & ~Masked --Need to shift first since apparently, 1 is not available zone, while 0 is opposite
    if (Masked & ZONES_EMZ)>0 then EMZONE=1 else EMZONE=0 end -- If among available monster zone from extra has extra monster zone
    --Debug.Message("ExMustLink: ".. ExMustLink)
    --Debug.Message("ExNoMustLink: ".. ExNoMustLink)
    --Debug.Message("NotEx: ".. NotEx)
    --Debug.Message("MMZONE: ".. MMZONE)
    --Debug.Message("EXZONE: ".. EXZONE)
    --Debug.Message("Masked: ".. Masked)
    --Debug.Message("EMZONE: ".. EMZONE)
    return ExMustLink+ExNoMustLink+NotEx>0 and (EXZONE >= ExMustLink) and (MMZONE+EMZONE >= ExMustLink+ExNoMustLink+NotEx)
    and (ExMustLink+ExNoMustLink+NotEx==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
end