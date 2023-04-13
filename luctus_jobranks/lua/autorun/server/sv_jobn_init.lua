--Luctus Jobranks
--Made by OverlordAkise

luctus_jobranks = {}
hook.Add("postLoadCustomDarkRPItems", "luctus_jobranks_init", function()

    --CONFIG START HERE

    --Explanation:

    --1   "[R]",          The short name infront of your Player name
    --2   "Rekrut",       The long name behind your Job name
    --3   false,          If the rank can up / downrank other players
    --4   {"m9k_mp5sd"},  What weapons the rank spawns with
    --5   15              Custom Salary (added ontop of base job salary)

    --An Example:
    luctus_jobranks[TEAM_CITIZEN] = {
        [1] = {"[R]", "Rekrut",false,{"guthscp_keycard_lvl_2","m9k_mp5sd"},15},
        [2] = {"[P]", "Private",false,{"guthscp_keycard_lvl_3","m9k_mp5sd"},20},
        [3] = {"[C]", "Corporal",false,{"guthscp_keycard_lvl_3","m9k_mp5sd"},25},
        [4] = {"[SGT]", "Seargent",false,{"guthscp_keycard_lvl_3","m9k_m4a1"},30},
        [5] = {"[L]", "Leader",false,{"guthscp_keycard_lvl_3","m9k_m4a1"},45},
        [6] = {"[WC]", "Watchcommander",true,{"guthscp_keycard_lvl_3","m9k_m16a4_acog"},60},
        [7] = {"[Chief]", "Chief",true,{"guthscp_keycard_lvl_4","m9k_m16a4_acog"},100}
    }
  
    --Required/Mandatory are only the first 2 things: Short-Name and Long-Name
    --This is also valid:
    luctus_jobranks[TEAM_HOBO] = {
        [1] = {"[LCOL]", "Lieutenant Colonel"},
        [2] = {"[COL]", "Colonel"}
    }
  
    --You can also copy rankconfigs, but the ranks of players will NOT copy over! Only the config gets copied!
    luctus_jobranks[TEAM_MEDIC] = luctus_jobranks[TEAM_HOBO]
  
  
    --CONFIG END HERE
    print("[luctus_jobranks] Config loaded!")
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT )") --Safety
end)

LuctusLog = LuctusLog or function()end

hook.Add("PostGamemodeLoaded","luctus_jobranks_dbinit",function()
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



function luctusGetRankID(team,rankShort)
    if not luctus_jobranks[team] then return nil end
    local count = 1
    for k,v in pairs(luctus_jobranks[team]) do
        if v[1] == rankShort then
            return k
        end
    end
    return nil
end



function luctusRankup(ply,teamcmd,executor)
    local newId = 0
    local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        newId = math.min(tonumber(res[1].rankid) + 1,#luctus_jobranks[ply:Team()])
        --print(newId)
        local ires = sql.Query("UPDATE luctus_jobranks SET rankid = "..(newId).." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
        if ires == false then
            error(sql.LastError())
        end
        DarkRP.notify(ply,0,5,"Du wurdest befördert!")
        ply:PrintMessage(HUD_PRINTTALK, "Du wurdest befördert!")
        ply:SetNWString("l_nametag", luctus_jobranks[ply:Team()][newId][1])
        ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[ply:Team()][newId][2]..")")
        ply:setDarkRPVar("salary", ply:getJobTable().salary)
        if luctus_jobranks[ply:Team()][newId][5] then
            ply:setDarkRPVar("salary", ply:getJobTable().salary + luctus_jobranks[ply:Team()][newId][5])
        end
        ply.lrankID = newId
        LuctusLog("Jobranks",executor:Nick().."("..executor:SteamID()..") just promoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[ply:Team()][newId][2])
    end
end



function luctusRankdown(ply,teamcmd,executor)
    local newId = 0
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
        ply:SetNWString("l_nametag", luctus_jobranks[ply:Team()][newId][1])
        ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[ply:Team()][newId][2]..")")
        ply:setDarkRPVar("salary", ply:getJobTable().salary)
        if luctus_jobranks[ply:Team()][newId][5] then
            ply:setDarkRPVar("salary", ply:getJobTable().salary + luctus_jobranks[ply:Team()][newId][5])
        end
        ply.lrankID = newId
        LuctusLog("Jobranks",executor:Nick().."("..executor:SteamID()..") just demoted "..ply:Nick().."("..ply:SteamID()..") to "..luctus_jobranks[ply:Team()][newId][2])
    end
end



hook.Add("PlayerSay", "luctus_jobranks_promote", function(ply,text,team)
    if string.Split(text," ")[1] == "!promote" then
        local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
        if rankID and luctus_jobranks[ply:Team()][rankID][3] then
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
    if string.Split(text," ")[1] == "!demote" then
        local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
        if rankID and luctus_jobranks[ply:Team()][rankID][3] then
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
    if string.Split(text," ")[1] == "!apromote" then
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
    if string.Split(text," ")[1] == "!ademote" then
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
    if ply.lrankID and tonumber(ply.lrankID) and luctus_jobranks[ply:Team()] and luctus_jobranks[ply:Team()][ply.lrankID] then
        if luctus_jobranks[ply:Team()][ply.lrankID][4] then
            for k,v in pairs(luctus_jobranks[ply:Team()][ply.lrankID][4]) do
                ply:Give(v)
            end
        end
    end
end)


hook.Add("OnPlayerChangedTeam", "luctus_nametags", function(ply, beforeNum, afterNum)
    --switch from X
    if luctus_jobranks[beforeNum] then
        ply:SetNWString("l_nametag","")
        ply.lrankID = nil
    end

    --Jobranks
    if luctus_jobranks[afterNum] then
        local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(RPExtraTeams[afterNum].command))
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
            ply:SetNWString("l_nametag",luctus_jobranks[afterNum][rankid][1])
            ply:updateJob(ply:getDarkRPVar("job").." ("..luctus_jobranks[afterNum][rankid][2]..")")
            ply:setDarkRPVar("salary", RPExtraTeams[afterNum].salary)
            if luctus_jobranks[afterNum][rankid][5] then
                ply:setDarkRPVar("salary", RPExtraTeams[afterNum].salary + luctus_jobranks[afterNum][rankid][5])
            end
            ply.lrankID = rankid
        else
            local inres = sql.Query("INSERT INTO luctus_jobranks(steamid,jobcmd,rankid) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(RPExtraTeams[afterNum].command)..",1)")
            if inres == false then
                error(sql.LastError())
            end
            if inres == nil then
                print("[luctus_jobranks] New player successfully inserted!")
            end
            ply:SetNWString("l_nametag", luctus_jobranks[afterNum][1][1])
            ply:updateJob(ply:getDarkRPVar("job").." ("..luctus_jobranks[afterNum][1][2]..")")
            ply:setDarkRPVar("salary", RPExtraTeams[afterNum].salary)
            if luctus_jobranks[afterNum][1][5] then
                ply:setDarkRPVar("salary", RPExtraTeams[afterNum].salary + luctus_jobranks[afterNum][1][5])
            end
            ply.lrankID = 1
        end
    end
end)

hook.Add("playerGetSalary", "luctus_jobranks_salary", function(Player, Amount)
    --Fix salary? For whatever reason DarkRP is ignoring ply:getDarkRPVar("salary")
    return false, "Payday! You received $" .. Player:getDarkRPVar("salary") .. "!", Player:getDarkRPVar("salary")
end)

print("[luctus_jobranks] sv loaded!")
