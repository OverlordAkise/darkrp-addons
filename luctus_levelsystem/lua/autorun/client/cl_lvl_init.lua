--Luctus Levelsystem
--Made by OverlordAkise

local color_white = Color(255,255,255,255)
local color_bar = Color(0, 0, 0, 180)
local color_xp = Color(0, 0, 0, 200)

hook.Add("InitPostEntity","luctus_levelsys_hud_load",function()
    hook.Add("HUDPaint","luctus_levelsystem_hud", function()
        local ply = LocalPlayer()
        local w = ScrW()
        local xpNeeded = (ply:getDarkRPVar("xp")*w)/levelReqExp(ply:getDarkRPVar("level"))
        draw.RoundedBox(0, 0, 0, w, 12, color_bar)
        draw.RoundedBox(0, 0, 0, xpNeeded, 12, color_xp)
        draw.DrawText(ply:getDarkRPVar("xp"),"Default",50,0,color_white)
        draw.DrawText(levelReqExp(ply:getDarkRPVar("level")),"Default",w-10,0,color_white,TEXT_ALIGN_RIGHT)
        draw.DrawText("Level: "..ply:getDarkRPVar("level"),"Default",w/2,0,color_white,TEXT_ALIGN_CENTER)
    end)
end)

print("[luctus_levelsystem] cl loaded")
