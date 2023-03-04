if not aux.MagikularProcedure then
	aux.MagikularProcedure = {}
	Magikular = aux.MagikularProcedure
end

if not Magikular then
	Magikular = aux.MagikularProcedure
end

--Archetype code
SET_MAGIKULAR = 0x1f4

function Magikular.SummonSpellTrap(tc,attr)
                        tc:AddMonsterAttribute(TYPE_NORMAL)
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(4)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(attr)
			tc:RegisterEffect(e2,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_RACE)
			e3:SetValue(RACE_SPELLCASTER)
			tc:RegisterEffect(e3,true)
			local e4=e1:Clone()
			e4:SetCode(EFFECT_SET_BASE_ATTACK)
			e4:SetValue(1500)
			tc:RegisterEffect(e4,true)
			local e5=e4:Clone()
			e5:SetCode(EFFECT_SET_BASE_DEFENSE)
			tc:RegisterEffect(e5,true)
			local e6=e1:Clone()
			e6:SetCode(EFFECT_ADD_SETCODE)
			e6:SetValue(SET_MAGIKULAR)
			tc:RegisterEffect(e6,true)
			tc:AddMonsterAttributeComplete()
end
