--Luctus Levelsystem
--Made by OverlordAkise

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
    if LUCTUS_XP_DISABLE_WHILE_AFK and self:getDarkRPVar("AFK",false) then return end
    local getxp = amount
    local mult = hook.Run("LuctusLevelMultXP",self,amount)
    if tonumber(mult) then
        getxp = getxp*mult
    end
    getxp = getxp*LUCTUS_LEVEL_XP_MULTIPLIER
    
    local curXP = self:getXP() + getxp
    local curLevel = self:getLevel()
    local oldLevel = curLevel
    DarkRP.notify(self,0,5,"You received "..getxp.." XP!")
    while curXP >= LuctusLevelRequiredXP(curLevel)  do
        curXP = curXP - LuctusLevelRequiredXP(curLevel)
        curLevel = curLevel + 1
        DarkRP.notify(self,0,5,"You reached Lv."..curLevel.."!")
    end
    self:setXP(curXP)
    self:setLevel(curLevel)
    LuctusLevelSave(self)
    hook.Run("LuctusLevelGained",self,getxp,curLevel-oldLevel)
end

plymeta.AddXP = plymeta.addXP

--internal functions from now on

local function sSID(ply)
    if LUCTUS_XP_PERJOB then
        return sql.SQLStr(ply:SteamID()..team.GetName(ply:Team()))
    else
        return sql.SQLStr(ply:SteamID())
    end
end

function LuctusLevelSave(ply)
    local res = sql.Query("UPDATE luctus_levelsystem SET exp = "..ply:getXP()..", lvl = "..ply:getLevel().." WHERE steamid = "..sSID(ply))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
end

function LuctusLevelLoad(ply)
    ply:setLevel(1)
    ply:setXP(0)
    local res = sql.QueryRow("SELECT * FROM luctus_levelsystem WHERE steamid = "..sSID(ply))
    if res == false then
        error(sql.LastError())
    end
    if res then
        ply:setLevel(tonumber(res.lvl))
        ply:setXP(tonumber(res.exp))
        print("[luctus_levelsystem] User successfully loaded!")
    else
        local res = sql.Query("INSERT INTO luctus_levelsystem(steamid,steamid64,exp,lvl) VALUES("..sSID(ply)..","..sql.SQLStr(ply:SteamID64())..",0,1)")
        if res == false then
            error(sql.LastError())
        end
        print("[luctus_levelsystem] New user successfully inserted!")
    end
end

hook.Add("OnPlayerChangedTeam", "luctus_levelsystem", function(ply,before,after)
    if LUCTUS_XP_PERJOB then
        LuctusLevelLoad(ply)
    end
end)

hook.Add("PlayerDisconnected", "luctus_levelsystem", function(ply)
    LuctusLevelSave(ply)
    timer.Remove("levelload_"..ply:SteamID())
end)
 
hook.Add("ShutDown", "luctus_levelsystem", function()
    for k,v in pairs(player.GetHumans()) do
        LuctusLevelSave(v)
    end
end)

hook.Add("PlayerInitialSpawn","luctus_levelsystem",function(ply)
    if not LUCTUS_XP_PERJOB then
        LuctusLevelLoad(ply)
    else
        timer.Create("levelload_"..ply:SteamID(),1,0,function()
            if not IsValid(ply) then
                timer.Remove("levelload_"..ply:SteamID())
                return
            end
            if ply:Team() == 0 then return end
            LuctusLevelLoad(ply)
            timer.Remove("levelload_"..ply:SteamID())
        end)
    end
end)

hook.Add("PlayerDeath","luctus_levelsystem",function(ply,inflictor,attacker)
    if attacker:IsPlayer() and IsValid(attacker) then
        attacker:addXP(LUCTUS_XP_KILL)
    end
end)

timer.Create("luctus_levelsystem",LUCTUS_XP_TIMER,0,function()
    for k,v in ipairs(player.GetAll()) do
        v:addXP(LUCTUS_XP_TIMER_XP)
    end
end)

--Restrict job changes
if LUCTUS_LEVEL_JOBRESTRICT then
    hook.Add("playerCanChangeTeam","luctus_levelsystem",function(ply,newTeam,force)
        if force then return end
        local jobTable = RPExtraTeams[newTeam]
        if jobTable and jobTable.level and ply:getLevel() < jobTable.level then
            return false, "Level too low!"
        end
    end)
end

print("[luctus_levelsystem] sv loaded")
