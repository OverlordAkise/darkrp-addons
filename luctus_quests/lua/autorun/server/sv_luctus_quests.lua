--Luctus Quests
--Made by OverlordAkise

--Should the quest menu be opened via chat command?
LUCTUS_QUESTS_CHATMENU = true
--With what command can you open the quest menu?
LUCTUS_QUESTS_CHATCOMMAND = "!quests"

--CONFIG END

LUCTUS_QUESTS_LIST = LUCTUS_QUESTS_LIST or {}
LUCTUS_QUESTS_COMPLETED = LUCTUS_QUESTS_COMPLETED or {}

util.AddNetworkString("luctus_quests")

hook.Add("InitPostEntity","luctus_quests",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_quests(steamid VARCHAR(100), quests TEXT)") --quests: json [name]=unlockedInTimestamp
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_quests_active(steamid VARCHAR(100), name TEXT, progress INT, needed INT)")
    if res==false then error(sql.LastError()) end
end)

function LuctusQuestsStart(ply,name)
    local quest = LUCTUS_QUESTS_LIST[name]
    if not quest then return end
    if LUCTUS_QUESTS_COMPLETED[ply][name] and (LUCTUS_QUESTS_COMPLETED[ply][name] == 0 or LUCTUS_QUESTS_COMPLETED[ply][name] > os.time()) then
        DarkRP.notify(ply,1,5,"You already completed this quest!")
        return
    end
    if ply.lqName ~= "" then
        DarkRP.notify(ply,1,5,"You already have an active quest!")
        return
    end
    if quest.unlockfunc and not quest.unlockfunc(ply) then
        DarkRP.notify(ply,1,5,"You do not meet the requirements to do this quest!")
        return
    end
    ply.lqName = name
    ply.lqProgress = 0
    ply.lqNeeded = quest.progressNeeded
    quest.startfunc(ply)
    DarkRP.notify(ply,0,5,"Quest '"..name.."' started")
    LuctusQuestsSaveActiveQuest(ply,name,quest.progressNeeded)
    hook.Run("LuctusQuestsStarted",ply,qname)
end

function LuctusQuestsCancel(ply)
    if ply.lqName == "" then
        DarkRP.notify(ply,1,5,"You do not have an active quest!")
        return
    end
    local qname = ply.lqName
    local quest = LUCTUS_QUESTS_LIST[qname]
    if not quest then return end
    quest.endfunc(ply)
    ply.lqName = ""
    ply.lqProgress = 0
    ply.lqNeeded = 0
    DarkRP.notify(ply,0,5,"Quest '"..qname.."' stopped")
    LuctusQuestsSaveActiveQuest(ply,"",0)
    hook.Run("LuctusQuestsCanceled",ply,qname)
end

function LuctusQuestsProgress(ply,raiseBy)
    raiseBy = raiseBy or 1
    ply.lqProgress = ply.lqProgress + raiseBy
    if ply.lqProgress >= ply.lqNeeded then
        LuctusQuestsComplete(ply)
    end
end

function LuctusQuestsComplete(ply)
    local qname = ply.lqName
    local quest = LUCTUS_QUESTS_LIST[qname]
    if not quest then return end
    if quest.repeatDelay > 0 then
        LUCTUS_QUESTS_COMPLETED[ply][qname] = os.time()+quest.repeatDelay
    else
        LUCTUS_QUESTS_COMPLETED[ply][qname] = 0
    end
    quest.endfunc(ply)
    ply.lqName = ""
    ply.lqProgress = 0
    ply.lqNeeded = 0
    quest.completefunc(ply)
    DarkRP.notify(ply,0,5,"Quest '"..qname.."' completed!")
    LuctusQuestsSaveComplete(ply)
    hook.Run("LuctusQuestsCompleted",ply,qname)
end

