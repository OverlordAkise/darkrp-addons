--Luctus Safezones
--Made by OverlordAkise

util.AddNetworkString("luctus_safezone")
util.AddNetworkString("luctus_safezone_delete")

LUCTUS_SAFEZONE_CACHE = LUCTUS_SAFEZONE_CACHE or {}

hook.Add("EntityTakeDamage", "luctus_safezones_god", function(ply, dmginfo)
    if ply:IsPlayer() and ply.luctusInSafezone then
        dmginfo:SetDamage(0)
    end
end)

hook.Add("PlayerSpawnObject", "luctus_safezones_nospawning", function(ply, model, skinNumber )
  if ply.luctusInSafezone then
    return false
  end
end)

function LuctusSafezoneHandleSpawns()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_safezones(pos_one VARCHAR(200), pos_two VARCHAR(200))")
    if res == false then 
        error(sql.LastError())
    end

    res = sql.Query("SELECT *,rowid FROM luctus_safezones")
    if res == false then
        error(sql.LastError())
    end

    if res and #res > 0 then
        for k,v in pairs(res) do
            p1 = Vector(v["pos_one"])
            p2 = Vector(v["pos_two"])
            local ent = ents.Create("luctus_safezone")
            ent:SetPos( (p1 + p2) / 2 )
            ent.min = p1
            ent.max = p2
            ent:Spawn()
            ent:SetID(v["rowid"])
            ent:SetEID(ent:EntIndex())
            LUCTUS_SAFEZONE_CACHE[v["rowid"]] = ent:EntIndex()
        end
    end
    print("[luctus_safezones] Safezones spawned!")
    hook.Remove("PlayerInitialSpawn", "luctus_safezone_init")
end

hook.Add("PlayerInitialSpawn", "luctus_safezone_init", LuctusSafezoneHandleSpawns)
hook.Add("PostCleanupMap", "luctus_safezone_init", LuctusSafezoneHandleSpawns)

function luctusLeftSafezone(ply)
    ply.luctusInSafezone = false
    net.Start("luctus_safezone")
        net.WriteBool(false)
    net.Send(ply)
end

function luctusEnteredSafezone(ply)
    ply.luctusInSafezone = true
    net.Start("luctus_safezone")
        net.WriteBool(true)
    net.Send(ply)
end

function luctusSaveSafezone(posone, postwo)
    local res = sql.Query("INSERT INTO luctus_safezones VALUES("..sql.SQLStr(posone)..", "..sql.SQLStr(postwo)..")")
    if res == false then 
        error(sql.LastError())
    end
    if res == nil then print("[luctus_safezones] Safezone saved successfully!") end
  
    local ent = ents.Create("luctus_safezone")
    ent:SetPos( (posone + postwo) / 2 )
    ent.min = posone
    ent.max = postwo
    ent:Spawn()

    res = sql.QueryRow("SELECT rowid FROM luctus_safezones ORDER BY rowid DESC limit 1")
    if res == false then 
        error(sql.LastError())
    end
    ent:SetID(tonumber(res["rowid"]))
    ent:SetEID(ent:EntIndex())
    LUCTUS_SAFEZONE_CACHE[res["rowid"]] = ent:EntIndex()
end

net.Receive("luctus_safezone_delete", function(len, ply)
    if not ply:IsAdmin() and not ply:IsSuperAdmin() then return end
    local rowid = net.ReadString()
    if not tonumber(rowid) then return end
    res = sql.QueryRow("DELETE FROM luctus_safezones WHERE rowid = "..rowid)
    if res == false then 
        error(sql.LastError())
    end
    print("[luctus_safezones] Deleted safezone from DB")
    if LUCTUS_SAFEZONE_CACHE[rowid] then
        local ent = ents.GetByIndex(LUCTUS_SAFEZONE_CACHE[rowid])
        if ent and IsValid(ent) then ent:Remove() end
    end
    print("[luctus_safezones] Deleted safezone from map")
end)

print("[luctus_safezones] sv loaded")
