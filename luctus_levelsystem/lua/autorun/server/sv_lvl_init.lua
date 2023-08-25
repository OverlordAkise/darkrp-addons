--Luctus Levelsystem
--Made by OverlordAkise

-- CONFIG

LUCTUS_XP_TIMER = 300 --seconds, interval for giving XP
LUCTUS_XP_TIMER_XP = 20 --how many XP every interval
LUCTUS_XP_KILL = 5 --how many XP per player kill

-- CONFIG END

hook.Add("PostGamemodeLoaded","luctus_levelsystem",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_levelsystem( steamid TEXT, steamid64 TEXT, exp INT, lvl INT )")
    --SteamID64 to link it to a playername with darkrp_player table
    if res == false then
        error(sql.LastError())
    end
end)

local plymeta = FindMetaTable("Player")

function plymeta:setLevel(level)
    self:setDarkRPVar("level",level)
end

function plymeta:setXP(xp)
    self:setDarkRPVar("xp",xp)
end

function plymeta:addXP(amount)
    local curXP = self:getXP() + amount
    local curLevel = self:getLevel()
    DarkRP.notify(self,0,5,"You received "..amount.." XP!")
    while curXP >= levelReqExp(curLevel)  do
        curXP = curXP - levelReqExp(curLevel)
        curLevel = curLevel + 1
        DarkRP.notify(self,0,5,"You reached Lv."..curLevel.."!")
    end
    self:setXP(curXP)
    self:setLevel(curLevel)
    LuctusLevelSave(self)
end

plymeta.AddXP = plymeta.addXP

--internal functions from now on

function LuctusLevelSave(ply)
    local res = sql.Query("UPDATE luctus_levelsystem SET exp = "..ply:getXP()..", lvl = "..ply:getLevel().." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
end

function LuctusLevelLoad(ply)
    ply:setLevel(1)
    ply:setXP(0)
    local res = sql.QueryRow("SELECT * FROM luctus_levelsystem WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if res then
        ply:setLevel(tonumber(res.lvl))
        ply:setXP(tonumber(res.exp))
        print("[luctus_levelsystem] User successfully loaded!")
    else
        local res = sql.Query("INSERT INTO luctus_levelsystem(steamid,steamid64,exp,lvl) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(ply:SteamID64())..",0,1)")
        if res == false then
            error(sql.LastError())
        end
        print("[luctus_levelsystem] New user successfully inserted!")
    end
end

hook.Add("PlayerDisconnected", "luctus_levelsystem", function(ply)
    LuctusLevelSave(ply)
end)
 
hook.Add("ShutDown", "luctus_levelsystem", function()
    for k,v in pairs(player.GetHumans()) do
        LuctusLevelSave(v)
    end
end)

hook.Add("PlayerInitialSpawn","luctus_levelsystem",function(ply)
    LuctusLevelLoad(ply)
end)

hook.Add("PlayerDeath","luctus_levelsystem",function(ply,inflictor,attacker)
    if attacker:IsPlayer() && IsValid(attacker) then
        attacker:addXP(LUCTUS_XP_KILL)
    end
end)

timer.Create("luctus_levelsystem",LUCTUS_XP_TIMER,0,function()
    for k,v in pairs(player.GetAll()) do
        v:addXP(LUCTUS_XP_TIMER_XP)
    end
end)

print("[luctus_levelsystem] sv loaded")