function LuctusQuestsSaveComplete(ply)
    local res = sql.Query("UPDATE luctus_quests_active SET name='',progress=0,needed=0 WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
    res = sql.Query(string.format("UPDATE luctus_quests SET quests=%s WHERE steamid=%s",sql.SQLStr(util.TableToJSON(LUCTUS_QUESTS_COMPLETED[ply])),sql.SQLStr(ply:SteamID())))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end

function LuctusQuestsSaveActiveQuest(ply,name,needed)
    local res = sql.Query(string.format("UPDATE luctus_quests_active SET name='%s',progress=0,needed=%d WHERE steamid=%s",name,needed,sql.SQLStr(ply:SteamID())))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end

hook.Add("PlayerInitialSpawn","luctus_quests",function(ply)
    LUCTUS_QUESTS_COMPLETED[ply] = {}
    LuctusQuestsLoad(ply)
end)

function LuctusQuestsLoad(ply)
    local res = sql.QueryRow("SELECT steamid,name,progress,needed FROM luctus_quests_active WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
    if not res or table.IsEmpty(res) then
        --New user
        print("[luctus_quests] Inserting new user",ply:SteamID(),ply:Nick())
        res = sql.Query(string.format("INSERT INTO luctus_quests_active(steamid,name,progress,needed) VALUES(%s,'',0,0)",sql.SQLStr(ply:SteamID())))
        if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
        ply.lqName = ""
        ply.lqProgress = 0
        ply.lqNeeded = 0
        res = sql.Query(string.format("INSERT INTO luctus_quests(steamid,quests) VALUES(%s,'{}')",sql.SQLStr(ply:SteamID())))
        if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
        return
    else
        ply.lqName = res.name
        ply.lqProgress = res.progress
        ply.lqNeeded = res.needed
        local quest = LUCTUS_QUESTS_LIST[name]
        if quest then 
            quest.startfunc(ply)
        else
            ply.lqName = ""
            ply.lqProgress = 0
            ply.lqNeeded = 0
        end
    end
    res = sql.QueryValue("SELECT quests FROM luctus_quests WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
    if res then
        LUCTUS_QUESTS_COMPLETED[ply] = util.JSONToTable(res)
    end
end

hook.Add("PlayerDisconnected","luctus_dailyquests",function(ply)
    LUCTUS_QUESTS_COMPLETED[ply] = nil
    LuctusQuestsSaveProgress(ply)
end)

hook.Add("ShutDown","luctus_quests_saveprogress",function()
    LuctusQuestsSaveProgressForAll()
end)

function LuctusQuestsSaveProgress(ply)
    if ply.lqName == "" then return end
    local res = sql.Query(string.format("UPDATE luctus_quests_active SET progress=%d WHERE steamid=%s",ply.lqProgress,sql.SQLStr(ply:SteamID())))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end

function LuctusQuestsSaveProgressForAll()
    sql.Begin()
    for k,ply in ipairs(player.GetHumans()) do
        LuctusQuestsSaveProgress(ply)
    end
    sql.Commit()
end


function LuctusQuestsHasActiveQuest(ply)
    return ply.lqName ~= ""
end

local cd = {}
net.Receive("luctus_quests",function(len,ply)
    if not cd[ply] then cd[ply] = 0 end
    if cd[ply]>CurTime() then return end
    cd[ply] = CurTime()+0.2
    
    local shouldStart = net.ReadBool()
    local questName = net.ReadString()
    if shouldStart then
        LuctusQuestsStart(ply,questName)
    else
        LuctusQuestsCancel(ply)
    end
end)

function LuctusQuestsOpenMenu(ply)
    net.Start("luctus_quests")
        net.WriteTable(LUCTUS_QUESTS_COMPLETED[ply])
        net.WriteString(ply.lqName)
    net.Send(ply)
end

hook.Add("PlayerSay","luctus_quests",function(ply,text)
    if not LUCTUS_QUESTS_CHATMENU then return end
    if text == LUCTUS_QUESTS_CHATCOMMAND then
        LuctusQuestsOpenMenu(ply)
    end
end)

print("[luctus_quests] sv loaded")
