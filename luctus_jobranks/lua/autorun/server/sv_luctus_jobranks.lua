--Luctus Jobranks
--Made by OverlordAkise

--to dynamically disable the addon
LUCTUS_JOBRANKS_IS_ACTIVE = true

hook.Add("PostGamemodeLoaded","luctus_jobranks_dbinit",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT, UNIQUE(steamid,jobcmd) )")
end)
hook.Add("postLoadCustomDarkRPItems", "luctus_jobranks_dbinit", function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT, UNIQUE(steamid,jobcmd) )")
end)

local function luctusGetPlayer(name)
    local ret = nil
    if not name or name == "" then return ret end
    for k,v in ipairs(player.GetAll()) do
        if string.find( string.lower(v:Nick()), string.lower(name) ) then
            if ret ~= nil then
                return nil
            end
            ret = v
        end
    end
    return ret
end

function luctusGetRankID(plyteam,rankShort)
    local jobname = team.GetName(plyteam)
    if not luctus_jobranks[jobname] then return nil end
    local count = 1
    for k,v in pairs(luctus_jobranks[jobname]) do
        if v[1] == rankShort then
            return k
        end
    end
    return nil
end

function luctusRankup(ply,teamcmd,executor)
    local newId = 0
    local jobname = team.GetName(ply:Team())
    local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        newId = math.min(tonumber(res[1].rankid) + 1,#luctus_jobranks[jobname])
        luctusJobranksSave(ply:SteamID(),teamcmd,newId)
        
        DarkRP.notify(ply,0,5,"Du wurdest befördert!")
        ply:PrintMessage(HUD_PRINTTALK, "Du wurdest befördert!")
        
        LuctusJobranksApply(ply,ply:Team(),newId)
        
        if ply:Alive() then
            LuctusJobranksSpawn(ply)
        end
        
        local message = executor:Nick().."("..executor:SteamID()..") just promoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[jobname][newId][2]
        print("[luctus_jobranks]",message)
        hook.Run("LuctusJobranksUprank",executor,ply,luctus_jobranks[jobname][newId][2],message) --uprankPly,targetPly,newJobName,logmessage)
    end
end

function luctusRankdown(ply,teamcmd,executor)
    local newId = 0
    local jobname = team.GetName(ply:Team())
    local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        newId = math.max(tonumber(res[1].rankid) - 1,1)
        luctusJobranksSave(ply:SteamID(),teamcmd,newId)

        DarkRP.notify(ply,0,5,"Du wurdest degradiert!")
        ply:PrintMessage(HUD_PRINTTALK, "Du wurdest degradiert!")
        
        LuctusJobranksApply(ply,ply:Team(),newId)
        
        if ply:Alive() then
            LuctusJobranksSpawn(ply)
        end
        
        local message = executor:Nick().."("..executor:SteamID()..") just demoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[jobname][newId][2]
        print("[luctus_jobranks]",message)
        hook.Run("LuctusJobranksDownrank",executor,ply,luctus_jobranks[jobname][newId][2],message) --uprankPly,targetPly,newJobName,logmessage)
    end
end

function luctusJobranksSave(steamid,jobcmd,rank)
    local res = sql.Query("REPLACE INTO luctus_jobranks(steamid,jobcmd,rankid) VALUES("..sql.SQLStr(steamid)..","..sql.SQLStr(jobcmd)..","..rank..")")
    if res == false then
        error(sql.LastError())
    end
end

function LuctusJobranksGet(steamid)
    local res = sql.Query("SELECT * FROM luctus_jobrranks WHERE steamid="..sql.SQLStr(steamid))
    if res==false then error(sql.LastError()) end
    if not res or not res[1] then return {} end
    return res
end

