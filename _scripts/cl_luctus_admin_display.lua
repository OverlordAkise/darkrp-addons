--Luctus Admin Display
--Made by OverlordAkise

--This shows you a message in bright red at the bottom of your screen
-- whenever you are noclipping / in godmode / cloaked.

local NOCLIP_MSG = "YOU ARE IN NOCLIP"
local GODMODE_MSG = "YOU ARE IN GODMODE"
local CLOAK_MSG = "YOU ARE CLOAKED"

--CONFIG END

surface.CreateFont("LuctusAdminDisplay", { font = "Arial", size = 24, weight = 9001 })



local color_red = Color(255,0,0,255)

hook.Add("HUDPaint", "luctus_admin_display", function()
    local ply = LocalPlayer()
    local scrw = ScrW()/2
    local scrh = ScrH()/1.15
    if not IsValid(ply) then return end
    if ply:HasGodMode() then
        draw.SimpleText(GODMODE_MSG,"LuctusAdminDisplay",scrw,scrh,color_red,TEXT_ALIGN_CENTER)
    end
    if ply:GetColor().a < 255 then
        draw.SimpleText(CLOAK_MSG,"LuctusAdminDisplay",scrw,scrh+24,color_red,TEXT_ALIGN_CENTER)
    end
    if ply:GetMoveType() == 8 then
        draw.SimpleText(NOCLIP_MSG,"LuctusAdminDisplay",scrw,scrh+48,color_red,TEXT_ALIGN_CENTER)
    end
end)

print("[luctus_admin_display] cl loaded")
