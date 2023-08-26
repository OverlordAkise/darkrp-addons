--Luctus HUD
--Made by OverlordAkise

surface.CreateFont( "LucidHUDFont", { font = "Consolas", size = 18, weight = 0 } )
surface.CreateFont( "LucidAmmoFont", { font = "Consolas", size = 48, weight = 0 } )

local health_icon = Material( "icon16/heart.png" )
local shield_icon = Material( "icon16/shield.png" )
local cash_icon = Material( "icon16/money.png" )
local star_icon = Material( "icon16/star.png" )
local tick_icon = Material( "icon16/tick.png" )
local cup_icon = Material( "icon16/cup.png" )

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

local function CreateImageIcon(icon, x, y, col, val)
    surface.SetDrawColor(col)
    surface.SetMaterial(icon)
    if val then
        surface.SetDrawColor(color_white)
    end
    surface.DrawTexturedRect(x, y, 16, 16)
end

--local vars for HUD
local avatar
local scrw = ScrW()
local scrh = ScrH()
local startX = 5
local startY = scrh-185
local baseWidth = 320
local baseHeight = 150

local barX = 100
local barY = startY + 50
local maxBarSize = 220
local barHeight = 24
local iconOffset = 25

--more optimization
local featureCol = Color(0, 195, 165)
local featureColDim = Color(0,150,125)
local mainBoxCol = Color(32, 34, 37, 220)
local backgroundCol = Color(26,26,26)
local hpCol = Color(220, 20, 60, 190)
local armorCol = Color(30, 144, 255)
local moneyCol = Color(46, 204, 113)
local healthCol = Color(255, 0, 0)
local shieldCol = Color(30,144,255)
local darkenedCol = Color(40, 40, 40)
local wepCol = Color(14, 14, 14, 250)
local secCol = Color(255,155,0)
local curJob = 0


