--Luctus Dailyquests
--Made by OverlordAkise

LUCTUS_DAILYQUESTS_LIST = LUCTUS_DAILYQUESTS_LIST or {}

util.AddNetworkString("luctus_dailyquests")
util.AddNetworkString("luctus_dailyquests_sync")
util.AddNetworkString("luctus_dailyquests_syncall")

hook.Add("InitPostEntity","luctus_dailyquests",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_dailyquests(steamid TEXT, date TEXT, quests TEXT, UNIQUE(steamid))")
    if res==false then error(sql.LastError()) end
end)

LUCTUS_DAILYQUESTS_CACHE = LUCTUS_DAILYQUESTS_CACHE or {}
LUCTUS_DAILYQUESTS_TODAY = os.date("%Y-%m-%d")

timer.Create("luctus_dailyquests_daychange",180,0,function()
    if os.date("%Y-%m-%d") == LUCTUS_DAILYQUESTS_TODAY then return end
    print("[luctus_dailyquests] Day changed, refreshing quests for online players")
    for k,ply in pairs(player.GetAll()) do
        LuctusDailyquestsLoadPlayer(ply)
    end
    LUCTUS_DAILYQUESTS_TODAY = os.date("%Y-%m-%d")
end)

hook.Add("InitPostEntity","luctus_dailyquests_load_custom",function()
    hook.Run("LuctusDailyquestLoad")
end)

function LuctusDailyquestsAddQuest(name,minNeed,maxNeed)
    table.insert(LUCTUS_DAILYQUESTS_LIST,{name,minNeed,maxNeed})
end

hook.Add("PlayerInitialSpawn","luctus_dailyquests",function(ply)
    LUCTUS_DAILYQUESTS_CACHE[ply] = {}
    LuctusDailyquestsLoadPlayer(ply)
end)

hook.Add("PlayerDisconnected","luctus_dailyquests",function(ply)
    LUCTUS_DAILYQUESTS_CACHE[ply] = nil
end)

net.Receive("luctus_dailyquests_syncall", function(len,ply)
    LuctusDailyquestsSyncAll(ply)
end)

function LuctusDailyquestsGetRandom()
    local quests = {}
    local tempList = table.Copy(LUCTUS_DAILYQUESTS_LIST)
    for i=1,LUCTUS_DAILYQUESTS_AMOUNT do
        local q = table.remove(tempList,math.random(#tempList))
        if not q then return quests end --no more quests
        quests[ q[1] ] = {0,math.random(q[2],q[3])}
    end
    return quests
end

function LuctusDailyquestsLoadPlayer(ply)
    local res = sql.QueryRow("SELECT * FROM luctus_dailyquests WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res==false then error(sql.LastError()) end
    if res then
        if res.date == LUCTUS_DAILYQUESTS_TODAY then
            LUCTUS_DAILYQUESTS_CACHE[ply] = util.JSONToTable(res.quests)
        else
            LUCTUS_DAILYQUESTS_CACHE[ply] = LuctusDailyquestsGetRandom()
        end
    else
        LUCTUS_DAILYQUESTS_CACHE[ply] = LuctusDailyquestsGetRandom()
    end
    LuctusDailyquestsSaveQuests(ply)
end

function LuctusDailyquestsSaveQuests(ply)
    local res = sql.Query("REPLACE INTO luctus_dailyquests(steamid,date,quests) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(LUCTUS_DAILYQUESTS_TODAY)..","..sql.SQLStr(util.TableToJSON(LUCTUS_DAILYQUESTS_CACHE[ply]))..")")
    if res==false then error(sql.LastError()) end
end

function LuctusDailyquestsHasActive(ply,name)
    local q = LUCTUS_DAILYQUESTS_CACHE[ply][name]
    return q and q[1]<q[2] or false
end

function LuctusDailyquestsProgress(ply,name,raiseBy)
    raiseBy = raiseBy or 1
    local quest = LUCTUS_DAILYQUESTS_CACHE[ply][name]
    if not quest then return end
    local newValue = quest[1] + raiseBy
    LUCTUS_DAILYQUESTS_CACHE[ply][name][1] = newValue
    LuctusDailyquestsSync(ply,name,newValue)
    LuctusDailyquestsSaveQuests(ply)
    if newValue >= quest[2] then
        hook.Run("LuctusDailyquestsFinished",ply,name)
        LuctusDailyquestsNotify(ply, "You have finished quest: "..name)
    end
end


function LuctusDailyquestsSyncAll(ply)
    net.Start("luctus_dailyquests_syncall")
        net.WriteInt(LUCTUS_DAILYQUESTS_AMOUNT,32)
        for name,quest in pairs(LUCTUS_DAILYQUESTS_CACHE[ply]) do
            net.WriteString(name)
            net.WriteInt(quest[1],32)
            net.WriteInt(quest[2],32)
        end
    net.Send(ply)
end

function LuctusDailyquestsSync(ply,name,newValue)
    net.Start("luctus_dailyquests_sync")
        net.WriteString(name)
        net.WriteInt(newValue,32)
    net.Send(ply)
end

function LuctusDailyquestsNotify(ply,text)
    ply:PrintMessage(3,text)
end

print("[luctus_dailyquests] sv loaded")
