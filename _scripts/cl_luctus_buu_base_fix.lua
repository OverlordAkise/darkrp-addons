--Luctus buu-base fix
--Made by OverlordAkise

--The problem was the missing "IsValid(weapon)" check, added it and tidied up the code

hook.Add("InitPostEntity","luctus_buu_base_fix",function()
    hook.Add("CreateMove", "IronIdleMove",function(cmd)
        local ply = LocalPlayer()
        local weapon = ply:GetActiveWeapon()
        if not IsValid(ply) or not IsValid(weapon) then return end
        if not weapon:GetNWBool("Ironsights") then return end
        local ang = cmd:GetViewAngles()

        local ft = FrameTime()
        local BreatTime = RealTime() * .5
        local MoveForce = CalcMoveForce(ply)

        ang.pitch = ang.pitch + math.cos(BreatTime) / MoveForce
        ang.yaw = ang.yaw + math.cos(BreatTime / 2) / MoveForce
        cmd:SetViewAngles(ang)
    end)
    print("[luctus_buu_base_fix] Loaded")
end)

print("[luctus_buu_base_fix] Ready to load")
