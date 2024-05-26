--Luctus Weapon Refund
--Made by OverlordAkise

--Gives the player you are looking at his weapons before his death back

--Which ranks are allowed to use the chat commands
LUCTUS_WEPREFUND_ADMINRANKS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
    ["supporter"] = true,
}

function LuctusWeaponRefund(ply)
    if not LUCTUS_WEPREFUND_CACHE[ply] or table.IsEmpty(LUCTUS_WEPREFUND_CACHE[ply]) then return end
    local weapons = table.remove(LUCTUS_WEPREFUND_CACHE[ply])
    for k,wepclass in ipairs(weapons) do
        ply:Give(wepclass)
    end
    hook.Run("LuctusWeprefund",ply,#weapons)
end

hook.Add("PlayerDeath","luctus_weprefund",function(ply)
    if not LUCTUS_WEPREFUND_CACHE[ply] then
        LUCTUS_WEPREFUND_CACHE[ply] = {}
    end
    local weapons = {}
    for k,wep in ipairs(ply:GetWeapons()) do
        table.insert(weapons,wep:GetClass())
    end
    table.insert(LUCTUS_WEPREFUND_CACHE[ply],weapons)
    if #LUCTUS_WEPREFUND_CACHE[ply] > 10 then
        table.remove(LUCTUS_WEPREFUND_CACHE[ply],1)
    end
end)

LUCTUS_WEPREFUND_CACHE = LUCTUS_WEPREFUND_CACHE or {}
timer.Create("luctus_weprefund_cache",180,0,function()
    for ply,v in pairs(LUCTUS_WEPREFUND_CACHE) do
        if not IsValid(ply) then LUCTUS_WEPREFUND_CACHE[ply] = nil end
    end
end)

hook.Add("PlayerSay","luctus_weprefund",function(ply,text)
    if text == "!refundmyweapons" and LUCTUS_WEPREFUND_ADMINRANKS[ply:GetUserGroup()] then LuctusWeaponRefund(ply) end
    if text ~= "!refundweapons" then return end
    if not LUCTUS_WEPREFUND_ADMINRANKS[ply:GetUserGroup()] then return end
    local target = ply:GetEyeTrace().Entity
    if not IsValid(target) or not target:IsPlayer() then
        DarkRP.notify(ply,1,5,"You are not looking at a player!")
        return
    end
    if not LUCTUS_WEPREFUND_CACHE[target] or table.IsEmpty(LUCTUS_WEPREFUND_CACHE[target]) then
        DarkRP.notify(ply,1,5,"This player does not have refundable weapons!")
        return
    end
    LuctusWeaponRefund(target)
    DarkRP.notify(ply,0,5,"Gave "..target:Nick().." back his weapons")
end)

print("[luctus_weprefund] sv loaded")
