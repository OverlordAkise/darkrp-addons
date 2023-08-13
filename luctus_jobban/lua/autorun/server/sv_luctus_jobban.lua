--Luctus Jobban
--Made by OverlordAkise

--Set to false and jobbans will be ignored
LUCTUS_JOBBAN_IS_ACTIVE = true

hook.Add("InitPostEntity","luctus_jobban",function() --DatabaseInitialized
    MySQLite.query("CREATE TABLE IF NOT EXISTS luctus_jobban(steamid VARCHAR(64), job VARCHAR(255), unbantime INT, UNIQUE(steamid,job))",function()end,function(err,str) error(err) end)
end)

function LuctusJobbanLoad(ply)
    ply.ljobban = {}
    MySQLite.query("SELECT job,unbantime FROM luctus_jobban WHERE steamid = "..sql.SQLStr(ply:SteamID()),function(jobs)
        if not jobs then return end
        if table.Count(jobs) == 0 then return end
        for _, row in pairs(jobs) do
            ply.ljobban[row.job] = tonumber(row.unbantime)
        end
    end,function(err,str) error(err) end)
end

function LuctusJobbanGetBySteamID(steamid,callback)
    MySQLite.query("SELECT job,unbantime FROM luctus_jobban WHERE steamid="..sql.SQLStr(steamid),callback,function(err,str) error(err) end)
end

function LuctusJobbanIsBanned(ply,jobname)
    if not ply.ljobban then return false end
    if ply.ljobban[jobname] then
        if ply.ljobban[jobname] == 0 then return 0 end --infinite ban = 0
        if ply.ljobban[jobname] > os.time() then return ply.ljobban[jobname] end
        ply.ljobban[jobname] = nil
        LuctusJobbanUnban(ply,jobname)
        return false
    end
    return false
end

function LuctusJobbanBan(ply, job, bantime)
    ply.ljobban[job] = os.time()+bantime
    if team.GetName(ply:Team()) == job then
        ply:changeTeam(GAMEMODE.DefaultTeam, true)
    end
    LuctusJobbanBanID(ply:SteamID(), job, bantime, ply)
end

function LuctusJobbanBanID(steamid, job, bantime, ply)
    local newBanTime = os.time()+bantime
    if bantime == 0 then
        newBanTime = 0
    end
    MySQLite.query("REPLACE INTO luctus_jobban(steamid,job,unbantime) VALUES("..sql.SQLStr(steamid)..","..sql.SQLStr(job)..","..(newBanTime)..")",function()
        print("[luctus_jobban]",steamid.." was jobbanned from "..job.." until "..os.date("%H:%M:%S - %d.%m.%Y",newBanTime))
        hook.Run("LuctusJobbanBan",steamid,job,newBanTime,ply)
    end,function(err,str) error(err) end)
end

function LuctusJobbanUnban(ply, job)
    ply.ljobban[job] = nil
    LuctusJobbanUnbanID(ply:SteamID(), job, ply)
end

function LuctusJobbanUnbanID(steamid, job, ply)
    MySQLite.query("DELETE FROM luctus_jobban WHERE steamid="..sql.SQLStr(steamid).." AND job="..sql.SQLStr(job),function()
        print("[luctus_jobban]",steamid.." was jobunbanned from "..job)
        hook.Run("LuctusJobbanUnban",steamid,job,ply)
    end,function(err,str) error(err) end)
end

hook.Add("PlayerInitialSpawn", "luctus_jobban_load", function(ply)
    LuctusJobbanLoad(ply)
end)

hook.Add("playerCanChangeTeam", "luctus_jobban_check", function(ply, job, force)
    if not LUCTUS_JOBBAN_IS_ACTIVE then return end
    if LuctusJobbanIsBanned(ply,team.GetName(job)) then return false, "You are banned from this job!" end
end)

print("[luctus_jobban] sv loaded")
