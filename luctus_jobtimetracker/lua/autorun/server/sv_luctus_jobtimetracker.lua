--Luctus JobTimeTracker
--Made by OverlordAkise

--If you have used the old jobtimetracker script please run the following to reset the database for the new format and then restart the server:
-- lua_run sql.Query("DROP TABLE luctus_jobtimetracker")


--Which command shows playtime for a player
-- !jobtime            - view your own job playtimes
-- !jobtime <steamid>  - view someone elses job playtimes
LUCTUS_JOBTIMETRACKER_CMD = "!jobtime"
--Which command shows the server's all together jobtimes
LUCTUS_JOBTIMETRACKER_CMD_ALL = "!jobtimeall"


--config end


util.AddNetworkString("luctus_jtt")

hook.Add("InitPostEntity","luctus_jobtimetracker",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobtimetracker(steamid TEXT, job TEXT, changedToAmount BIGINT, time BIGINT)")
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end)

hook.Add("postLoadCustomDarkRPItems","luctus_statistics_init_jobs",function()
    print("[luctus_statistics] Init database postdrp")
    local dbJobs = sql.Query("SELECT * FROM luctus_jobtimetracker WHERE steamid='all'")
    local alreadyExistJobs = {}
    if not istable(dbJobs) then dbJobs = {} end
    for k,v in ipairs(dbJobs) do
        alreadyExistJobs[v.job] = true
    end
    for k,v in ipairs(RPExtraTeams) do
        if not alreadyExistJobs[v.name] then
            local res = sql.Query("INSERT INTO luctus_jobtimetracker VALUES('all',"..sql.SQLStr(v.name)..",0,0)")
            if res == false then ErrorNoHaltWithStack(sql.LastError()) end
            print("[luctus_statistics] New job added: "..v.name)
        end
    end
end)

local lastChange = {}
local timeCache = {}

function LuctusJobtimetrackerSave(ply,job)
    local newTime = math.Round(timeCache[ply] + CurTime()-lastChange[ply])
    local res = sql.Query("UPDATE luctus_jobtimetracker SET time="..newTime.." WHERE steamid="..sql.SQLStr(ply:SteamID()).." AND job="..sql.SQLStr(job))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
    timeCache[ply] = newTime
end

function LuctusJTTSaveServerTimes()
    local ss = SysTime()
    local jobTimes = {}
    for k,ply in ipairs(player.GetHumans()) do
        if not ply.switchJob then continue end
        if not jobTimes[team.GetName(ply:Team())] then jobTimes[team.GetName(ply:Team())] = 0 end
        jobTimes[team.GetName(ply:Team())] = jobTimes[team.GetName(ply:Team())] + math.Round(CurTime()-ply.switchJob)
        ply.switchJob = CurTime()
    end
    local res = nil
    for jobname,playtime in pairs(jobTimes) do
        res = sql.Query("UPDATE luctus_jobtimetracker SET time = time + "..playtime.." WHERE steamid='all' AND job="..sql.SQLStr(jobname))
        if res == false then ErrorNoHaltWithStack(sql.LastError()) end
    end
    --print("[luctus_statistics] Saved all players in "..(SysTime()-ss).."s")
end

hook.Add("PlayerInitialSpawn","luctus_jobtimetracker",function(ply)
    ply.switchJob = CurTime()
    -- lastChange[ply] = CurTime()
end)

