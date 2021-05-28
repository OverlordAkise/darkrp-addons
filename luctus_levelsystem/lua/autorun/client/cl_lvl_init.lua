--Luctus Levelsystem
--Made by OverlordAkise

local xp = 3
local lvl = 1
local xpneed = Luctus_reqexp(1)

hook.Add("InitPostEntity", "luctus_level_timer", function()
  timer.Create("luctus_levelsystem_update",5,0,function()
    xp = LocalPlayer():GetNWInt("exp",0)
    lvl = LocalPlayer():GetNWInt("lvl",1)
    xpneed = Luctus_reqexp(lvl)
  end)
  hook.Add("HUDPaint","luctus_levelsystem_hud", function()
    draw.RoundedBox(0, 0, 0, ScrW(), 12, Color(0, 0, 0, 180))
    draw.RoundedBox(0, 0, 0, (xp*ScrW())/xpneed, 12, Color(0, 0, 0, 200))
    draw.DrawText(xp,"Default",50,0,Color(255,255,255))
    draw.DrawText(xpneed,"Default",ScrW()-10,0,Color(255,255,255),TEXT_ALIGN_RIGHT)
    draw.DrawText("Level: "..lvl,"Default",ScrW()/2,0,Color(255,255,255),TEXT_ALIGN_CENTER)
  end)
end)



print("[luctus_levelsystem] CL file loaded!")
