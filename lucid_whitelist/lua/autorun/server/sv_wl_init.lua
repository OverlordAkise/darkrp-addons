--Lucid Whitelist
--Made by OverlordAkise

util.AddNetworkString("lucid_whitelist_get")
util.AddNetworkString("lucid_whitelist_set")

hook.Add("PlayerInitialSpawn", "lucid_whitelist", function(ply)
    local sqlData = sql.QueryRow("SELECT * FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if sqlData then
        local jsonData = util.JSONToTable(sqlData.jsonlist)
        for k,v in pairs(jsonData) do
            ply:SetNWBool(k,v)
        end
    end
end)

hook.Add("InitPostEntity","lucid_whitelist",function()
    sql.Query("CREATE TABLE IF NOT EXISTS lucid_whitelist( steamid TEXT, jsonlist TEXT )")
    local sqlData = sql.QueryRow("SELECT * FROM lucid_whitelist WHERE steamid = 'everyone'")
    print("DEBUG sqlData:",sqlData)
    if sqlData then
        local jsonData = util.JSONToTable(sqlData.jsonlist)
        for k,v in pairs(jsonData) do
            print("DEBUG adding global everyone:",k,"->",v)
            SetGlobalBool(k,v)
        end
    end
end)


net.Receive("lucid_whitelist_set", function(len,ply)
    if not ply:IsAdmin() then return end
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
    if(res == false)then
        print("[lwhitelist] ERROR DURING SQL SET DELETE!")
    else
        print("[lwhitelist] Successfully deleted old whitelist for user "..steamid)
    end
    res = sql.Query("INSERT INTO lucid_whitelist(steamid,jsonlist) VALUES("..sql.SQLStr(steamid)..", "..sql.SQLStr(jtext)..")")
    if(res == false)then
        print("[lwhitelist] ERROR DURING SQL SET INSERT!")
    else
        print("[lwhitelist] Successfully inserted new whitelist for user "..steamid)
        print("DEBUG Data: "..steamid.." Whitelist: "..jtext)
    end
  
    if steamid == "everyone" then
        for job_index,job in pairs(RPExtraTeams) do
            if(jsondata[job.name])then
                SetGlobalBool(job.name,true)
            else
                SetGlobalBool(job.name,false)
            end
        end
    else
        for k,v in pairs(player.GetAll()) do
            if v:SteamID() == steamid then
                for job_index,job in pairs(RPExtraTeams) do
                    if(jsondata[job.name])then
                        v:SetNWBool(job.name,true)
                    else
                        v:SetNWBool(job.name,false)
                    end
                end
                break
            end
        end
    end
end)

net.Receive("lucid_whitelist_get", function(len,ply)
    if not ply:IsAdmin() then return end
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
end)

print("[lwhitelist] Lucid Whitelist server loaded!")
