--Luctus Levelsystem
--Made by OverlordAkise

local color_white = Color(255,255,255,255)
local color_bar = Color(0, 0, 0, 180)
local color_xp = Color(70, 70, 70, 250)

local w = ScrW()
local h = ScrH()
local curxp = 0
local level = 1
local reqXP = 10
local xpBarLength = 0
hook.Add("DarkRPVarChanged","luctus_levelsystem",function(ply,name,old,new)
    if ply ~= LocalPlayer() then return end
    if name == "xp" then
        curxp = new
        xpBarLength = (curxp*w)/reqXP
    end
    if name == "level" then
        level = new
        reqXP = LuctusLevelRequiredXP(level)
    end
end)

if not LUCTUS_LEVEL_SHOW_TAB then
    hook.Add("HUDPaint","luctus_levelsystem_hud", function()
        draw.RoundedBox(0, 0, 0, w, 12, color_bar)
        draw.RoundedBox(0, 0, 0, xpBarLength, 12, color_xp)
        draw.SimpleText(curxp,"Default",50,0,color_white)
        draw.SimpleText(reqXP,"Default",w-10,0,color_white,TEXT_ALIGN_RIGHT)
        draw.SimpleText("Level: "..level,"Default",w/2,0,color_white,TEXT_ALIGN_CENTER)
    end)
else
    hook.Add("HUDPaint","luctus_levelsystem_hud", function()
        if not input.IsButtonDown(KEY_TAB) then return end
        draw.RoundedBox(0, w/4-2, h/12-2, w/2+4, 32+4, color_bar)
        draw.RoundedBox(0, w/4, h/12, xpBarLength, 32, color_xp)
        draw.SimpleText(curxp,"DermaDefault",w/4+10,h/12+9,color_white)
        draw.SimpleText(reqXP,"DermaDefault",w/2+w/4-5,h/12+9,color_white,TEXT_ALIGN_RIGHT)
        draw.SimpleText("Level: "..level,"DermaDefault",w/2,h/12+9,color_white,TEXT_ALIGN_CENTER)
    end)
end

print("[luctus_levelsystem] cl loaded")
