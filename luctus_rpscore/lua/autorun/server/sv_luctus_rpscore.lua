--Luctus RP-Score
--Made by OverlordAkise

hook.Add("InitPostEntity","luctus_rpscore",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_rpscore(steamid TEXT, steamid64 TEXT, rpscore INT)")
    --SteamID64 to link it to a playername with darkrp_player table
    if res == false then
        error(sql.LastError())
    end
end)

local plymeta = FindMetaTable("Player")

function plymeta:setRPScore(s)
    self:setDarkRPVar("rpscore",s)
end

function plymeta:addRPScore(s)
    self:setDarkRPVar("rpscore",self:getRPScore()+s)
end

function LuctusRPScoreSave(ply)
    local res = sql.Query("UPDATE luctus_rpscore SET rpscore = "..ply:getRPScore().." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
end

function LuctusRPScoreLoad(ply)
    ply:setRPScore(0)
    local res = sql.QueryValue("SELECT rpscore FROM luctus_rpscore WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if res then
        ply:setRPScore(tonumber(res))
    else
        local res = sql.Query("INSERT INTO luctus_rpscore(steamid,steamid64,rpscore) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:SteamID64())..",0)")
        if res == false then
            error(sql.LastError())
        end
        print("[luctus_rpscore] New user successfully inserted!")
    end
end

hook.Add("PlayerDisconnected", "luctus_rpscore", function(ply)
    LuctusRPScoreSave(ply)
end)
 
hook.Add("ShutDown", "luctus_rpscore", function()
    for k,v in ipairs(player.GetHumans()) do
        LuctusRPScoreSave(v)
    end
end)

hook.Add("PlayerInitialSpawn","luctus_rpscore",function(ply)
    LuctusRPScoreLoad(ply)
end)

print("[luctus_rpscore] sv loaded")
