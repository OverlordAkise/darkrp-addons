--Luctus Statistics
--Made by OverlordAkise

LUCTUS_STATISTICS_COMMAND = "!stats"


util.AddNetworkString("luctus_statistics")

hook.Add("PostGamemodeLoaded","luctus_statistics_init_db",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_stat_jobs( jobname TEXT, changedToAmount BIGINT, playtime BIGINT )")
    print("[luctus_statistics] Database initialized!")
end)

hook.Add("postLoadCustomDarkRPItems","luctus_statistics_init_jobs",function()
    local dbJobs = sql.Query("SELECT * FROM luctus_stat_jobs")
    local alreadyExistJobs = {}
    if not istable(dbJobs) then dbJobs = {} end
    for k,v in pairs(dbJobs) do
        alreadyExistJobs[v.jobname] = true
    end
    for k,v in pairs(RPExtraTeams) do
        if not alreadyExistJobs[v.name] then
            sql.Query("INSERT INTO luctus_stat_jobs VALUES("..sql.SQLStr(v.name)..",0,0)")
            print("[luctus_statistics] New job added: "..v.name)
        else
            --print("[luctus_statistics] Job already existed in db: "..v.name)
        end
    end
end)

hook.Add("PlayerInitialSpawn","luctus_statistics",function(ply)
    ply.switchJob = CurTime()
end)

hook.Add("OnPlayerChangedTeam","luctus_statistics",function(ply, before, after)
    local beforeName = team.GetName(before)
    local afterName = team.GetName(after)
    local res = sql.Query("UPDATE luctus_stat_jobs SET changedToAmount = changedToAmount + 1 WHERE jobname = "..sql.SQLStr(afterName))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    res = sql.Query("UPDATE luctus_stat_jobs SET playtime = playtime + "..math.Round(CurTime()-ply.switchJob).." WHERE jobname = "..sql.SQLStr(beforeName))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    ply.switchJob = CurTime()
end)

hook.Add("PlayerDisconnect","luctus_statistics",function(ply)
    if ply.switchJob then
        sql.Query("UPDATE luctus_stat_jobs SET playtime = playtime + "..math.Round(CurTime()-ply.switchJob).." WHERE jobname = "..sql.SQLStr(team.GetName(ply:Team())))
    end
end)

timer.Create("luctus_statistics_job_time",30,0,function()
    luctusStatSaveAll()
end)

hook.Add("ShutDown","luctus_statistics",function()
    --extra prints to see if it hangs in this function
    print("[luctus_statistics] Saving all players...")
    luctusStatSaveAll()
    print("[luctus_statistics] Done saving everything.")
end)

function luctusStatSaveAll()
    local ss = SysTime()
    local jobTimes = {}
    for k,ply in pairs(player.GetAll()) do
        if not ply.switchJob then continue end
        if not jobTimes[team.GetName(ply:Team())] then jobTimes[team.GetName(ply:Team())] = 0 end
        jobTimes[team.GetName(ply:Team())] = jobTimes[team.GetName(ply:Team())] + math.Round(CurTime()-ply.switchJob)
        ply.switchJob = CurTime()
    end
    for jobname,playtime in pairs(jobTimes) do
        sql.Query("UPDATE luctus_stat_jobs SET playtime = playtime + "..playtime.." WHERE jobname = "..sql.SQLStr(jobname))
    end
    --print("[luctus_statistics] Saved all players in "..(SysTime()-ss).."s")
end


local statcachetime = 0
local statcache = {}
hook.Add("PlayerSay","luctus_statistics",function(ply,text,team)
    if text == LUCTUS_STATISTICS_COMMAND then
        if CurTime() > statcachetime then
            statcachetime = CurTime()+60
            statcache = util.TableToJSON(sql.Query("SELECT * FROM luctus_stat_jobs"))
        end
        net.Start("luctus_statistics")
            net.WriteString(statcache)
        net.Send(ply)
        return ""
    end
end)

print("[luctus_statistics] sv loaded!")
