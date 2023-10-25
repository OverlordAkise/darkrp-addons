--Luctus Temprank
--Made by OverlordAkise

LUCTUS_TEMPRANK_CHECKINTERVAL = 120

LUCTUS_TEMPRANK_TIMES = LUCTUS_TEMPRANK_TIMES or {}

hook.Add("InitPostEntity","luctus_temprank",function(ply)
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_temprank(steamid VARCHAR(50), rank VARCHAR(250), duration INT, previousrank VARCHAR(250))")
    if res == false then
        error(sql.LastError())
    end
end)

function LuctusTemprankLoad(ply)
    local res = sql.QueryRow("SELECT * FROM luctus_temprank WHERE steamid="..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if not res then return end
    LuctusTemprankGive(ply,res.rank,res.duration,res.previousrank)
end

hook.Add("PlayerInitialSpawn","luctus_temprank",LuctusTemprankLoad)


function LuctusTemprankActivateSteamID(steamid,rankname,duration,oldRank,admin)
    local res = sql.Query("DELETE FROM luctus_temprank WHERE steamid="..sql.SQLStr(steamid))
    if res == false then
        error(sql.LastError())
    end
    res = sql.Query(string.format("INSERT INTO luctus_temprank VALUES(%s,%s,%d,%s)",
        sql.SQLStr(steamid),
        sql.SQLStr(rankname),
        duration,
        sql.SQLStr(oldRank)
    ))
    if res == false then
        error(sql.LastError())
    end
    hook.Run("LuctusTemprankActivated",steamid,rankname,duration,oldRank,admin)
end

function LuctusTemprankActivate(ply,rankname,duration,oldRank,admin)
    LuctusTemprankGive(ply,rankname,duration,oldRank,admin)
    LuctusTemprankActivateSteamID(ply:SteamID(),rankname,duration,oldRank,admin)
end

function LuctusTemprankHasActive(ply)
    return LUCTUS_TEMPRANK_TIMES[ply:SteamID()]
end

function LuctusTemprankUpdate(steamid,rank,newtime)
    local res = sql.Query("UPDATE luctus_temprank SET duration = "..newtime.." WHERE steamid="..sql.SQLStr(steamid).." AND rank="..sql.SQLStr(rank))
    if res == false then
        error(sql.LastError())
    end
    LUCTUS_TEMPRANK_TIMES[steamid][2] = newtime
end

function LuctusTemprankGive(ply,rankname,duration,oldRank,admin)
    local steamid = ply:SteamID()
    duration = tonumber(duration)
    if not duration then return end
    LUCTUS_TEMPRANK_TIMES[steamid] = {
        rankname,
        duration,
        oldRank,
    }
    LuctusTemprankSetRank(ply,rankname,admin)
    timer.Create("luctus_temprank_"..steamid,LUCTUS_TEMPRANK_CHECKINTERVAL,0,function()
        if not LUCTUS_TEMPRANK_TIMES[steamid] then return end
        local timeRemaining = LUCTUS_TEMPRANK_TIMES[steamid][2]-LUCTUS_TEMPRANK_CHECKINTERVAL
        if timeRemaining <= 0 then
            LuctusTemprankRemove(ply)
            return
        end
        LuctusTemprankUpdate(steamid,rankname,timeRemaining)
    end)
end

function LuctusTemprankSetRank(ply,rankname,admin)
    if not admin then admin = Entity(0) end
    ulx.adduser(admin,ply,rankname)
end

function LuctusTemprankRemove(ply,admin)
    local steamid = ply:SteamID()
    if not LUCTUS_TEMPRANK_TIMES[steamid] then return end
    local oldRank = LUCTUS_TEMPRANK_TIMES[steamid][3]
    timer.Remove("luctus_temprank_"..steamid)
    LuctusTemprankSetRank(ply,oldRank,admin)
    LUCTUS_TEMPRANK_TIMES[steamid] = nil
    LuctusTemprankRemoveSteamID(steamid,admin)
end

function LuctusTemprankRemoveSteamID(steamid,admin)
    local res = sql.Query("DELETE FROM luctus_temprank WHERE steamid="..sql.SQLStr(steamid))
    if res == false then
        error(sql.LastError())
    end
    hook.Run("LuctusTemprankRemoved",ply,admin)
end

print("[luctus_temprank] sv loaded")
