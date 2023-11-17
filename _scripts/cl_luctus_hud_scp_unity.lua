--Luctus SCP Unity HUD
--Made by OverlordAkise

--Missing features: Wanted/License/Arrest/Lockdown/Agenda display

surface.CreateFont("LucidHUDFont",{font="Verdana",size=18,weight=0})

local health_icon = Material( "icon16/heart.png" )
local shield_icon = Material( "icon16/shield.png" )

local function CreateImageIcon(icon, x, y, col, val)
    surface.SetDrawColor(col)
    surface.SetMaterial(icon)
    if val then
        surface.SetDrawColor(color_white)
    end
    surface.DrawTexturedRect(x, y, 16, 16)
end

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
local startX = 90
local startY = scrh-155

local barX = startX+100
local barY = startY+30
local maxBarSize = 350
local barHeight = 20

local hpCol = Color(10,100,10)
local armorCol = Color(40,40,190)
local wepCol = Color(200,200,255)
local backgroundCol = Color(56,56,56,255)

hook.Add("HUDPaint", "luctus_hud", function()
    local ply = LocalPlayer()
    --HP
    CreateImageIcon(health_icon, startX, startY, hpCol)
    draw.RoundedBox(0,startX+19,startY,maxBarSize,barHeight,color_black)
    draw.RoundedBox(0,startX+19+1,startY+1,maxBarSize-2,barHeight-2,backgroundCol)
    draw.RoundedBox(0,startX+19+1,startY+1,math.Clamp((ply:Health()*maxBarSize)/ply:GetMaxHealth(),0,maxBarSize)-2,barHeight-2,hpCol)
    draw.SimpleText(ply:Health(), "LucidHUDFont",startX+19+5,startY+1,color_white,TEXT_ALIGN_LEFT)
    --Armor
    CreateImageIcon(shield_icon, startX, startY+35, armorCol)
    draw.RoundedBox(0,startX+19,startY+33,maxBarSize,barHeight,color_black)
    draw.RoundedBox(0,startX+19+1,startY+33+1,maxBarSize-2,barHeight-2,backgroundCol)
    draw.RoundedBox(0,startX+19+1,startY+33+1,math.Clamp((ply:Armor()*maxBarSize)/ply:GetMaxArmor(),0,maxBarSize)-2,barHeight-2,armorCol)
    --Money
    draw.SimpleText(DarkRP.formatMoney(ply:getDarkRPVar("money")).." (+"..ply:getDarkRPVar("salary").."$)", "LucidHUDFont",startX+19+5,startY+60,color_white,TEXT_ALIGN_LEFT)
    --Name and job
    draw.SimpleText(ply:Nick(), "LucidHUDFont", startX+19+5, startY-16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    --weapon
    local wep = ply:GetActiveWeapon()
    if wep:IsValid() then
        local startXWep = scrw-startX-maxBarSize
        local wep_name = wep:GetPrintName() or wep:GetClass() or "Unbekannt"
        local ammo_type = wep:GetPrimaryAmmoType()
        if ammo_type == -1 then
            draw.SimpleTextOutlined(wep_name, "LucidHUDFont", startXWep+maxBarSize-5, startY, color_white, TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP,1,color_black)
        else
            local clip = wep:Clip1()
            local maxclip = wep:GetMaxClip1()
            local ammoLength = math.Clamp((wep:Clip1()*maxBarSize)/wep:GetMaxClip1(),0,maxBarSize)
            draw.SimpleText(wep_name, "LucidHUDFont", startXWep+maxBarSize-5, startY, color_white, TEXT_ALIGN_RIGHT)
            draw.SimpleText(clip.."/"..maxclip.." ("..ply:GetAmmoCount(ammo_type)..")", "LucidHUDFont", startXWep+maxBarSize-5, startY+55, color_white, TEXT_ALIGN_RIGHT)
            draw.RoundedBox(0,startXWep,startY+30,maxBarSize,barHeight,color_black)
            draw.RoundedBox(0,startXWep+1,startY+30+1,maxBarSize-2,barHeight-2,backgroundCol)
            draw.RoundedBox(0,startXWep+1+(maxBarSize-ammoLength),startY+30+1,ammoLength-2,barHeight-2,wepCol)
        end
    end
end)

print("[luctus_hud_scpu] cl loaded!")
