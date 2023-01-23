--Contingency Contract
--Script by bankkyza

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)	
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCountLimit(1)
	e1:SetRange(0xff)
	e1:SetCondition(s.con)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

--Variable for select preset at the beginning
local op=0

--Variable for risk amount
local risk=0

--variable for level of each risk
local LP=0
local draw=0
local buff=0
local debuff=0
local trgpro=0
local batpro=0
local effpro=0
local magehand=0
local extralife=0
local zoneban=0
local forceattack=0
local startsummon=0

--Table to hold value of each risk for easier managing
--risktable is current risk that is choosing at the moment
local risktable =   {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0,[9]=0,[10]=0,[11]=0,[12]=0}
--maxtable is table that hold the option that give the highest risk level for each risk
local maxtable  =   {
    [1]     = 3,
    [2]     = 3,
    [3]     = 3,
    [4]     = 3,
    [5]     = 1,
    [6]     = 1,
    [7]     = 1,
    [8]     = 1,
    [9]     = 2,
    [10]    = 3,
    [11]    = 1,
    [12]    = 1}

--Variable to count which question is for now
local question = 1

--Utility variable for stuffs
local reach0lp=false
local dismzone,disszone
local tmp=0
local targetnegateflag=false

--variable that only become true if you manage to beat opponent (win in other word)
local win=false

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==1
end
function s.valatkop(e,c)
    return c:GetBaseAttack() * (100 + buff) /100
end
function s.valdefop(e,c)
    return c:GetBaseDefense() * (100 + buff) /100
end
function s.valatktp(e,c)
    return c:GetBaseAttack() * (100 - debuff) /100
end
function s.valdeftp(e,c)
    return c:GetBaseDefense() * (100 - debuff) /100
end
function s.checkdefensefilter(c)
    return c:IsFaceup() and c:IsDefenseAbove(0)
