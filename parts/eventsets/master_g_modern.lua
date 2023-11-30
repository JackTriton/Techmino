-- local regretDelay=-1
-- local int_grade=0
-- local grade_points=0
local _igb={0,1,2,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,11,11,12,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26}
local function getInternalGradeBoosts(internal_grade)
    return _igb[MATH.clamp(internal_grade+1,1,#_igb)]
end
-- local spd_lvl=0
-- local cools=0
-- local regrets=0
-- local prevSectTime=0
-- local isInRoll=false
-- local rollGrades=0
local awesome_time=    {2700,2700,2520,2280,2280,1980,1980,1620,1620,0}
local cool_time=   {3120,3120,2940,2700,2700,2520,2520,2280,2280,0}
local regret_time= {5400,4500,4500,4080,3600,3600,3000,3000,3000,3000}
local fault_time=    {7200,5400,5400,4500,4080,4080,3600,3600,3600,3600}
local function getGrav(l)
    return
        l<30  and 64   or
        l<40  and 43   or
        l<50  and 32   or
        l<60  and 26   or
        l<70  and 21   or
        l<80  and 16   or
        l<90  and 8    or
        l<120 and 6    or
        l<160 and 4    or
        l<200 and 3    or
        l<240 and 2    or
        l<260 and 64   or
        l<268 and 32   or
        l<275 and 16   or
        l<280 and 8    or
        l<290 and 4    or
        l<320 and 3    or
        l<370 and 2    or
        l<430 and 1    or
        l<470 and 0.75 or
        l<510 and 0.5  or
        l<600 and 0.25 or
        l<700 and 0.1  or
        0
end
local function getLock(l)
    return
        l<900  and 30 or
        l<1100 and 17 or
        l<1400 and 15 or
        12
end
local function getCurrentGrade(D)
    if not D.int_grade then D.int_grade=0 end
    if not D.roll_grades then D.roll_grades=0 end
    return math.floor(math.max(1,getInternalGradeBoosts(D.internal_grade)+D.rollGrades+D.cools+1-D.regrets))
end
local function addGrade(D,row,cmb,chk,lvl) -- IGS = internal grade system
    if row<1 then return end
    local pts=0
    local cmb_mult=1.0
    local lvl_mult=math.floor(lvl/250)+1
    local spn_mult=1.0
    if chk.spin then spn_mult=spn_mult*1.5
    elseif chk.mini then spn_mult=spn_mult*1.2
    end
    if chk.pc then spn_mult=spn_mult*2.0
    elseif chk.hpc then spn_mult=spn_mult*1.2
    end
    if row==1 then
        pts=D.internal_grade<5 and 10 or D.internal_grade<10 and 5 or 2
        cmb_mult=1.0
    elseif row==2 then
        pts=D.internal_grade<3 and 20 or D.internal_grade<6 and 15 or D.internal_grade<10 and 10 or 12
        cmb_mult=cmb==1 and 1 or cmb<4 and 1.2 or cmb<8 and 1.4 or cmb<10 and 1.5 or 2.0
    elseif row==3 then
        pts=D.internal_grade==0 and 40 or D.internal_grade<4 and 30 or D.internal_grade<7 and 20 or D.internal_grade<10 and 15 or 13
        cmb_mult=cmb==1 and 1 or cmb<10 and 1+(cmb+2)*0.1 or 2
    else
        pts=D.internal_grade==0 and 50 or D.internal_grade<5 and 40 or 30
        cmb_mult=cmb==1 and 1 or cmb==2 and 1.5 or cmb<6 and (0.2*cmb)+1.2 or cmb<10 and (0.1*cmb)+1.7 or 3
    end
    D.grade_points=D.grade_points+(pts*cmb_mult*lvl_mult*spn_mult)
    if D.grade_points>=100 then
        D.grade_points=0
        D.internal_grade=D.internal_grade+1
    end
end
local function getRollGoal(D,isGreenLine)
    local invis=D.cools>11
    local superinvis=D.cools>16
    -- get amount of grades needed for TGM+
    local rem=46-getCurrentGrade(D)-(
        -- adjust for clear bonus
        isGreenLine and 0 or
        superinvis and 1.6 or invis and not superinvis and .8 or .5
    )
    if rem<=0 then return 0 end
    local goal=0
    if superinvis then
        goal=math.floor(rem)*4
        rem=rem%1
        return goal+(rem>0.3 and 4 or rem*10)
    elseif invis then
        goal=math.floor(rem/.53)*4
        rem=rem%.53
        return goal+(rem>0.21 and 4 or rem*16)
    else
        goal=math.floor(rem/.26)*4
        rem=rem%.26
        return goal+(rem>0.12 and 4 or rem*25)
    end
end
local function getCurSection(D)
    return math.ceil((D.pt+1)/100)
end
local function getSectionState(P,section)
    local D=P.modeData
    local awesome,cool,miss,regret,fault=false,false,false,false,false
    if D.awesomeList[section] then awesome=true 
    elseif D.coolList[section] then cool=true end
    if D.regretList[section] then regret=true 
    elseif D.faultList[section] then fault=true end

    if section==getCurSection(D) and P.stat.frame-D.prevSectTime>cool_time[section] then
        miss=true
    end
    return awesome,cool,miss,regret,fault
end
local function setSectionColor(awesome,cool,regret,fault,isCurSection)
    if not (awesome or cool or regret or fault) then
        GC.setColor(0.6,0.6,0.6,isCurSection and 0.25 or 0.6)
    else
        GC.setColor(fault and 0.5 or regret and 1 or 0, awesome and 1 or cool and 1 or 0, awesome and 1 or 0, 1)
    end
end
local function setCurSectionColor(awesome, cool, miss, regret, fault)
    if awesome and fault then
        GC.setColor(COLOR.P)
    elseif awesome and regret then
        GC.setColor(COLOR.lB)
    elseif cool and fault then
        GC.setColor(COLOR.O)
    elseif cool and regret then
        GC.setColor(COLOR.Y)
    elseif awesome then
        GC.setColor(COLOR.C)
    elseif cool then
        GC.setColor(COLOR.G)
    elseif regret then
        GC.setColor(COLOR.R)
    elseif fault then
        GC.setColor(COLOR.dR)
    elseif miss then
        GC.setColor(COLOR.lX)
    end
end

return {
    drop=64,
    lock=30,
    keyCancel={10,11,12,14,15,16,17,18,19,20},
    arr=1,
    minsdarr=1,
    ihs=true,irs=true,ims=false,
    mesDisp=function(P)
        local D=P.modeData
        GC.setColor(1,1,1,1)
        setFont(45)
        mText(TEXTOBJ.grade,63,180)
        setFont(60)
        GC.mStr(getMasterGradeModern(getCurrentGrade(D)),63,110)  -- draw grade
        for i=1,10 do -- draw cool/regret history
            setSectionColor(D.awesomeList[i],D.coolList[i],D.regretList[i],D.faultList[i],i==getCurSection(D))
            GC.circle('fill',-10,150+i*25,10)
            GC.setColor(1,1,1,1)
        end
        if D.isInRoll then
            setFont(20)
            GC.mStr(("%.1f"):format(D.rollGrades),63,208) -- draw roll grades
            GC.setLineWidth(2)
            GC.setColor(.98,.98,.98,.8)
            GC.rectangle('line',0,240,126,80,4)
            GC.setColor(.98,.98,.98,.4)
            GC.rectangle('fill',0+2,240+2,126-4,80-4,2) -- draw time box
            
            setFont(45) -- Draw time text
            local t=(P.stat.frame-D.prevSectTime)/60
            local T=("%.1f"):format(60-t)
            GC.setColor(COLOR.dH)
            GC.mStr(T,65,250)
            t=t/60
            GC.setColor(1.7*t,2.3-2*t,.3)
            GC.mStr(T,63,248)

            GC.setColor(COLOR.O)
            PLY.draw.drawTargetLine(P,getRollGoal(D),true)

            GC.setColor(COLOR.G)
            PLY.draw.drawTargetLine(P,getRollGoal(D,true),true)
        else
            -- Not in roll
            setFont(20)
            GC.mStr(D.grade_points,63,208)
            setFont(45)

            setCurSectionColor(getSectionState(P,getCurSection(D)))
            PLY.draw.drawProgress(P.modeData.pt,P.modeData.target)
        end
    end,
    hook_drop=function(P)
        local D=P.modeData

        local c=#P.clearedRow
        if D.cools>16 and D.isInRoll then -- super invis roll grades
            D.rollGrades=D.rollGrades+(c==4 and 1 or 0.1*c)
            return

        elseif D.cools>11 and D.isInRoll then -- invis roll grades
            D.rollGrades=D.rollGrades+(c==4 and 0.52 or 0.06*c)
            return

        elseif D.isInRoll then -- fading roll grades
            D.rollGrades=D.rollGrades+(c==4 and 0.26 or 0.04*c)
            return
        end

        if c==0 and D.pt+1>=D.target then return end
        local s=c<3 and c+1 or c==3 and 5 or 7
        local LP=P.lastPiece
        local B2B=P.b2b
        if c==4 then
            if B2B>800 then s=s+2
            elseif B2B>=50 then s=s+1
            end
        end
        if LP.spin and c==0 then s=s+1
        elseif LP.spin and c>0 then
            if B2B>=50 then s=s+2
            else s=s+1
            end
        end
        if LP.mini and c>0 and B2B>=50 then s=s+1 end
        if LP.pc then s=s+4 end
        if LP.hpc then s=s+1 end
        if P.combo>7 then s=s+2
        elseif P.combo>3 then s=s+1 end

        if not D.isInRoll then
            addGrade(D,c,P.combo,LP,D.pt)
            D.pt=D.pt+s
            D.speed_level=D.speed_level+s
        end

        if D.pt%100>70 and not D.prevDrop70 then
            if P.stat.frame-D.prevSectTime<awesome_time[math.ceil(D.pt/100)] then
                D.cools=D.cools+2
                D.awesomeList[getCurSection(D)]=true
                D.coolList[getCurSection(D)]=true
                P:_showText("AWESOME!!",0,-120,80,'fly',.8)
                D.nextSpeedUpper=true
            elseif P.stat.frame-D.prevSectTime<cool_time[math.ceil(D.pt/100)] then
                D.cools=D.cools+1
                D.coolList[getCurSection(D)]=true
                P:_showText("COOL!",0,-120,80,'fly',.8)
                D.nextSpeedUp=true
            end
            D.prevDrop70=true
        end

        if D.pt+1==D.target then
            SFX.play('warn_1')
        elseif D.pt>=D.target then-- Level up!
            D.speed_level=D.nextSpeedUpper and D.speed_level+150 or D.nextSpeedUp and D.speed_level+100 or D.speed_level
            D.nextSpeedUp=false
            D.nextSpeedUpper=false
            D.prevDrop70=false
            s=D.target/100
            local E=P.gameEnv
            E.drop=getGrav(D.speed_level)
            E.lock=getLock(D.speed_level)
            if (E.drop==0) then P:set20G(true) end

            if P.stat.frame-D.prevSectTime > fault_time[math.ceil(s)] then
                D.regrets=D.regrets+2
                D.regretDelay=60
            elseif P.stat.frame-D.prevSectTime > regret_time[math.ceil(s)] then
                D.regrets=D.regrets+1
                D.regretDelay=60
            end
            D.prevSectTime=P.stat.frame
            if s==2 then
                BG.set('rainbow')
            elseif s==4 then
                BG.set('rainbow2')
            elseif s==5 then
                if P.stat.frame>420*60 then
                    D.pt=500
                    P:win('finish')
                    return
                else
                    BG.set('glow')
                    BGM.play('secret7th remix')
                end
            elseif s==6 then
                BG.set('lightning')
            elseif s>9 then
                if D.cools>16 then
                    if E.lockFX and 3>E.lockFX then E.lockFX=3 end
                    P:setInvisible(5)
                    E.block=false
                elseif D.cools>11 then
                    if E.lockFX and E.lockFX>1 then E.lockFX=1 end
                    P:setInvisible(5)
                else
                    P:setInvisible(300)
                    if E.lockFX and not E.lockFX==2 then E.lockFX=2 end
                    if E.block==false then E.block=true end
                end
                D.pt=999
                P.waiting=240
                BGM.stop()
                D.isInRollTrans=true
                return
            end
            D.target=D.target<900 and D.target+100 or 999
            P:stageComplete(s)
            SFX.play('reach')
        end
    end,
    task=function(P)
        local D=P.modeData
        D.regretDelay=-1
        D.pt=0
        D.target=100
        D.int_grade=0
        D.grade_points=0
        D.rollGrades=0
        D.spd_lvl=0
        D.cools=0
        D.regrets=0
        D.prevSectTime=0
        D.isInRoll=false
        D.isInRollTrans=false
        D.isFault=false
        D.prevDrop70=false
        D.nextSpeedUp=false
        D.nextSpeedUpper=false
        D.awesomeList,D.coolList,D.regretList,D.faultList=TABLE.new(false,9),TABLE.new(false,9),TABLE.new(false,10),TABLE.new(false,10)
        local decayRate={125,80,80,50,50,50,45,45,45,45,40,40,40,40,40,30,30,30,30,30,20,20,20,20,20,15,15,15,15,15,15,15,15,15,15,10,10,10,10,9,9,9,8,8,8,7,7,7,6}
        local decayTimer=0

        while true do
            coroutine.yield()
            D.gradePts=getCurrentGrade(D)
            if P.stat.frame-D.prevSectTime > fault_time[getCurSection(D)] and not (D.isInRoll or D.isInRollTrans) then
                D.faultList[math.ceil(D.pt/100)]=true
                D.regretList[math.ceil(D.pt/100)]=true
                D.isFault=true
            elseif P.stat.frame-D.prevSectTime > regret_time[getCurSection(D)] and not (D.isInRoll or D.isInRollTrans) then
                D.regretList[math.ceil(D.pt/100)]=true
            end
            if D.regretDelay>-1 then
                D.regretDelay=D.regretDelay-1
                if D.regretDelay==-1 and D.isFault then 
                    P:_showText("FAULT!!!",0,-120,80,'beat',.8) 
                    D.isFault=false
                elseif D.regretDelay==-1 then P:_showText("REGRET!!",0,-120,80,'beat',.8) end
            end
            if D.isInRollTrans then
                if P.waiting>=220 then
                    -- Make field invisible
                    for y=1,#P.field do for x=1,10 do
                        P.visTime[y][x]=P.waiting-220
                    end end
                elseif P.waiting==190 then
                    TABLE.cut(P.field)
                    TABLE.cut(P.visTime)
                elseif P.waiting==180 then
                    playReadySFX(3,3)
                    P:_showText("3",0,-120,120,'fly',1)
                elseif P.waiting==120 then
                    playReadySFX(2,1)
                    P:_showText("2",0,-120,120,'fly',1)
                elseif P.waiting==60 then
                    playReadySFX(1,1)
                    P:_showText("1",0,-120,120,'fly',1)
                elseif P.waiting==1 then
                    playReadySFX(0,1)
                    D.isInRollTrans=false
                    D.isInRoll=true
                    BGM.play('hope')
                    BG.set('blockspace')
                    D.prevSectTime=P.stat.frame
                end
            end
            if P.waiting<=0 and D.grade_points>0 and not D.isInRoll then
                decayTimer=decayTimer+1
                if decayTimer>=decayRate[math.min(D.internal_grade+1,#decayRate)] then
                    decayTimer=0
                    D.grade_points=D.grade_points-1
                end
            elseif D.isInRoll and P.stat.frame>=D.prevSectTime+3599 then
                D.rollGrades=D.rollGrades+(D.cools>16 and 1.6 or D.cools>11 and 0.8 or 0.5)
                D.gradePts=getCurrentGrade(D)
                P:win('finish')
            end
        end
    end,
}