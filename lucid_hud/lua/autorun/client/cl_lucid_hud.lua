--[[
  Free DarkRP HUD v2
  Initial base: Elegant HUD by ted.lua (http://steamcommunity.com/id/tedlua/)
  Refactored and remodeled by: OverlordAkise (https://steamcommunity.com/id/overlordakise/)
]]

--Replaced model with steam avatar
--Set the font to something everyone has
--removed "DrawFillableBars" and similar functions which were either never used or unnecessary
--Removed Table.Hasvalue for HUDShouldDraw (performance)
--Removed CreateHUD and defined it in hook (performance, no double func call)
--Color(255,255,255) -> COLOR_WHITE (doesnt create a new color object)
--Made top and main box into one
--moved local static variables out of the loop


surface.CreateFont( "LucidHUDFont", { font = "Consolas", size = 18, weight = 0 } )
surface.CreateFont( "LucidAmmoFont", { font = "Consolas", size = 48, weight = 0 } )
--Montserrat

local health_icon = Material( "icon16/heart.png" )
local shield_icon = Material( "icon16/shield.png" )
local cash_icon = Material( "icon16/money.png" )
local star_icon = Material( "icon16/star.png" )
local tick_icon = Material( "icon16/tick.png" )
local cup_icon = Material( "icon16/cup.png" )

hook.Add( 'HUDShouldDraw', 'ChefHideDefaultDarkRPHUD', function( vs )
  if vs == "DarkRP_HUD" or vs == "CHudBattery" or vs == "CHudHealth" or vs == "DarkRP_Hungermod" then return false end
  if vs == "CHudSecondaryAmmo" or vs == "CHudAmmo" then return false end
end)

local function CreateImageIcon( icon, x, y, col, val )
    surface.SetDrawColor( col )
    surface.SetMaterial( icon )
    local w, h = 16, 16
    if val then
        surface.SetDrawColor( Color( 255, 255, 255 ) )
    end
    surface.DrawTexturedRect( x, y, w, h )
end

--local vars for HUD
local avatar
local scrw = ScrW()
local scrh = ScrH()
local startX = 5
local startY = scrh-172
local baseWidth = 320
local baseHeight = 140

local barX = 100
local barY = startY + 40
local barWidth = 190
local barHeight = 24
local maxBarSize = 220
local iconOffset = 25

if avatar then avatar:Remove() end
hook.Add( 'HUDPaint', 'HUD_DRAW_HUD', function()
  local ply = LocalPlayer()
  --MainBox
  surface.SetDrawColor(Color(14, 14, 14, 250))
  surface.DrawRect(startX, startY, baseWidth, baseHeight)
  --Job
  surface.SetFont("LucidHUDFont")
  local job = team.GetName( ply:Team() )
  local jobOffset = surface.GetTextSize(job)
  draw.SimpleText( ply:Nick(), "LucidHUDFont", 12, startY + 17, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
  draw.SimpleText( job, "LucidHUDFont", baseWidth-2-jobOffset, startY + 17, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
  --Avatar
  if !IsValid(avatar) then
    avatar = vgui.Create("AvatarImage")
    avatar:SetPos( startX + 10, startY + 39 )
    avatar:SetSize( 75, 75)
    avatar:SetPlayer(ply, 64)
    avatar:ParentToHUD()
    avatar.Think = function(self)
      wep = LocalPlayer():GetActiveWeapon()
      if wep:IsValid() and wep:GetClass() == "gmod_camera" then
        self:Remove()
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
  surface.SetDrawColor(Color(26,26,26))
  surface.DrawRect(barX, barY, maxBarSize, barHeight)
  surface.DrawRect(barX, barY + 28, maxBarSize, barHeight)
  surface.DrawRect(barX, barY + 55, maxBarSize, barHeight)
  --HP
  surface.SetDrawColor(Color(220, 20, 60, 190))
  surface.DrawRect(barX + iconOffset, barY, ((ply:Health()*maxBarSize)/ply:GetMaxHealth()) - iconOffset, barHeight)
  draw.SimpleText(ply:Health() > 0 and ply:Health() or 0, "LucidHUDFont", 215, barY + 4, COLOR_WHITE, TEXT_ALIGN_CENTER)
  --Armor
  surface.SetDrawColor(Color(30, 144, 255))
  surface.DrawRect(barX + iconOffset, barY + 28, ((ply:Armor()*maxBarSize)/ply:GetMaxArmor()) - iconOffset, barHeight)
  draw.SimpleText(ply:Armor() > 0 and ply:Armor() or 0, "LucidHUDFont", 215, barY + 32, COLOR_WHITE, TEXT_ALIGN_CENTER)
  --Green Money
  surface.SetDrawColor(Color(46, 204, 113))
  surface.DrawRect(barX + iconOffset, barY + 55, maxBarSize - iconOffset, barHeight)
  draw.SimpleText(DarkRP.formatMoney(ply:getDarkRPVar( "money" )), "LucidHUDFont", 215, barY+59, COLOR_WHITE, TEXT_ALIGN_CENTER)
  --Icons
  CreateImageIcon(health_icon, 104, startY + 44, Color(255, 0, 0))
  CreateImageIcon(shield_icon, 103,startY + 71, Color(30,144,255))
  CreateImageIcon(cash_icon, 104, startY + 99, Color(255, 255, 255))
  CreateImageIcon(star_icon, 30, startY + 119, Color(40, 40, 40), ply:isWanted() )
  CreateImageIcon(tick_icon, 55, startY + 120, Color(40, 40, 40), ply:getDarkRPVar("HasGunlicense") )
  --Hunger
  if LocalPlayer and LocalPlayer() and LocalPlayer():getDarkRPVar("Energy") then
    surface.SetDrawColor(Color(26,26,26))
    surface.DrawRect(barX, barY + 82, maxBarSize, barHeight/2)
    surface.SetDrawColor(Color(255,155,0))
    surface.DrawRect(barX + iconOffset, barY + 82, ((player.GetAll()[1]:getDarkRPVar("Energy")*maxBarSize)/100) - iconOffset, barHeight/2)
    draw.SimpleText(LocalPlayer():getDarkRPVar("Energy"), "LucidHUDFont", 215, barY+79, COLOR_WHITE, TEXT_ALIGN_CENTER)
    CreateImageIcon(cup_icon, 104, startY + 120, Color(255, 255, 255))
  end
  wep = ply:GetActiveWeapon()
	if wep:IsValid() then
		local veh = ply:GetVehicle()
		if veh:IsValid() and !ply:GetAllowWeaponsInVehicle() then return end
		wep_class = wep:GetClass()
		wep_name = wep:GetPrintName() or wep_class or "Unbekannt"
    ammo_type = wep:GetPrimaryAmmoType()
    if ammo_type == -1 then
      surface.SetDrawColor(Color(14, 14, 14, 250))
      surface.DrawRect(scrw-245, scrh-170, 200, 30)
      draw.SimpleText(wep_name, "LucidHUDFont", scrw-240, scrh-165, COLOR_WHITE, TEXT_ALIGN_LEFT)
    end
    if ammo_type ~= -1 then
      surface.SetDrawColor(Color(14, 14, 14, 250))
      surface.DrawRect(scrw-245, scrh-170, 200, 105)
      draw.SimpleText(wep_name, "LucidHUDFont", scrw-240, scrh-165, COLOR_WHITE, TEXT_ALIGN_LEFT)
      draw.SimpleText(wep:Clip1(), "LucidAmmoFont", scrw-145, scrh-150, COLOR_WHITE, TEXT_ALIGN_RIGHT)
      draw.SimpleText(ply:GetAmmoCount(ammo_type), "LucidHUDFont", scrw-100, scrh-113, COLOR_WHITE, TEXT_ALIGN_RIGHT)
      surface.SetDrawColor(Color(255,155,0))
      surface.DrawRect(scrw-240,scrh-90,(wep:Clip1()*190)/wep:GetMaxClip1(),20)
    end
  end
end)