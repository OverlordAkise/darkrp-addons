--Luctus Levelsystem
--Made by OverlordAkise

hook.Add("InitPostEntity","luctus_levelsys_hud_load",function()
    hook.Add("HUDPaint","luctus_levelsystem_hud", function()
        local ply = LocalPlayer()
        local xpNeeded = (ply:getDarkRPVar("xp")*ScrW())/levelReqExp(ply:getDarkRPVar("level"))
        draw.RoundedBox(0, 0, 0, ScrW(), 12, Color(0, 0, 0, 180))
        draw.RoundedBox(0, 0, 0, xpNeeded, 12, Color(0, 0, 0, 200))
        draw.DrawText(ply:getDarkRPVar("xp"),"Default",50,0,Color(255,255,255))
        draw.DrawText(levelReqExp(ply:getDarkRPVar("level")),"Default",ScrW()-10,0,Color(255,255,255),TEXT_ALIGN_RIGHT)
        draw.DrawText("Level: "..ply:getDarkRPVar("level"),"Default",ScrW()/2,0,Color(255,255,255),TEXT_ALIGN_CENTER)
    end)
end)

print("[luctus_levelsystem] cl loaded!")