end
function s.startsummonfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then
		local sdg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
        Duel.DisableShuffleCheck()
		Duel.SendtoDeck(sdg,nil,-2,REASON_RULE)
	    
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Duel.ConfirmCards(1-tp,c)
		Duel.Hint(HINT_CARD,0,id)

        if c:GetPreviousLocation()==LOCATION_HAND then
		    Duel.Draw(tp,1,REASON_RULE)
	    end

        repeat
            Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
            op=Duel.SelectOption(tp,aux.Stringid(id+1,0),aux.Stringid(id+2,0),aux.Stringid(id+3,0),aux.Stringid(id+4,0))
            if(op==0) then
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+7,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+8,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+9,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+10,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+11,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+12,0))
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+13,0))
            end
        until(op~=0)
        if (op==1) then
            for key,value in ipairs(risktable) do
                risktable[key] = 0
            end
        end
        if (op==2) then
            for key,value in ipairs(risktable) do
                risktable[key] = maxtable[key]
            end
        end
        if (op==3) then
            while(question <= #risktable) do
                s.askplayer(tp,question)
            end

            risk = 0
        end
        LP,draw,buff,debuff,trgpro,batpro,effpro,magehand,extralife,zoneban,forceattack,startsummon=s.translate()

        --Iterate to count the amount of risk
        for tmp=1,#risktable do
            s.addrisk(tmp)
        end

        s.setplayerdescription(tp)

        if      LP          == 1    then LP     =   1000;   
        elseif  LP          == 2    then LP     =   2000;  
        elseif  LP          == 3    then LP     =   4000;   end
        if      buff        == 1    then buff   =   20;     
        elseif  buff        == 2    then buff   =   30;     
        elseif  buff        == 3    then buff   =   50;     end
        if      debuff      == 1    then debuff =   20;     
        elseif  debuff      == 2    then debuff =   30;     
        elseif  debuff      == 3    then debuff =   50;     end

        local g1=Effect.GlobalEffect()
        --if(LP == 1) then g1:SetDescription(aux.Stringid(10,id+1)) end
        g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        g1:SetCode(EVENT_TURN_END)
        g1:SetCountLimit(1)
        g1:SetOperation(
            function() 
                --Debug.Message(reach0lp)
                if((LP == 0) and (Duel.GetLP(1-tp) == 0) and (reach0lp == true)) then
                    Duel.SetLP(1-tp,1,REASON_RULE)
                else
                    Duel.SetLP(1-tp,Duel.GetLP(1-tp) + LP,REASON_RULE)
                end
                reach0lp = false
                targetnegateflag = false
            end
            )
        Duel.RegisterEffect(g1,tp)

        local e2=Effect.GlobalEffect()
	    e2:SetType(EFFECT_TYPE_FIELD)
	    e2:SetCode(EFFECT_DRAW_COUNT)
	    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	    e2:SetTargetRange(0,1)
	    e2:SetValue(draw+1)
	    Duel.RegisterEffect(e2,tp)

        local e3=Effect.GlobalEffect()
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetCode(EFFECT_SET_BASE_ATTACK)
        e3:SetTargetRange(0,LOCATION_MZONE)
        e3:SetValue(s.valatkop)
        Duel.RegisterEffect(e3,tp)
        local e4=e3:Clone()
        e4:SetCode(EFFECT_SET_BASE_DEFENSE)
        e4:SetValue(s.valdefop)
        Duel.RegisterEffect(e4,tp)

        local e5=Effect.GlobalEffect()
        e5:SetType(EFFECT_TYPE_FIELD)
        e5:SetCode(EFFECT_SET_BASE_ATTACK)
        e5:SetTargetRange(LOCATION_MZONE,0)
        e5:SetValue(s.valatktp)
        Duel.RegisterEffect(e5,tp)
        local e6=e5:Clone()
        e6:SetCode(EFFECT_SET_BASE_DEFENSE)
        e6:SetValue(s.valdeftp)
        Duel.RegisterEffect(e6,tp)

        --Opponent cannot target
        local e7=Effect.GlobalEffect()
	    e7:SetCategory(CATEGORY_DISABLE)
	    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    e7:SetCode(EVENT_CHAIN_SOLVING)
        e7:SetCountLimit(1)
	    e7:SetCondition(s.negtargetcon)
	    e7:SetOperation(s.negtargetop)
	    Duel.RegisterEffect(e7,tp)

        --Battle protection
	    local e8=Effect.GlobalEffect()
	    e8:SetType(EFFECT_TYPE_FIELD)
        e8:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	    e8:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	    e8:SetTargetRange(0,LOCATION_MZONE)
        e8:SetCondition(function() return (batpro==1) end)
	    e8:SetTarget(aux.TRUE)
	    e8:SetValue(function(_,_,r) return (r&REASON_BATTLE==REASON_BATTLE) and 1 or 0 end)
	    Duel.RegisterEffect(e8,tp)

        --destruction protection
	    local e9=Effect.GlobalEffect()
	    e9:SetType(EFFECT_TYPE_FIELD)
        e9:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	    e9:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	    e9:SetTargetRange(0,LOCATION_MZONE)
        e9:SetCondition(function() return (effpro==1) end)
        e9:SetTarget(aux.TRUE)
	    --e9:SetTarget(function(_,c) return c:IsFacedown() and c:GetSequence()<5 end)
	    e9:SetValue(function(_,_,r) return (r&REASON_EFFECT==REASON_EFFECT) and 1 or 0 end)
	    Duel.RegisterEffect(e9,tp)

        --negate first effect
	    local e10=Effect.GlobalEffect()
	    e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	    e10:SetCode(EVENT_CHAIN_SOLVING)
	    e10:SetCountLimit(1)
	    e10:SetCondition(s.negcon)
	    e10:SetOperation(s.negop)
	    Duel.RegisterEffect(e10,tp)

        if zoneban == 1 or zoneban == 3 then
            dismzone = Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
            local e11=Effect.GlobalEffect()
	        e11:SetType(EFFECT_TYPE_FIELD)
	        e11:SetCode(EFFECT_DISABLE_FIELD)
	        e11:SetLabel(dismzone)
            e11:SetOperation(function() return dismzone end)
	        Duel.RegisterEffect(e11,tp)
        end

        if zoneban == 2 or zoneban == 3 then
            disszone = Duel.SelectDisableField(tp,1,LOCATION_SZONE,0,0)
            local e12=Effect.GlobalEffect()
	        e12:SetType(EFFECT_TYPE_FIELD)
	        e12:SetCode(EFFECT_DISABLE_FIELD)
	        e12:SetLabel(disszone)
            e12:SetOperation(function() return disszone end)
	        Duel.RegisterEffect(e12,tp)
        end

        --Force attack
	    local e13=Effect.GlobalEffect()
	    e13:SetType(EFFECT_TYPE_FIELD)
	    e13:SetCode(EFFECT_MUST_ATTACK)
	    e13:SetTargetRange(LOCATION_MZONE,0)
	    e13:SetCondition(function() return (forceattack==1) end)
	    Duel.RegisterEffect(e13,tp)

        --[[Natural selection
        if forceattack == 1 then
            local e13=Effect.GlobalEffect()
            e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
            e13:SetCode(EVENT_TURN_END)
            e13:SetCountLimit(1)
            e13:SetCondition(function(_,tp)return Duel.GetTurnPlayer()==tp end)
            e13:SetOperation(
            function() 
                local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
                Debug.Message(#g)
                if #g>0 then
                    local g1=g:GetMinGroup(Card.GetAttack)
                    Debug.Message(#g1)
                    g = Duel.GetMatchingGroup(s.checkdefensefilter,tp,LOCATION_MZONE,0,nil)
                    local g2=g:GetMinGroup(Card.GetDefense)
                    Debug.Message(#g2)
                    g1:Merge(g2)
                    if #g1>1 then
                        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			            local sg=g1:Select(tp,1,1,nil)
			            Duel.HintSelection(sg)
			            Duel.SendtoGrave(sg,REASON_RULE)
                    else 
                        Duel.HintSelection(g1) 
                        Duel.SendtoGrave(g1,REASON_RULE)
                    end
                end
            end
            )
            Duel.RegisterEffect(e13,tp)
        end]]

        --Opponent free summon
        if startsummon == 1 then
            Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		    local g=Duel.SelectMatchingCard(1-tp,s.startsummonfilter,1-tp,LOCATION_EXTRA,0,1,1,nil,e,1-tp)
		    local tc=g:GetFirst()
		    if tc then
		    	Duel.SpecialSummon(tc,0,1-tp,1-tp,true,false,POS_FACEUP)
            else
                g=Duel.SelectMatchingCard(1-tp,s.startsummonfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
                tc=g:GetFirst()
		        if tc then
		    	    Duel.SpecialSummon(tc,0,1-tp,1-tp,true,false,POS_FACEUP)
                end
		    end
        end

        local r1=Effect.GlobalEffect()
        r1:SetType(EFFECT_TYPE_FIELD)
        r1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_PLAYER_TARGET)
        r1:SetCode(EFFECT_CANNOT_LOSE_DECK)
        r1:SetTargetRange(0,1)
        r1:SetValue(1)
        Duel.RegisterEffect(r1,tp)
        local r2=r1:Clone()
        r2:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
        Duel.RegisterEffect(r2,tp)
        local r3=r1:Clone()
        r3:SetCode(EFFECT_CANNOT_LOSE_LP)
        r3:SetCondition(function() return win==false end)
        Duel.RegisterEffect(r3,tp)

        --No hand limit
	    local r4=Effect.GlobalEffect()
	    r4:SetType(EFFECT_TYPE_FIELD)
	    r4:SetCode(EFFECT_HAND_LIMIT)
	    r4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	    r4:SetTargetRange(0,1)
	    r4:SetValue(99)
	    Duel.RegisterEffect(r4,tp)

        local r5=Effect.GlobalEffect()
        r5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        r5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_PLAYER_TARGET)
        r5:SetCode(EVENT_ADJUST)
        r5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (Duel.GetLP(1-tp) == 0) and (reach0lp == false) end)
        r5:SetOperation(function() 
            if (extralife > 0) then
                reach0lp = true
                extralife = extralife - 1
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+23-extralife,0))
            elseif (extralife == 0) then
                reach0lp = true
                Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+24,0))
                win = true
            else
                Debug.Message(string.format("Something is wrong, I can feel it"))
            end
        end)
        Duel.RegisterEffect(r5,tp)

        --Show Total Amount of Risk at the end
        Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+risk,8))
    end
