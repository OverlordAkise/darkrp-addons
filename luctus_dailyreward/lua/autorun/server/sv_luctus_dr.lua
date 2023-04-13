--Luctus Daily Rewards
--Made by OverlordAkise

util.AddNetworkString("luctus_dayward")
util.AddNetworkString("luctus_dayward_sync")

hook.Add("InitPostEntity","luctus_dailyrewards",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_dailyreward(steamid TEXT, lastreward INT, streak INT)")
    if res == false then
        error(sql.LastError())
    end
end)

hook.Add("PlayerInitialSpawn","luctus_dailyrewards",function(ply)
    ply.lastDailyReward = 0
    ply.dailyRewardStreak = 1
    local res = sql.Query("SELECT * FROM luctus_dailyreward WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        ply.lastDailyReward = tonumber(res[1].lastreward)
        ply.dailyRewardStreak = tonumber(res[1].streak)
    else
        res = sql.Query("INSERT INTO luctus_dailyreward(steamid,lastreward,streak) VALUES("..sql.SQLStr(ply:SteamID())..",0,1)")
        if err == false then
            error(sql.LastError())
        end
    end
    --if lastLogin was not today or yesterday then reset
    if os.date("%Y%m%d",ply.lastDailyReward) != os.date("%Y%m%d") and os.date("%Y%m%d",ply.lastDailyReward+86400) != os.date("%Y%m%d") then
        ply.dailyRewardStreak = 1
    end
end)

net.Receive("luctus_dayward",function(len,ply)
    --print("[DEBUG]","Received daily reward sv")
    if os.date("%Y%m%d",ply.lastDailyReward) != os.date("%Y%m%d") then
        print("[DEBUG]","Date different, giving reward")
        LuctusDailyRewardReward(ply)
    end
end)

net.Receive("luctus_dayward_sync",function(len,ply)
    net.Start("luctus_dayward_sync")
        net.WriteInt(ply.lastDailyReward,32)
        net.WriteInt(ply.dailyRewardStreak,32)
    net.Send(ply)
end)

function LuctusDailyRewardReward(ply)
    --print("[DEBUG]","Reward start for",ply)
    ply.lastDailyReward = os.time()
    if LUCTUS_DAYWARD_STAY_HIGHEST_REWARD then
        ply.dailyRewardStreak = math.min(ply.dailyRewardStreak + 1,#LUCTUS_DAYWARD_AMOUNT)
    else
        ply.dailyRewardStreak = ply.dailyRewardStreak + 1
        if ply.dailyRewardStreak > #LUCTUS_DAYWARD_AMOUNT then
            ply.dailyRewardStreak = 1
        end
    end
    local res = sql.Query("UPDATE luctus_dailyreward SET lastreward="..os.time()..",streak="..ply.dailyRewardStreak.." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    local amountTable = LUCTUS_DAYWARD_AMOUNT[ply.dailyRewardStreak]
    for key,value in pairs(amountTable) do
        --print("[DEBUG]","Checking for type",key,"value",value,"//isin:",LUCTUS_DAYWARD_TYPES[key])
        if value ~= 0 and LUCTUS_DAYWARD_TYPES[key] then
            LUCTUS_DAYWARD_TYPES[key][2](ply,value)
            --print("[DEBUG]","Reward type",key,"for",ply)
            DarkRP.notify(ply,0,5,"[dailylogin] You received your reward!")
        end
    end
end

print("[luctus_dailyrewards] sv loaded")
