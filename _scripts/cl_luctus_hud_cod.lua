--Luctus HUD COD-Style
--Made by OverlordAkise

--WARNING:You need a levelsystem with a ply:getLevel() function for this to work!
--This is a "COD Warzone"-like HUD meant for PVP servers
--Missing features: Wanted/License/Arrest/Lockdown/Agenda display

surface.CreateFont( "LucidHUDFont", { font = "Verdana", size = 18, weight = 0 } )

local noDraw = {
    ["DarkRP_HUD"] = true,
    ["CHudBattery"] = true,
    ["CHudHealth"] = true,
    ["DarkRP_Hungermod"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudAmmo"] = true,
}

hook.Add("HUDShouldDraw", "luctus_hud_hide", function(vs)
    if noDraw[vs] then return false end
end)

local scrw = ScrW()
local scrh = ScrH()
local startX = 15
local startY = scrh-185
local baseWidth = 320
local baseHeight = 90

local barX = startX+100
local barY = startY+30
local maxBarSize = 250
local barHeight = 10

local featureCol = Color(0, 195, 165)
local backgroundCol = Color(56,56,56,255)
local armorCol = Color(30, 144, 255)

local mainBoxQuadStructure = {
    texture = surface.GetTextureID("vgui/gradient-l"),
    color = Color(0,0,0,255),
    x = startX,
    y = startY,
    w = baseWidth+100,
    h = baseHeight,
}
local weaponSmallQuadStructure = {
    texture = surface.GetTextureID("vgui/gradient-r"),
    color = Color(0,0,0,255),
    x = scrw-245,
    y = startY,
    w = 200,
    h = 30,
}
local weaponBigQuadStructure = {
    texture = surface.GetTextureID("vgui/gradient-r"),
    color = Color(0,0,0,255),
    x = scrw-245,
    y = startY,
    w = 200,
    h = 70,
}

hook.Add("HUDPaint", "luctus_hud", function()
    local ply = LocalPlayer()
    --MainBox
    draw.TexturedQuad(mainBoxQuadStructure)
    --Name and job
    draw.SimpleText(ply:Nick().." (Lv."..ply:getLevel()..")", "LucidHUDFont", startX+15, startY + 14, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    --Armor
    draw.RoundedBox(0,startX+15,barY,maxBarSize,barHeight,backgroundCol)
    draw.RoundedBox(0,startX+15,barY,math.Clamp((ply:Armor()*maxBarSize)/ply:GetMaxArmor(),0,maxBarSize),barHeight,armorCol)
    --HP
    draw.RoundedBox(0,startX+15,barY+18,maxBarSize,barHeight,backgroundCol)
    draw.RoundedBox(0,startX+15,barY+18,math.Clamp((ply:Health()*maxBarSize)/ply:GetMaxHealth(),0,maxBarSize),barHeight,color_white)
    --Money
    draw.SimpleText(DarkRP.formatMoney(ply:getDarkRPVar("money")), "LucidHUDFont",startX+15,barY+32,color_white,TEXT_ALIGN_LEFT)
    --weapon
    local wep = ply:GetActiveWeapon()
    if wep:IsValid() then
        local wep_name = wep:GetPrintName() or wep:GetClass() or "Unbekannt"
        local ammo_type = wep:GetPrimaryAmmoType()
        if ammo_type == -1 then
            draw.TexturedQuad(weaponSmallQuadStructure)
            draw.SimpleText(wep_name, "LucidHUDFont", scrw-startX-35, startY+5, color_white, TEXT_ALIGN_RIGHT)
        else
            local clip = wep:Clip1()
            local maxclip = wep:GetMaxClip1()
            local ammoLength = math.Clamp((wep:Clip1()*maxBarSize)/wep:GetMaxClip1(),0,maxBarSize)
            draw.TexturedQuad(weaponBigQuadStructure)
            draw.SimpleText(wep_name, "LucidHUDFont", scrw-startX-35, startY+5, color_white, TEXT_ALIGN_RIGHT)
            draw.SimpleText(clip.."/"..maxclip.." ("..ply:GetAmmoCount(ammo_type)..")", "LucidHUDFont", scrw-startX-35, startY+45, color_white, TEXT_ALIGN_RIGHT)
            draw.RoundedBox(0,scrw-50-maxBarSize,startY+30,maxBarSize,barHeight,backgroundCol)
            draw.RoundedBox(0,scrw-50-ammoLength,startY+30,ammoLength,barHeight,color_white)
        end
    end
end)

print("[luctus_hud_cod] cl loaded!")
