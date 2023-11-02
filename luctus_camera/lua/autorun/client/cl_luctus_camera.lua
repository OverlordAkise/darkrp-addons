--Luctus Camera
--Made by OverlordAkise

hook.Add("ShouldDrawLocalPlayer","luctus_camera",function(ply)
    if not IsValid(ply) then return end
    if ply ~= LocalPlayer() then return end
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_luctus_camera_tablet" and wep:GetClass() ~= "weapon_luctus_camera" then return end
    return true
end)

print("[luctus_camera] cl loaded")
