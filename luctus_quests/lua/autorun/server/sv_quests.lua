--Luctus Quests
--Made by OverlordAkise

LUCTUS_QUESTS_LIST = LUCTUS_QUESTS_LIST or {}

util.AddNetworkString("luctus_quests")
util.AddNetworkString("luctus_quests_sync")
util.AddNetworkString("luctus_quests_syncall")

hook.Add("InitPostEntity","luctus_quests",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_quests(steamid TEXT, date TEXT, quests TEXT, UNIQUE(steamid))")
    if res==false then error(sql.LastError()) end
end)

LUCTUS_QUESTS_CACHE = LUCTUS_QUESTS_CACHE or {}
LUCTUS_QUESTS_TODAY = os.date("%Y-%m-%d")

timer.Create("luctus_quests_daychange",180,0,function()
    if os.date("%Y-%m-%d") == LUCTUS_QUESTS_TODAY then return end
    print("[luctus_quests] Day changed, refreshing quests for online players")
    for k,ply in pairs(player.GetAll()) do
        LuctusQuestsLoadPlayer(ply)
    end
    LUCTUS_QUESTS_TODAY = os.date("%Y-%m-%d")
end)

hook.Add("InitPostEntity","luctus_quests_load_custom",function()
    hook.Run("LuctusQuestLoad")
end)

function LuctusQuestsAddQuest(name,minNeed,maxNeed)
    table.insert(LUCTUS_QUESTS_LIST,{name,minNeed,maxNeed})
end

hook.Add("PlayerInitialSpawn","luctus_quests",function(ply)
    LUCTUS_QUESTS_CACHE[ply] = {}
    LuctusQuestsLoadPlayer(ply)
end)

hook.Add("PlayerDisconnected","luctus_quests",function(ply)
    LUCTUS_QUESTS_CACHE[ply] = nil
end)

net.Receive("luctus_quests_syncall", function(len,ply)
    LuctusQuestsSyncAll(ply)
end)

function LuctusQuestsGetRandom()
    local quests = {}
    local tempList = table.Copy(LUCTUS_QUESTS_LIST)
    for i=1,LUCTUS_QUESTS_AMOUNT do
        local q = table.remove(tempList,math.random(#tempList))
        if not q then return quests end --no more quests
        quests[ q[1] ] = {0,math.random(q[2],q[3])}
    end
    return quests
end

function LuctusQuestsLoadPlayer(ply)
    local res = sql.QueryRow("SELECT * FROM luctus_quests WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res==false then error(sql.LastError()) end
    if res then
        if res.date == LUCTUS_QUESTS_TODAY then
            LUCTUS_QUESTS_CACHE[ply] = util.JSONToTable(res.quests)
        else
            LUCTUS_QUESTS_CACHE[ply] = LuctusQuestsGetRandom()
        end
    else
        LUCTUS_QUESTS_CACHE[ply] = LuctusQuestsGetRandom()
    end
    LuctusQuestsSaveQuests(ply)
end

function LuctusQuestsSaveQuests(ply)
    local res = sql.Query("REPLACE INTO luctus_quests(steamid,date,quests) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(LUCTUS_QUESTS_TODAY)..","..sql.SQLStr(util.TableToJSON(LUCTUS_QUESTS_CACHE[ply]))..")")
    if res==false then error(sql.LastError()) end
end

function LuctusQuestsHasActive(ply,name)
    local q = LUCTUS_QUESTS_CACHE[ply][name]
    return q and q[1]<q[2] or false
end

function LuctusQuestsProgress(ply,name,raiseBy)
    raiseBy = raiseBy or 1
    local quest = LUCTUS_QUESTS_CACHE[ply][name]
    if not quest then return end
    local newValue = quest[1] + raiseBy
    LUCTUS_QUESTS_CACHE[ply][name][1] = newValue
    LuctusQuestsSync(ply,name,newValue)
    LuctusQuestsSaveQuests(ply)
    if newValue >= quest[2] then
        hook.Run("LuctusQuestsFinished",ply,name)
        LuctusQuestsNotify(ply, "You have finished quest: "..name)
    end
end


function LuctusQuestsSyncAll(ply)
    net.Start("luctus_quests_syncall")
        net.WriteInt(LUCTUS_QUESTS_AMOUNT,32)
        for name,quest in pairs(LUCTUS_QUESTS_CACHE[ply]) do
            net.WriteString(name)
            net.WriteInt(quest[1],32)
            net.WriteInt(quest[2],32)
        end
    net.Send(ply)
end

function LuctusQuestsSync(ply,name,newValue)
    net.Start("luctus_quests_sync")
        net.WriteString(name)
        net.WriteInt(newValue,32)
    net.Send(ply)
end

function LuctusQuestsNotify(ply,text)
    ply:PrintMessage(3,text)
end

print("[luctus_quests] sv loaded")
