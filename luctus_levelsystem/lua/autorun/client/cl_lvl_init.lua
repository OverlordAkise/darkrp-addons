--Luctus Levelsystem
--Made by OverlordAkise

hook.Add("HUDPaint","luctus_levelsystem_hud", function()
    local ply = LocalPlayer()
    local xpNeeded = (ply:getDarkRPVar("xp")*ScrW())/levelReqExp(ply:getDarkRPVar("level"))
    draw.RoundedBox(0, 0, 0, ScrW(), 12, Color(0, 0, 0, 180))
    draw.RoundedBox(0, 0, 0, xpNeeded, 12, Color(0, 0, 0, 200))
    draw.DrawText(ply:getDarkRPVar("xp"),"Default",50,0,color_white)
    draw.DrawText(levelReqExp(ply:getDarkRPVar("level")),"Default",ScrW()-10,0,color_white,TEXT_ALIGN_RIGHT)
    draw.DrawText("Level: "..ply:getDarkRPVar("level"),"Default",ScrW()/2,0,color_white,TEXT_ALIGN_CENTER)
end)

print("[luctus_levelsystem] cl loaded!")
