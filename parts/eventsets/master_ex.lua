local sectionName={"D","C","B","A","A+","S-","S","S+","S+","SS","SS","U","U","X","X+"}
local passPoint=16

return{
    dropPiece=function(P)
        if P.modeData.rankPoint<140-passPoint then--If Less then X
            local R=#P.clearedRow
            if R>0 then
                if R==4 then R=10 end--Techrash +10
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+R,140-passPoint)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
            end
        end
    end,
    task=function(P)
        P:set20G(true)
        P.lockDelay=15
        P.gameEnv.lock=15
        P.gameEnv.wait=15
        P.gameEnv.fall=6

        P.modeData.rankPoint=0
        P.modeData.rankName=sectionName[1]
        while true do
            YIELD()
            if P.stat.frame>=3600 then
                P.modeData.rankPoint=math.min(P.modeData.rankPoint+passPoint,140)
                P.modeData.rankName=sectionName[math.floor(P.modeData.rankPoint/10)+1]
                P:win('finish')
                return
            end
        end
    end,
}