hook.Add( "HUDPaint", "luctus_hud", function()
    local ply = LocalPlayer()
    --MainBox
    surface.SetDrawColor(featureCol)
    surface.DrawRect(startX, startY, baseWidth, baseHeight)
    surface.SetDrawColor(backgroundCol)
    surface.DrawRect(startX+2, startY+2, baseWidth - 4, baseHeight - 4)
    --Job
    draw.SimpleText(ply:Nick(), "LucidHUDFont", 15, startY + 14, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(ply:getDarkRPVar("job"), "LucidHUDFont", 15, startY + 34, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    --Avatar
    local wep = ply:GetActiveWeapon()
    if !IsValid(avatar) then
        avatar = vgui.Create("SpawnIcon")
        avatar:SetPos(startX + 10, startY + 49)
        avatar:SetSize(75, 75)
        avatar:SetModel(ply:GetModel())
        avatar:ParentToHUD()
        avatar.Think = function(self)
            if wep:IsValid() and wep:GetClass() == "gmod_camera" then
                self:Remove()
            end
            if curJob ~= ply:Team() then
                self:Remove()
                curJob = ply:Team()
            end
        end
        avatar.OnScreenSizeChanged = function(self)
            self:SetPos(startX + 10, startY + 39)
            scrw = ScrW()
            scrh = ScrH()
            startY = ScrH()-172
            barY = startY + 40
        end
    end
    --backgrounds
    surface.SetDrawColor(backgroundCol)
    surface.DrawRect(barX, barY, maxBarSize, barHeight)
    surface.DrawRect(barX, barY + 28, maxBarSize, barHeight)
    surface.DrawRect(barX, barY + 55, maxBarSize, barHeight)
    --HP
    surface.SetDrawColor(hpCol)
    surface.DrawRect(barX + iconOffset, barY, math.Clamp((ply:Health()*maxBarSize)/ply:GetMaxHealth(),0,maxBarSize) - iconOffset, barHeight)
    draw.SimpleText(ply:Health() > 0 and ply:Health() or 0, "LucidHUDFont", 215, barY + 4, color_white, TEXT_ALIGN_CENTER)
    --Armor
    surface.SetDrawColor(armorCol)
    surface.DrawRect(barX + iconOffset, barY + 28, math.Clamp((ply:Armor()*maxBarSize)/ply:GetMaxArmor(),0,maxBarSize) - iconOffset, barHeight)
    draw.SimpleText(ply:Armor(), "LucidHUDFont", 215, barY + 32, color_white, TEXT_ALIGN_CENTER)
    --Green Money
    surface.SetDrawColor(moneyCol)
    surface.DrawRect(barX + iconOffset, barY + 55, maxBarSize - iconOffset, barHeight)
    draw.SimpleText(DarkRP.formatMoney(ply:getDarkRPVar( "money" )) .. "(+"..ply:getDarkRPVar("salary")..")", "LucidHUDFont", 215, barY+59, color_white, TEXT_ALIGN_CENTER)
    --Icons
    CreateImageIcon(health_icon, 104, startY + 54, healthCol)
    CreateImageIcon(shield_icon, 103,startY + 81, shieldCol)
    CreateImageIcon(cash_icon, 104, startY + 109, color_white)
    CreateImageIcon(star_icon, 30, startY + 129, darkenedCol, ply:isWanted())
    CreateImageIcon(tick_icon, 55, startY + 130, darkenedCol, ply:getDarkRPVar("HasGunlicense"))
    --Hunger
    local energy = ply:getDarkRPVar("Energy")
    if energy then
        surface.SetDrawColor(darkenedCol)
        surface.DrawRect(barX, barY + 82, maxBarSize, barHeight/2)
        surface.SetDrawColor(secCol)
        surface.DrawRect(barX + iconOffset, barY + 82, ((energy*maxBarSize)/100) - iconOffset, barHeight/2)
        draw.SimpleText(energy, "LucidHUDFont", 215, barY+79, color_white, TEXT_ALIGN_CENTER)
        CreateImageIcon(cup_icon, 104, startY + 130, color_white)
    end
    --weapon
    if wep:IsValid() then
        local wep_name = wep:GetPrintName() or wep:GetClass() or "Unbekannt"
        local ammo_type = wep:GetPrimaryAmmoType()
        if ammo_type == -1 then
            surface.SetDrawColor(wepCol)
            surface.DrawRect(scrw-245, scrh-170, 200, 30)
            draw.SimpleText(wep_name, "LucidHUDFont", scrw-240, scrh-165, color_white, TEXT_ALIGN_LEFT)
        else
            surface.SetDrawColor(wepCol)
            surface.DrawRect(scrw-245, scrh-170, 200, 105)
            draw.SimpleText(wep_name, "LucidHUDFont", scrw-240, scrh-165, color_white, TEXT_ALIGN_LEFT)
            draw.SimpleText(wep:Clip1(), "LucidAmmoFont", scrw-145, scrh-150, color_white, TEXT_ALIGN_RIGHT)
            draw.SimpleText(ply:GetAmmoCount(ammo_type), "LucidHUDFont", scrw-100, scrh-113, color_white, TEXT_ALIGN_RIGHT)
            surface.SetDrawColor(secCol)
            surface.DrawRect(scrw-240,scrh-90,math.Clamp((wep:Clip1()*190)/wep:GetMaxClip1(),0,190),20)
        end
    end
    --agenda
    local agenda = ply:getAgendaTable()
    if agenda then
        agendaText = DarkRP.textWrap((ply:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "DarkRPHUD1", 440)
        
        draw.RoundedBox(0, 12, 22, 456, 106, backgroundCol)
        draw.RoundedBox(0, 10, 20, 460, 20, featureColDim)

        draw.DrawNonParsedText(agenda.Title, "LucidHUDFont", 30, 22, color_white, 0)
        draw.DrawNonParsedText(agendaText, "LucidHUDFont", 30, 45, color_white, 0)
    end
    --lockdown
    if GetGlobalBool("DarkRP_LockDown") then
        local cin = math.Clamp(math.abs(math.sin(CurTime()/5) * ScrW()),0,ScrW()-100)
        draw.DrawNonParsedText("LOCKDOWN", "Trebuchet24", cin, scrh-25, featureCol, TEXT_ALIGN_LEFT)
    end
    --arrested
    if ply:getDarkRPVar("Arrested") then
        draw.SimpleTextOutlined("You are in jail!", "Trebuchet24", scrw / 2, scrh - scrh / 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, backgroundCol)
    end
end)

print("[luctus_hud] cl loaded!")