end
function s.negtargetfilter(c,tp)
    return c:IsMonster() and c:IsControler(1-tp) and c:IsLocation(LOCATION_ONFIELD)
end
function s.negtargetcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    Debug.Message("check1")
	return e:GetHandlerPlayer()==rp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (trgpro==1)
    and g and g:IsExists(s.negtargetfilter,1,e:GetHandler(),tp) and Duel.IsChainDisablable(ev)
end
function s.negtargetop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
    targetnegateflag = true
end
function s.askplayer(tp,current)
    
    local RiskChoiceCount = s.getriskchoicecount(current)

    repeat
    --This is for risk that has 4 choice total(include no risk choice)
    if(RiskChoiceCount == 4) then
        
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id+current,1))
        if(current == 1) then
            risktable[current]=Duel.SelectOption(tp,aux.Stringid(id+15,0),aux.Stringid(id+current,2),aux.Stringid(id+current,3),aux.Stringid(id+current,4),
            aux.Stringid(id+16,0),aux.Stringid(id+17,0),aux.Stringid(id+18,0),aux.Stringid(id+19,0))
        else
            risktable[current]=Duel.SelectOption(tp,aux.Stringid(id+15,0),aux.Stringid(id+current,2),aux.Stringid(id+current,3),aux.Stringid(id+current,4),
            aux.Stringid(id+16,0),aux.Stringid(id+17,0),aux.Stringid(id+18,0),aux.Stringid(id+19,0),aux.Stringid(id+20,0))
        end
    --This is for risk that has 2 choice total(include no risk choice)
    elseif (RiskChoiceCount == 2) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id+current,1))
        risktable[current]=Duel.SelectOption(tp,aux.Stringid(id+15,0),aux.Stringid(id+current,2),
        aux.Stringid(id+16,0),aux.Stringid(id+17,0),aux.Stringid(id+18,0),aux.Stringid(id+19,0),aux.Stringid(id+20,0))

    --This is for risk that has 3 choice total(include no risk choice)
    elseif (RiskChoiceCount == 3) then
        Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id+current,1))
        risktable[current]=Duel.SelectOption(tp,aux.Stringid(id+15,0),aux.Stringid(id+current,2),aux.Stringid(id+current,3),
        aux.Stringid(id+16,0),aux.Stringid(id+17,0),aux.Stringid(id+18,0),aux.Stringid(id+19,0),aux.Stringid(id+20,0))
    end

    if(risktable[current] == RiskChoiceCount) then
        Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+current,7))
    elseif(risktable[current] == (RiskChoiceCount+1)) then
        Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(id+risk,8))
        --Debug.Message(risk)
    elseif(risktable[current] == (RiskChoiceCount+2)) then
        s.skipnorisk(current)
        question = #risktable + 1
        return
    elseif(risktable[current] == (RiskChoiceCount+3)) then
        s.skipmaxrisk(current)
        question = #risktable + 1
        return
    elseif(risktable[current] == (RiskChoiceCount+4)) then
        risk = risk - risktable[current-1]
        question = question - 1
        return
    end

    until((risktable[current] >= 0) and (risktable[current] < RiskChoiceCount))

    s.addrisk(current)

    question = question + 1
