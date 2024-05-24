--Luctus HUD-bar
--Made by OverlordAkise

surface.CreateFont("LuctusHUDFont", { font = "Arial", size = 24, weight = 0 })
surface.CreateFont("LuctusAmmoFont", { font = "Arial", size = 48, weight = 0 })

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


--Config start

local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)
local color_wep_bar = Color(30,30,30,240)
local color_black_t = Color(0,0,0,230)
local hpCol = Color(220, 110, 110, 255)
local armorCol = Color(0, 0, 255, 255)

local hudHeight = 32 --height of the hud bar at top
local m = 10 --margin between elements
local iconHeight = 24 --how big the icons are


--The HUD elements from left to right
local hud_elements = {
    {Material("icon16/report_user.png"),color_white,function(ply) return ply:Nick() end},
    {Material("icon16/user.png"),color_white,function(ply) return ply:getDarkRPVar("job") end},
    {Material("icon16/money.png"),color_white,function(ply) return DarkRP.formatMoney(ply:getDarkRPVar("money")) end},
    --{Material("icon16/cup.png"),color_white,function(ply) return ply:getDarkRPVar("Energy") end},
    {Material("icon16/heart.png"),hpCol,function(ply) return ply:Health()>0 and ply:Health() or 0 end},
    {Material("icon16/shield.png"),armorCol,function(ply) return ply:Armor() end},
    -- {Material("icon16/award_star_silver_1.png"),color_white,function(ply) return ply:getRPScore() end},
    {Material("icon16/star.png"),color_white,function(ply) return ply:isWanted() and "WANTED" or nil end},
    --gang
}

--The element all the way on the right
local hud_right = {Material("icon16/time.png"),color_white,function(ply) return LuctusBarHudFormatTime(ply:GetUTimeSessionTime()) end}

--Config end


--FormattedTime does not support hours
function LuctusBarHudFormatTime(tim)
    local hours = math.floor( tim / 3600 )
	local minutes = math.floor( ( tim / 60 ) % 60 )
    return string.format( "%02i:%02i:%02i", hours, minutes, math.floor( tim % 60 ))
end

local function CreateImageIcon(icon, x, y, col, val)
    surface.SetDrawColor(col)
    surface.SetMaterial(icon)
    if val then
        surface.SetDrawColor(color_white)
    end
    surface.DrawTexturedRect(x, y, iconHeight, iconHeight)
end

local iconHeightOffset = (hudHeight-iconHeight)/2

hook.Add("HUDPaint", "luctus_hud_bar", function()
    local ply = LocalPlayer()
    --MainBox
    surface.SetDrawColor(color_black_t)
    surface.DrawRect(0,0,scrw,hudHeight)
    surface.SetDrawColor(color_black)
    surface.DrawRect(0,hudHeight,scrw,1)
    --List entries
    local curX = m
    local lastWidth, lastHeight
    for k,stat in ipairs(hud_elements) do
        local text = stat[3](ply)
        if not text then continue end
        CreateImageIcon(stat[1],curX,iconHeightOffset,stat[2])
        curX = curX + iconHeight + m
        local w,h = draw.SimpleText(text,"LuctusHUDFont",curX,hudHeight/2,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
        curX = curX + w + m
        draw.RoundedBox(0,curX,0,1,hudHeight,color_black)
        curX = curX + 1 + m
    end
    --hardcoded right part
    local w,h = draw.SimpleText(hud_right[3](ply),"LuctusHUDFont",scrw-m,hudHeight/2,color_white,TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER)
    CreateImageIcon(hud_right[1],scrw-m-w-m-iconHeight,iconHeightOffset,hud_right[2])
    --weapon
    local wep = ply:GetActiveWeapon()
    if IsValid(wep) then
        local wep_name = wep:GetPrintName() or wep:GetClass() or "Unbekannt"
        local ammo_type = wep:GetPrimaryAmmoType()
        surface.SetDrawColor(color_black_t)
        surface.DrawRect(scrw-300, scrh-170, 250, 30)
        if ammo_type ~= -1 then
            surface.SetDrawColor(color_wep_bar)
            surface.DrawRect(scrw-300,scrh-170,math.Clamp((wep:Clip1()*250)/wep:GetMaxClip1(),0,250),30)
            draw.SimpleText(wep:Clip1(), "LuctusAmmoFont", scrw-300, scrh-155, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(ply:GetAmmoCount(ammo_type), "LuctusHUDFont", scrw-50, scrh-155, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        draw.SimpleText(wep_name, "Trebuchet18", scrw-220, scrh-155, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    --agenda
    local agenda = ply:getAgendaTable()
    if agenda then
        agendaText = DarkRP.textWrap((ply:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPHUD1", 440)
        
        draw.RoundedBox(0, hudHeight+12, 22, 456, 106, color_black_t)
        draw.RoundedBox(0, hudHeight+10, 20, 460, 20, color_black)

        draw.DrawNonParsedText(agenda.Title, "LuctusHUDFont", hudHeight+30, 22, color_white, 0)
        draw.DrawNonParsedText(agendaText, "LuctusHUDFont", hudHeight+30, 45, color_white, 0)
    end
    --lockdown
    if GetGlobalBool("DarkRP_LockDown") then
        local cin = math.Clamp(math.abs(math.sin(CurTime()/5) * ScrW()),0,ScrW()-100)
        draw.DrawNonParsedText("LOCKDOWN", "LuctusHUDFont", cin, scrh-25, color_black_t, TEXT_ALIGN_LEFT)
    end
    --arrested
    if ply:getDarkRPVar("Arrested") then
        draw.SimpleTextOutlined("You are in jail!", "LuctusHUDFont", scrw / 2, scrh - scrh / 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
    end
end)

print("[luctus_hud_bar] cl loaded")
