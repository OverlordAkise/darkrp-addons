--Luctus Levelsystem
--Made by OverlordAkise

hook.Add("PostGamemodeLoaded","luctus_scpnames",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_levelsystem( steamid TEXT, exp INT, lvl INT )")
    if res == false then
        print("[luctus_levelsystem] SQL ERROR DURING TABLE CREATION!")
        print(sql.LastError())
    end
end)

local plymeta = FindMetaTable("Player")

function plymeta:setLevel(level)
    self:setDarkRPVar("level",level)
end

function plymeta:setXP(xp)
    self:setDarkRPVar("xp",xp)
end

function plymeta:getLevel()
    return self:getDarkRPVar("level")
end

function plymeta:getXP()
    return self:getDarkRPVar("xp")
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
    Luctus_savexp(self)
end

plymeta.AddXP = plymeta.addXP

--internal functions from now on

function Luctus_savexp(ply)
    local res = sql.Query("UPDATE luctus_levelsystem SET exp = "..ply:getXP()..", lvl = "..ply:getLevel().." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        print("[luctus_levelsystem] ERROR DURING SQL UPDATE!")
        print(sql.LastError())
    end
end

function Luctus_loadxp(ply)
    ply:setLevel(1)
    ply:setXP(0)
    local res = sql.QueryRow("SELECT * FROM luctus_levelsystem WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        print("[luctus_levelsystem] ERROR DURING SQL UPDATE!")
        print(sql.LastError())
        return
    end
    if res then
        ply:setLevel(tonumber(res.lvl))
        ply:setXP(tonumber(res.exp))
        print("[luctus_levelsystem] User successfully loaded!")
    else
        local res = sql.Query("INSERT INTO luctus_levelsystem(steamid,exp,lvl) VALUES("..sql.SQLStr(ply:SteamID())..",0,1)")
        if res == false then
            print("[luctus_levelsystem] ERROR DURING SQL INSERT!")
            print(sql.LastError())
            return
        end
        print("[luctus_levelsystem] New user successfully inserted!")
    end
end

hook.Add('PlayerDisconnected', 'LVL_SaveOnDisconnect', function(ply)
    Luctus_savexp(ply)
end)
 
hook.Add('ShutDown', 'LVL_SaveOnShutdown', function()
    for k,v in pairs(player.GetAll()) do
        Luctus_savexp(v)
    end
end)

hook.Add("PlayerInitialSpawn","LVL_InitialLevel",function(ply)
    Luctus_loadxp(ply)
end)

hook.Add("PlayerDeath","LVL_SetLevel",function(ply,inflictor,attacker)
    if attacker:IsPlayer() && IsValid(attacker) then
        attacker:addXP(5)
    end
end)

timer.Create("luctus_lvl_timer",300,0,function()
    for k,v in pairs(player.GetAll()) do
        v:addXP(20)
    end
end)


print("[luctus_levelsystem] SV file loaded!")