end

function s.addrisk(current)
    if current == 1 then

        risk = risk + risktable[current]

    elseif current == 2 then

        risk = risk + risktable[current]

    elseif current == 3 then

        risk = risk + risktable[current]

    elseif current == 4 then

        risk = risk + risktable[current]

    elseif current == 5 then

        risk = risk + (risktable[current] * 2)

    elseif current == 6 then

        risk = risk + (risktable[current] * 2)

    elseif current == 7 then

        risk = risk + (risktable[current] * 2)

    elseif current == 8 then

        risk = risk + (risktable[current] * 3)

    elseif current == 9 then

        if(risktable[current]>0) then risk = risk + risktable[current] + 1 end

    elseif current == 10 then

        if(risktable[current]>=2) then risk = risk + risktable[current] - 1 else risk = risk + risktable[current] end

    elseif current == 11 then

        risk = risk + risktable[current]

    elseif current == 12 then

        risk = risk + (risktable[current] * 3)
    end
end

function s.getriskchoicecount(current)
    if(current == 1 or current == 2 or current == 3 or current == 4 or current == 10) then                          return 4
    elseif (current == 5 or current == 6 or current == 7 or current == 8 or current == 11 or current == 12) then    return 2
    elseif (current == 9) then                                                                                      return 3 end
end

function s.translate()
    return risktable[1],risktable[2],risktable[3],risktable[4],risktable[5],
        risktable[6],risktable[7],risktable[8],risktable[9],risktable[10],risktable[11],risktable[12]
end

function s.setplayerdescription(tp)
    for tmp = 1,#risktable do
        if risktable[tmp] > 0 then
            local r1=Effect.GlobalEffect()
            r1:SetDescription(aux.Stringid(id+tmp,9 + risktable[tmp]))
            r1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            if (tmp==4 or tmp==8 or tmp==10 or tmp==11) then
                r1:SetTargetRange(1,0)
            else
                r1:SetTargetRange(0,1)
            end
            Duel.RegisterEffect(r1,tp)
        end
    end
end

function s.skipnorisk(temp)
    local i
    for i=temp,#risktable do
        risktable[i] = 0
    end
end
function s.skipmaxrisk(temp)
    local i
    for i=temp,#risktable do
        risktable[i] = maxtable[i]
    end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    Debug.Message("check2")
	return rp==tp and Duel.IsChainDisablable(ev) and (magehand == 1) 
    and not (e:GetHandlerPlayer()==rp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (trgpro==1)
    and g and g:IsExists(s.negtargetfilter,1,e:GetHandler(),tp) and Duel.IsChainDisablable(ev) and (targetnegateflag == false))
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end