hook.Add("PlayerChangedTeam", "luctus_jobtimetracker", function(ply, beforeNum, afterNum)
    local beforeJob = team.GetName(beforeNum)
    local afterJob = team.GetName(afterNum)
    --plytime
    if lastChange[ply] then
        LuctusJobtimetrackerSave(ply,beforeJob)
    end
    lastChange[ply] = CurTime()
    timeCache[ply] = 0
    local res = sql.QueryRow("SELECT * FROM luctus_jobtimetracker WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND job="..sql.SQLStr(afterJob))
    if res==false then error(sql.LastError()) end
    if res then
        timeCache[ply] = res.time
    else
        res = sql.Query("INSERT INTO luctus_jobtimetracker(steamid,job,changedToAmount,time) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(afterJob)..",0,0)")
        if res==false then error(sql.LastError()) end
    end
    local res = sql.Query("UPDATE luctus_jobtimetracker SET changedToAmount = changedToAmount + 1 WHERE steamid="..sql.SQLStr(ply:SteamID()).." AND job="..sql.SQLStr(afterJob))
    if res==false then error(sql.LastError()) end
    
    --alltime
    local res = sql.Query("UPDATE luctus_jobtimetracker SET changedToAmount = changedToAmount + 1 WHERE steamid='all' AND job = "..sql.SQLStr(afterJob))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    res = sql.Query("UPDATE luctus_jobtimetracker SET time = time + "..math.Round(CurTime()-ply.switchJob).." WHERE steamid='all' AND job = "..sql.SQLStr(beforeJob))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    ply.switchJob = CurTime()
end)

hook.Add("PlayerDisconnected", "luctus_jobtimetracker", function(ply)
    --plytime
    if lastChange[ply] then
        LuctusJobtimetrackerSave(ply, team.GetName(ply:Team()))
    end
    lastChange[ply] = nil
    timeCache[ply] = nil
    --alltime
    if ply.switchJob then
        sql.Query("UPDATE luctus_jobtimetracker SET time = time + "..math.Round(CurTime()-ply.switchJob).." WHERE steamid='all' AND job = "..sql.SQLStr(team.GetName(ply:Team())))
    end
end)

hook.Add("ShutDown", "luctus_jobtimetracker", function()
    for k,ply in ipairs(player.GetHumans()) do
        if lastChange[ply] then
            LuctusJobtimetrackerSave(ply, team.GetName(ply:Team()))
        end
    end
    LuctusJTTSaveServerTimes()
end)

-- timer.Create("luctus_jobtimetracker",180,0,function()
    -- LuctusJTTSaveServerTimes()
-- end)


--api-like stuff
function LuctusJttHasMinutesPlaytime(ply,job,minutes)
    if tonumber(job) then
        job = team.GetName(job)
        if job == "" then return end
    end
    local res = sql.QueryValue("SELECT job FROM luctus_jobtimetracker WHERE steamid="..sql.SQLStr(ply:SteamID()).." AND job="..sql.SQLStr(job).." AND time>"..(minutes*60))
    if res==false then error(sql.LastError()) end
    if res then return true end
    return false
end

local cachePly = {}
local cacheTimePly = {}
function LuctusJttSendInfo(ply,steamid)
    if not cacheTimePly[steamid] or CurTime() > cacheTimePly[steamid] then
        cacheTimePly[steamid] = CurTime()+180
        cachePly[steamid] = util.TableToJSON(sql.Query("SELECT job,changedToAmount,time FROM luctus_jobtimetracker WHERE steamid="..sql.SQLStr(steamid)) or {})
    end
    net.Start("luctus_jtt")
        net.WriteString(steamid)
        net.WriteString(cachePly[steamid])
    net.Send(ply)
end

hook.Add("PlayerSay","luctus_jobtimetracker",function(ply,text)
    if text == LUCTUS_JOBTIMETRACKER_CMD_ALL then
        LuctusJttSendInfo(ply,"all")
        return
    end
    if text == LUCTUS_JOBTIMETRACKER_CMD then
        LuctusJttSendInfo(ply,ply:SteamID())
        return
    end
    if string.StartsWith(text,LUCTUS_JOBTIMETRACKER_CMD) then
        local steamid = string.Split(text," ")[2]
        if not steamid or steamid == "" then return end
        if not string.match(steamid,"^STEAM_%d:%d:%d+$") then return end
        LuctusJttSendInfo(ply,steamid)
        return
    end
end)

print("[luctus_jobtimetracker] sv loaded")
