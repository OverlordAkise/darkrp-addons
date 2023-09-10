--Luctus Levelsystem
--Made by OverlordAkise

local color_white = Color(255,255,255,255)
local color_bar = Color(0, 0, 0, 180)
local color_xp = Color(0, 0, 0, 200)
local w = ScrW()
local xp = 0
local level = 0
local reqXP = 0
local xpBarLength = 0

hook.Add("DarkRPVarChanged","luctus_levelsystem",function(ply,name,old,new)
    if ply ~= LocalPlayer() then return end
    if name == "xp" then
        xp = new
    end
    if name == "level" then
        level = new
        reqXP = LuctusLevelRequiredXP(level)
        xpBarLength = (xp*w)/reqXP
    end
end)

hook.Add("HUDPaint","luctus_levelsystem_hud", function()
    draw.RoundedBox(0, 0, 0, w, 12, color_bar)
    draw.RoundedBox(0, 0, 0, reqXP, 12, color_xp)
    draw.SimpleText(xp,"Default",50,0,color_white)
    draw.SimpleText(reqXP,"Default",w-10,0,color_white,TEXT_ALIGN_RIGHT)
    draw.SimpleText("Level: "..level,"Default",w/2,0,color_white,TEXT_ALIGN_CENTER)
end)


print("[luctus_levelsystem] cl loaded")
