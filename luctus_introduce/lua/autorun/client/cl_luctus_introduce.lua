--Luctus Introduce
--Made by OverlordAkise

LUCTUS_INTRODUCE_CACHE = LUCTUS_INTRODUCE_CACHE or {}

if LUCTUS_INTRODUCE_USE_WHEEL then
    hook.Add("LuctusWheelAdd","luctus_introduce",function()
        LuctusWheelAdd("player","Introduce",function()
            local ent = LocalPlayer():GetEyeTrace().Entity
            if not IsValid(ent) or not ent:IsPlayer() then return end
            net.Start("luctus_introduce")
                net.WriteEntity(ent)
            net.SendToServer()
        end)
    end)
end

net.Receive("luctus_introduce",function()
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    
    LuctusIntroduceSave(ply)
end)

function LuctusIntroduceSave(ply)
    local steamid = ply:SteamID()
    if LUCTUS_INTRODUCE_CACHE[steamid] then return end
    
    LUCTUS_INTRODUCE_CACHE[steamid] = true
    local res = sql.Query("REPLACE INTO luctus_introduce(steamid,metDate) VALUES("..sql.SQLStr(steamid)..",datetime('now','localtime'))")
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
    hook.Run("LuctusIntroduced",ply,LocalPlayer())
    notification.AddLegacy(ply:Nick().." introduced themself",0,3)
end

hook.Add("InitPostEntity","luctus_introduce",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_introduce(steamid TEXT UNIQUE, metDate TEXT)")
    if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
    
    local res = sql.Query("SELECT * FROM luctus_introduce")
    if res == false then ErrorNoHaltWithStack(sql.LastError()) return end
    if not res or not res[1] then return end
    for k,row in ipairs(res) do
        LUCTUS_INTRODUCE_CACHE[row.steamid] = true
    end
    LUCTUS_INTRODUCE_CACHE[LocalPlayer():SteamID()] = true
    print("[luctus_introduce] known players loaded, count:",#res)
end)

local plymeta = FindMetaTable("Player")
if LUCTUS_INTRODUCE_OVERWRITE_NAME then
    hook.Add("InitPostEntity","luctus_introduce_nick_overwrite",function()
    timer.Simple(3,function()
        plymeta.liOldNick = plymeta.Nick
        function plymeta:Nick()
            if not LUCTUS_INTRODUCE_CACHE[self:SteamID()] then return LUCTUS_INTRODUCE_UNKNOWN_NAME end
            return self:liOldNick()
        end
    end)
    end)
else
    function plymeta:IName()
        if not LUCTUS_INTRODUCE_CACHE[self:SteamID()] then return LUCTUS_INTRODUCE_UNKNOWN_NAME end
        return self:Nick()
    end
end

print("[luctus_introduce] cl loaded")
