--Luctus Hitmarker
--Made by OverlordAkise

local lasthitmarker = nil
hook.Add("ScalePlayerDamage","luctus_hitmarker",function(ply,hitgorup,dmginfo)
    local me = dmginfo:GetAttacker()
    if me == LocalPlayer() then
        lasthitmarker = SysTime()
        --surface.PlaySound("physics/flesh/flesh_impact_bullet4.wav")
        --Sounds while shooting are barely hearable
    end
end)

hook.Add("HUDPaint","luctus_hitmarker",function()
    if lasthitmarker then
        local w = ScrW()/2
        local h = ScrH()/2
        local bright = 255-(SysTime()-lasthitmarker)*200
        surface.SetDrawColor(255,255,255,bright)
        surface.DrawLine(w-10, h-10, w-5, h-5)
        surface.DrawLine(w+10, h-10, w+5, h-5)
        surface.DrawLine(w-10, h+10, w-5, h+5)
        surface.DrawLine(w+10, h+10, w+5, h+5)
        if bright <= 0 then lasthitmarker = nil end
    end
end)

print("[luctus_hitmarker] cl loaded")
