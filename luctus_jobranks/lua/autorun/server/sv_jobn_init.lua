--Luctus Jobranks
--Made by OverlordAkise

LuctusLog = LuctusLog or function()end

hook.Add("PostGamemodeLoaded","luctus_jobranks_dbinit",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT )")
end)
hook.Add("postLoadCustomDarkRPItems", "luctus_jobranks_dbinit", function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT )")
end)

local function luctusGetPlayer(name)
    local ret = nil
    for k,v in pairs(player.GetAll()) do
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
        local ires = sql.Query("UPDATE luctus_jobranks SET rankid = "..(newId).." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
        if ires == false then
            error(sql.LastError())
        end
        DarkRP.notify(ply,0,5,"Du wurdest befördert!")
        ply:PrintMessage(HUD_PRINTTALK, "Du wurdest befördert!")
        ply:SetNWString("l_nametag", luctus_jobranks[jobname][newId][1])
        ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[jobname][newId][2]..")")
        ply:setDarkRPVar("salary", ply:getJobTable().salary)
        if luctus_jobranks[jobname][newId][5] then
            ply:setDarkRPVar("salary", ply:getJobTable().salary + luctus_jobranks[jobname][newId][5])
        end
        ply.lrankID = newId
        LuctusLog("Jobranks",executor:Nick().."("..executor:SteamID()..") just promoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[jobname][newId][2])
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
        local ires = sql.Query("UPDATE luctus_jobranks SET rankid = "..(newId).." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
        if ires == false then
          error(sql.LastError())
        end
        DarkRP.notify(ply,0,5,"Du wurdest degradiert!")
        ply:PrintMessage(HUD_PRINTTALK, "Du wurdest degradiert!")
        ply:SetNWString("l_nametag", luctus_jobranks[jobname][newId][1])
        ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[jobname][newId][2]..")")
        ply:setDarkRPVar("salary", ply:getJobTable().salary)
        if luctus_jobranks[jobname][newId][5] then
            ply:setDarkRPVar("salary", ply:getJobTable().salary + luctus_jobranks[jobname][newId][5])
        end
        ply.lrankID = newId
        LuctusLog("Jobranks",executor:Nick().."("..executor:SteamID()..") just demoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[jobname][newId][2])
    end
end

hook.Add("PlayerSay", "luctus_jobranks_promote", function(ply,text)
    local jobname = team.GetName(ply:Team())
    if string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKUP_CMD then
        local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
        if rankID and luctus_jobranks[jobname][rankID][3] then
            local tPly = luctusGetPlayer(string.Split(text," ")[2])
            if not tPly then
                ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
                return
            end
            if ply:Team() ~= tPly:Team() then
                ply:PrintMessage(HUD_PRINTTALK, "Du kannst keine anderen Jobs promoten!")
                return
            end
            local tRankID = luctusGetRankID(tPly:Team(),tPly:GetNWString("l_nametag",""))
            if tRankID and rankID > tRankID+1 then
                luctusRankup(tPly,RPExtraTeams[tPly:Team()].command,ply)
            else
                ply:PrintMessage(HUD_PRINTTALK, "Du kannst nicht auf deinen Rang hochpromoten!")
            end
        else
            ply:PrintMessage(HUD_PRINTTALK, "Du hast keine Berechtigung für !promote!")
            return ""
        end
    end
    if string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKDOWN_CMD then
        local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
        if rankID and luctus_jobranks[jobname][rankID][3] then
            local tPly = luctusGetPlayer(string.Split(text," ")[2])
            if not tPly then
                ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
                return
            end
            if ply:Team() ~= tPly:Team() then
                ply:PrintMessage(HUD_PRINTTALK, "Du kannst keine anderen Jobs demoten!")
                return
            end
            local tRankID = luctusGetRankID(tPly:Team(),tPly:GetNWString("l_nametag",""))
            if tRankID and rankID > tRankID then
                luctusRankdown(tPly,RPExtraTeams[tPly:Team()].command,ply)
            else
                ply:PrintMessage(HUD_PRINTTALK, "Du kannst diesen Spieler nicht demoten!")
            end
        else
            ply:PrintMessage(HUD_PRINTTALK, "Du hast keine Berechtigung für !demote!")
            return ""
        end
    end
    if string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKUP_ADMIN_CMD then
        if ply:IsAdmin() or ply:IsSuperAdmin() then
            local tPly = luctusGetPlayer(string.Split(text," ")[2])
            if not tPly then
                ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
                return ""
            end
            luctusRankup(tPly,RPExtraTeams[tPly:Team()].command,ply)
            return ""
        else
            ply:PrintMessage(HUD_PRINTTALK, "Du hast keinen Zugang zu diesem Befehl!")
        end
    end
    if string.Split(text," ")[1] == LUCTUS_JOBRANKS_RANKDOWN_ADMIN_CMD then
        if ply:IsAdmin() or ply:IsSuperAdmin() then
            local tPly = luctusGetPlayer(string.Split(text," ")[2])
            if not tPly then
                ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
                return ""
            end
            luctusRankdown(tPly,RPExtraTeams[tPly:Team()].command,ply)
            return ""
        else
            ply:PrintMessage(HUD_PRINTTALK, "Du hast keinen Zugang zu diesem Befehl!")
        end
    end
end)

hook.Add("PlayerSpawn", "luctus_nametags", function(ply)
    local jobname = ply:Team()
    if ply.lrankID and tonumber(ply.lrankID) and luctus_jobranks[jobname] and luctus_jobranks[jobname][ply.lrankID] then
        if luctus_jobranks[jobname][ply.lrankID][4] then
            for k,v in pairs(luctus_jobranks[jobname][ply.lrankID][4]) do
                ply:Give(v)
            end
        end
    end
end)

hook.Add("OnPlayerChangedTeam", "luctus_nametags", function(ply, beforeNum, afterNum)
    local beforeName = team.GetName(beforeNum)
    local afterName = team.GetName(afterNum)
    --switch from X
    if luctus_jobranks[beforeName] then
        ply:SetNWString("l_nametag","")
        ply.lrankID = nil
    end

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
        if not tonumber(rankid) then
            print("[luctus_jobranks] ERROR SELECT RANKID WAS NOT A NUMBER!")
            return
        end
        rankid = tonumber(rankid)
        ply:SetNWString("l_nametag",luctus_jobranks[jobname][rankid][1])
        ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[jobname][rankid][2]..")")
        ply:setDarkRPVar("salary", RPExtraTeams[curTeam].salary)
        if luctus_jobranks[jobname][rankid][5] then
            ply:setDarkRPVar("salary", RPExtraTeams[curTeam].salary + luctus_jobranks[jobname][rankid][5])
        end
        ply.lrankID = rankid
    else
        local inres = sql.Query("INSERT INTO luctus_jobranks(steamid,jobcmd,rankid) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(RPExtraTeams[curTeam].command)..",1)")
        if inres == false then
            error(sql.LastError())
        end
        if inres == nil then
            print("[luctus_jobranks] New player successfully inserted!")
        end
        ply:SetNWString("l_nametag", luctus_jobranks[jobname][1][1])
        ply:updateJob(ply:getDarkRPVar("job").." ("..luctus_jobranks[jobname][1][2]..")")
        ply:setDarkRPVar("salary", RPExtraTeams[curTeam].salary)
        if luctus_jobranks[jobname][1][5] then
            ply:setDarkRPVar("salary", RPExtraTeams[curTeam].salary + luctus_jobranks[jobname][1][5])
        end
        ply.lrankID = 1
    end
end

hook.Add("playerGetSalary", "luctus_jobranks_salary", function(player, amount)
    --Fix salary? For whatever reason DarkRP is ignoring ply:getDarkRPVar("salary")
    return false, "Payday! You received $" .. player:getDarkRPVar("salary") .. "!", player:getDarkRPVar("salary")
end)

print("[luctus_jobranks] sv loaded!")