hook.Add("PlayerSay", "luctus_jobranks_promote", function(ply,text)
    local jobname = team.GetName(ply:Team())
    if string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKUP_CMD or
       string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKDOWN_CMD then
        local isRankup = string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKUP_CMD
        local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
        if rankID and luctus_jobranks[jobname][rankID][3] then
            local tPly = luctusGetPlayer(string.Split(text," ")[2])
            if not tPly then
                ply:PrintMessage(HUD_PRINTTALK, "ERROR: Target player not found!")
                return
            end
            if ply:Team() ~= tPly:Team() then
                ply:PrintMessage(HUD_PRINTTALK, "ERROR: Target has different job than you!")
                return
            end
            local tRankID = luctusGetRankID(tPly:Team(),tPly:GetNWString("l_nametag",""))
            if tRankID and rankID > (isRankup and tRankID+1 or tRankID) then --can max uprank to one rank below you
                if isRankup then
                    luctusRankup(tPly,RPExtraTeams[tPly:Team()].command,ply)
                else
                    luctusRankdown(tPly,RPExtraTeams[tPly:Team()].command,ply)
                end
                ply:PrintMessage(HUD_PRINTTALK, "ERROR: You can not change the rank of this player!")
            end
        else
            ply:PrintMessage(HUD_PRINTTALK, "You don't have permission to pro-/demote!")
            return ""
        end
    end
end)

hook.Add("PlayerSpawn", "luctus_nametags", function(ply)
    timer.Simple(0.1, function()
        LuctusJobranksSpawn(ply)
    end)
end)

function LuctusJobranksSpawn(ply)
    local jobname = team.GetName(ply:Team())
    if ply.lrankID and tonumber(ply.lrankID) and luctus_jobranks[jobname] and luctus_jobranks[jobname][ply.lrankID] then
        local ranktab = luctus_jobranks[jobname][ply.lrankID]
        if ranktab[4] then
            for k,v in pairs(ranktab[4]) do
                ply:Give(v)
            end
        end
        if ranktab[6] then
            ply:SetMaxHealth(ranktab[6])
            ply:SetHealth(ranktab[6])
        end
        if ranktab[7] then
            ply:SetArmor(ranktab[7])
        end
        if ranktab[8] then
            ply:SetModel(ranktab[8])
        end
    end
end

hook.Add("OnPlayerChangedTeam", "luctus_nametags", function(ply, beforeNum, afterNum)
    local beforeName = team.GetName(beforeNum)
    local afterName = team.GetName(afterNum)
    --switch from X
    if luctus_jobranks[beforeName] then
        ply:SetNWString("l_nametag","")
        ply.lrankID = nil
    end
    if not LUCTUS_JOBRANKS_IS_ACTIVE then return end
    --Jobranks
    if luctus_jobranks[afterName] then
        LuctusJobranksLoadPlayer(ply,afterNum)
    end
end)

function LuctusJobranksLoadPlayer(ply,curTeam)
    local jobname = team.GetName(curTeam)
    local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(RPExtraTeams[curTeam].command))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        local rankid = res[1].rankid
        LuctusJobranksApply(ply,curTeam,rankid)
    else
        local inres = sql.Query("INSERT INTO luctus_jobranks(steamid,jobcmd,rankid) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(RPExtraTeams[curTeam].command)..",1)")
        if inres == false then
            error(sql.LastError())
        end
        if inres == nil then
            print("[luctus_jobranks] New player successfully inserted!")
        end
        LuctusJobranksApply(ply,curTeam,1)
    end
end

function LuctusJobranksApply(ply,jobid,rankid)
    if not tonumber(rankid) then
        print("[luctus_jobranks] ERROR RANKID WAS NOT A NUMBER!")
        return
    end
    rankid = tonumber(rankid)
    local jobname = team.GetName(jobid)
    ply:SetNWString("l_nametag",luctus_jobranks[jobname][rankid][1])
    ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[jobname][rankid][2]..")")
    ply:setDarkRPVar("salary", RPExtraTeams[jobid].salary)
    if luctus_jobranks[jobname][rankid][5] then
        ply:setDarkRPVar("salary", RPExtraTeams[jobid].salary + luctus_jobranks[jobname][rankid][5])
    end
    ply.lrankID = rankid
end

hook.Add("playerGetSalary", "luctus_jobranks_salary", function(player, amount)
    --Fix salary? For whatever reason DarkRP is ignoring ply:getDarkRPVar("salary")
    return false, "Payday! You received $" .. player:getDarkRPVar("salary") .. "!", player:getDarkRPVar("salary")
end)

print("[luctus_jobranks] sv loaded")
