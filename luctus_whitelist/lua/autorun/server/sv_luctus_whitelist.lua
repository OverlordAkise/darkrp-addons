--Lucid Whitelist
--Made by OverlordAkise

util.AddNetworkString("lucid_whitelist_get")
util.AddNetworkString("lucid_whitelist_set")

hook.Add("playerCanChangeTeam","luctus_whitelist",function(ply,newTeam,force)
    if force then return true, "Job change was forced!" end
    local jobname = team.GetName(newTeam)
    local canChange = GetGlobalBool(jobname,false) or ply:GetNWBool(jobname,false)
    if not canChange then
        return false, LUCTUS_WHITELIST_ERRMESSAGE
    end
end)

hook.Add("PlayerInitialSpawn", "lucid_whitelist", function(ply)
    local jsonlist = sql.QueryValue("SELECT jsonlist FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if jsonlist then
        local jsonData = util.JSONToTable(jsonlist)
        for k,v in pairs(jsonData) do
            ply:SetNWBool(k,v)
        end
    end
end)

hook.Add("InitPostEntity","lucid_whitelist",function()
    sql.Query("CREATE TABLE IF NOT EXISTS lucid_whitelist( steamid TEXT, jsonlist TEXT )")
    local jsonlist = sql.QueryValue("SELECT jsonlist FROM lucid_whitelist WHERE steamid = 'everyone'")
    if jsonlist then
        local jsonData = util.JSONToTable(jsonlist)
        for k,v in pairs(jsonData) do
            SetGlobalBool(k,v)
        end
    end
end)


net.Receive("lucid_whitelist_set", function(len,ply)
    if not LUCTUS_WHITELIST_ALLOWED_RANKS[ply:GetUserGroup()] then return end
    local steamid = net.ReadString()

    if not (steamid:find("^STEAM_%d:%d:%d+$") or steamid == "everyone") then
        DarkRP.notify(ply, 1, 5, "[lwhitelist] You didn't send a valid ID!")
        return
    end
  
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local jsondata = util.JSONToTable(jtext)
    local res = sql.Query("DELETE FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(steamid))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    else
        print("[luctus_whitelist] Successfully deleted old whitelist for user "..steamid)
    end
    res = sql.Query("INSERT INTO lucid_whitelist(steamid,jsonlist) VALUES("..sql.SQLStr(steamid)..", "..sql.SQLStr(jtext)..")")
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    else
        print("[luctus_whitelist] Successfully inserted new whitelist for user "..steamid)
    end
    local targetPly = nil
    if steamid == "everyone" then
        for job_index,job in pairs(RPExtraTeams) do
            if jsondata[job.name] then
                SetGlobalBool(job.name,true)
            else
                SetGlobalBool(job.name,false)
            end
        end
    else
        for k,v in pairs(player.GetAll()) do
            if v:SteamID() == steamid then
                targetPly = v
                for job_index,job in pairs(RPExtraTeams) do
                    if jsondata[job.name] then
                        v:SetNWBool(job.name,true)
                    else
                        v:SetNWBool(job.name,false)
                    end
                end
                break
            end
        end
    end
    hook.Run("LuctusWhitelistUpdate",ply,targetPly,steamid,jtext)
end)

net.Receive("lucid_whitelist_get", function(len,ply)
    if not LUCTUS_WHITELIST_ALLOWED_RANKS[ply:GetUserGroup()] then return end
    local steamid = net.ReadString()

    if not (steamid:find("^STEAM_%d:%d:%d+$") or steamid == "everyone") then
        DarkRP.notify(ply, 1, 5, "[lwhitelist] You didn't send a valid ID!")
        return
    end

    local sqlData = sql.QueryRow("SELECT * FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(steamid))
  
    net.Start("lucid_whitelist_get")
    net.WriteString(steamid)
    if sqlData then
        jsontab = sqlData.jsonlist
    else
        jsontab = "{}"
    end

    local a = util.Compress(jsontab)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
    net.Send(ply)
    if sqlData==false then
        error(sql.LastError())
    end
end)

print("[luctus_whitelist] Lucid Whitelist server loaded!")
