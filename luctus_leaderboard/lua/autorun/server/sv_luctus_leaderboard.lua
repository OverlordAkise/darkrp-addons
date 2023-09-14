--Luctus Leaderboard
--Made by OverlordAkise


--Dynamically shut down the logic if false
LUCTUS_LEADERBOARDS_ACTIVE = true



LUCTUS_LEADERBOARDS = LUCTUS_LEADERBOARDS or {}
LUCTUS_LEADERBOARD_CACHE = {}

util.AddNetworkString("luctus_leaderboard_menu")
util.AddNetworkString("luctus_leaderboard_data")

function LuctusLeaderboardAdd(name,func)
    LUCTUS_LEADERBOARDS[name] = func
end

function LuctusLeaderboardGet(name)
    if not LUCTUS_LEADERBOARDS[name] then return {} end
    if LUCTUS_LEADERBOARD_CACHE[name] then
        if LUCTUS_LEADERBOARD_CACHE[name].expiry < CurTime() then
            LUCTUS_LEADERBOARD_CACHE[name] = nil
        else
            return LUCTUS_LEADERBOARD_CACHE[name].data
        end
    end
    local func = LUCTUS_LEADERBOARDS[name]
    local tab = func()
    LUCTUS_LEADERBOARD_CACHE[name] = {}
    LUCTUS_LEADERBOARD_CACHE[name].expiry = CurTime()+60
    LUCTUS_LEADERBOARD_CACHE[name].data = tab
    return tab
end

function LuctusLeaderboardGetBoards()
    local tab = {}
    for k,v in pairs(LUCTUS_LEADERBOARDS) do
        table.insert(tab,k)
    end
    return tab
end

hook.Add("PlayerSay","luctus_leaderboard",function(ply,text)
    if text != "!leaderboard" then return end
    net.Start("luctus_leaderboard_menu")
        net.WriteTable(LuctusLeaderboardGetBoards())
    net.Send(ply)
end)

net.Receive("luctus_leaderboard_data",function(len,ply)
    if not LUCTUS_LEADERBOARDS_ACTIVE then return end
    net.Start("luctus_leaderboard_data")
        net.WriteTable(LuctusLeaderboardGet(net.ReadString()))
    net.Send(ply)
end)

hook.Add("InitPostEntity","luctus_leaderboard_load",function()
    hook.Run("LuctusLeaderboardAdd")
end)



-- Leaderboards:


hook.Add("LuctusLeaderboardAdd","darkrp_money",function()
    if not DarkRP then return end
    LuctusLeaderboardAdd("DarkRP Money",function()
        local res = sql.Query("SELECT DISTINCT rpname,wallet FROM darkrp_player ORDER BY wallet DESC LIMIT 20;")
        if res and res[1] then
            local tab = {}
            for k,v in ipairs(res) do
                table.insert(tab,{v.rpname,v.wallet})
            end
            return tab
        end
        return {}
    end)
end)

hook.Add("LuctusLeaderboardAdd","utime",function()
    if not timer.Exists("UTimeTimer") then return end
    LuctusLeaderboardAdd("UTime Playtime",function()
        local res = sql.Query("SELECT rpname,totaltime FROM utime INNER JOIN darkrp_player ON utime.player = darkrp_player.uid ORDER BY totaltime DESC LIMIT 20;")
        if res and res[1] then
            local tab = {}
            for k,v in ipairs(res) do
                table.insert(tab,{v.rpname,string.NiceTime(tonumber(v.totaltime)).."/"..v.totaltime})
            end
            return tab
        end
        return {}
    end)
end)

hook.Add("LuctusLeaderboardAdd","luctus_levelsystem",function()
    if not LuctusLevelLoad then return end
    LuctusLeaderboardAdd("Highest ply level",function()
        local res = sql.Query("SELECT rpname,lvl FROM luctus_levelsystem INNER JOIN darkrp_player ON luctus_levelsystem.steamid64 = darkrp_player.uid ORDER BY lvl DESC LIMIT 20;")
        if res and res[1] then
            local tab = {}
            for k,v in ipairs(res) do
                table.insert(tab,{v.rpname,v.lvl})
            end
            return tab
        end
        return {}
    end)
end)

hook.Add("LuctusLeaderboardAdd","luctus_gangs",function()
    if not LUCTUS_GANGS_CREATE_COST then return end
    LuctusLeaderboardAdd("Highest gang level",function()
        local res = sql.Query("SELECT name,level FROM luctus_gangs ORDER BY level DESC LIMIT 20;")
        if res and res[1] then
            local tab = {}
            for k,v in ipairs(res) do
                table.insert(tab,{v.name,v.level})
            end
            return tab
        end
        return {}
    end)
    LuctusLeaderboardAdd("Highest gang money",function()
        local res = sql.Query("SELECT name,money FROM luctus_gangs ORDER BY money DESC LIMIT 20;")
        if res and res[1] then
            local tab = {}
            for k,v in ipairs(res) do
                table.insert(tab,{v.name,v.money})
            end
            return tab
        end
        return {}
    end)
end)

print("[luctus_leaderboard] sv loaded")
