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
    if not ply.refundweps or table.IsEmpty(ply.refundweps) then return end
    for k,wepclass in ipairs(ply.refundweps) do
        ply:Give(wepclass)
    end
end

hook.Add("PlayerDeath","luctus_weprefund",function(ply)
    ply.refundweps = {}
    PrintTable(ply:GetWeapons())
    for k,wep in ipairs(ply:GetWeapons()) do
        table.insert(ply.refundweps,wep:GetClass())
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
    if not target.refundweps or table.IsEmpty(target.refundweps) then
        DarkRP.notify(ply,1,5,"This player does not have refundable weapons!")
        return
    end
    LuctusWeaponRefund(target)
    DarkRP.notify(ply,0,5,"Gave "..target:Nick().." back his weapons")
end)

print("[luctus_weprefund] sv loaded")
