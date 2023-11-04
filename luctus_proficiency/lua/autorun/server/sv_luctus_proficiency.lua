--Luctus Weapon Proficiency
--Made by OverlordAkise

LUCTUS_PROFICIENCY_CACHE = LUCTUS_PROFICIENCY_CACHE or {}
local netCache = {}

hook.Add("InitPostEntity","luctus_proficiency",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_proficiency(steamid TEXT, tab TEXT)")
    if res==false then
        error(sql.LastError())
    end
end)

hook.Add("PlayerInitialSpawn","luctus_proficiency",function(ply)
    LUCTUS_PROFICIENCY_CACHE[ply] = {}
    local res = sql.QueryValue("SELECT tab FROM luctus_proficiency WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res==false then ErrorNoHaltWithStack(sql.LastError()) return end
    if res then
        LUCTUS_PROFICIENCY_CACHE[ply] = util.JSONToTable(res)
    else
        res = sql.Query(string.format("INSERT INTO luctus_proficiency(steamid,tab) VALUES(%s,'{}')",sql.SQLStr(ply:SteamID())))
        if res==false then ErrorNoHaltWithStack(sql.LastError()) end
    end
end)

function LuctusProficiencyRaise(ply,wepClass,amount)
    if not LUCTUS_PROFICIENCY_CACHE[ply][wepClass] then
        LUCTUS_PROFICIENCY_CACHE[ply][wepClass] = 0
    end
    local beforeXP = LUCTUS_PROFICIENCY_CACHE[ply][wepClass]
    LUCTUS_PROFICIENCY_CACHE[ply][wepClass] = beforeXP + amount
    LuctusProficiencyCheckLevelup(ply,wepClass,beforeXP,LUCTUS_PROFICIENCY_CACHE[ply][wepClass])
end

function LuctusProficiencyCheckLevelup(ply,wep,before,after)
    local xpReq = LUCTUS_PROFICIENCY_XP_REQUIRED
    if math.floor(before/xpReq) < math.floor(after/xpReq) then
        netCache[ply] = nil
        hook.Run("LuctusProficiencyLevelup",ply,wep,math.floor(after/xpReq),after) --ply,weapon,level,sumXP
    end
end

timer.Create("luctus_proficiency_network",1,0,function()
    for k,ply in ipairs(player.GetHumans()) do
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) then continue end
        if netCache[ply] == wep then continue end
        ply:SetNW2Int("luctus_proficiency",LUCTUS_PROFICIENCY_CACHE[ply][wep:GetClass()])
        netCache[ply] = wep
    end
end)

function LuctusProficiencySave(ply)
    local res = sql.Query(string.format("UPDATE luctus_proficiency SET tab=%s WHERE steamid=%s",sql.SQLStr(util.TableToJSON(LUCTUS_PROFICIENCY_CACHE[ply])),sql.SQLStr(ply:SteamID())))
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end

function LuctusProficiencySaveAll()
    for k,ply in ipairs(player.GetHumans()) do
        LuctusProficiencySave(ply)
    end
end

hook.Add("PlayerDisconnected","luctus_dailyquests",function(ply)
    LUCTUS_PROFICIENCY_CACHE[ply] = nil
    LuctusProficiencySave(ply)
end)

hook.Add("ShutDown","luctus_quests_saveprogress",function()
    LuctusProficiencySaveAll()
end)

timer.Create("luctus_proficiency_persist",300,0,function()
    sql.Begin()
    LuctusProficiencySaveAll()
    sql.Commit()
end)

function LuctusProficiencyGetLevel(ply,wepClass)
    return math.floor((LUCTUS_PROFICIENCY_CACHE[ply] and LUCTUS_PROFICIENCY_CACHE[ply][wepClass] or 0)/LUCTUS_PROFICIENCY_XP_REQUIRED)
end

--XP Givers

hook.Add("PostEntityTakeDamage","luctus_proficiency",function(ent,dmginfo,took)
    if not took or not ent:IsPlayer() then return end
    local att = dmginfo:GetAttacker()
    if not IsValid(att) or not att:IsPlayer() then return end
    local wep = att:GetActiveWeapon()
    if not IsValid(wep) then return end
    LuctusProficiencyRaise(att,wep:GetClass(),LUCTUS_PROFICIENCY_XP_HIT) 
end)

hook.Add("PlayerDeath", "luctus_proficiency", function(victim,inf,attacker)
    if not attacker:IsPlayer() then return end
    local wep = attacker:GetActiveWeapon()
    if not IsValid(wep) then return end
    LuctusProficiencyRaise(attacker,wep:GetClass(),LUCTUS_PROFICIENCY_XP_KILL)
end)

print("[luctus_proficiency] sv loaded")
