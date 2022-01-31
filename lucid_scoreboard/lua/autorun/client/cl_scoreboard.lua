--Lucid Scoreboard
--Made by OverlordAkise

local Lucid_Score_ServerName = "Lucid RP"
local Lucid_Score_WebsiteLink = "https://mistforums.com/"

local cgroups = {
  [ 'superadmin' ] = { 'Super Administrator', Color( 199, 44, 44 ) },
  [ 'developer' ] = { 'Developer', Color( 199, 44, 44 ) },
  [ 'admin' ] = { 'Administrator', Color( 241, 196, 15 ) },
  [ 'moderator' ] = { 'Moderator', Color( 52, 152, 219 ) },
  [ 'donator' ] = { 'Donator', Color( 155, 89, 182 ) },
  [ 'vip' ] = { 'VIP', Color( 155, 89, 182 ) }
}

local Lucid_Score_Staff = {
  [ 'superadmin' ] = true,
  [ 'admin' ] = true,
  [ 'moderator' ] = true,
  [ 'developer' ] = true
}

local Lucid_Options = {
  ["ulx bring"] = function(v) print(v) RunConsoleCommand("ulx", "bring", v:Nick()) end,
  ["ulx return"] = function(v) RunConsoleCommand("ulx", "return", v:Nick()) end,
  ["ulx freeze"] = function(v) RunConsoleCommand("ulx", "freeze", v:Nick()) end,
  ["ulx unfreeze"] = function(v) RunConsoleCommand("ulx", "unfreeze", v:Nick()) end,
  ["ulx jail"] = function(v) RunConsoleCommand("ulx", "jail", v:Nick()) end,
  ["ulx unjail"] = function(v) RunConsoleCommand("ulx", "unjail", v:Nick()) end,
  ["ulx spectate"] = function(v) RunConsoleCommand("ulx", "spectate", v:Nick()) end,
}

--------------------------
-- End of configuration --
--------------------------

local Lucid = nil
  

surface.CreateFont( "LucidScoreFontBig", { font = "Montserrat", size = 35, weight = 800, antialias = true, bold = true })
surface.CreateFont( "LucidScoreFontSmall", { font = "Montserrat", size = 20, weight = 700, antialias = true, bold = true })


function lucidDrawRect( x, y, w, h, col )
  surface.SetDrawColor( col )
  surface.DrawRect( x, y, w, h )
end

local function LucidCreateBase()
  if Lucid then Lucid:Close() end
  Lucid = vgui.Create( 'DFrame' )
  Lucid:SetSize( 1000, 700 )
  Lucid:SetTitle( '' )
  Lucid:SetDraggable( false )
  Lucid:SetVisible( true )
  Lucid:ShowCloseButton( false )
  Lucid:Center()
  gui.EnableScreenClicker( true )
  Lucid.Paint = function( me, w, h )
    lucidDrawRect(0, 0, w, h, Color(0, 195, 165))
    lucidDrawRect(1, 1, w-2, h-2, Color(32, 34, 37, 255))
    lucidDrawRect(10, 73, w - 20, 30, Color(34, 34, 34, 150))
    draw.DrawText("Name", "LucidScoreFontSmall", 51, 77, COLOR_WHITE)
    draw.DrawText("Job", "LucidScoreFontSmall", 331, 77, COLOR_WHITE, TEXT_ALIGN_LEFT)
    draw.DrawText("Rank", "LucidScoreFontSmall", 509, 77, COLOR_WHITE)
    draw.DrawText("Kills", "LucidScoreFontSmall", 750, 77, COLOR_WHITE)
    draw.DrawText("Deaths", "LucidScoreFontSmall", 810, 77, COLOR_WHITE)
    draw.DrawText("Ping", "LucidScoreFontSmall", 890, 77, COLOR_WHITE)
    draw.DrawText(Lucid_Score_ServerName, "LucidScoreFontBig", w / 2, 5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER)
    draw.DrawText("There are currently " .. #player.GetAll() .. " player(s) online.", "LucidScoreFontSmall", w / 2, h - 21, Color(255,255,255,255), TEXT_ALIGN_CENTER)
  end

  local website = vgui.Create( 'DLabel', Lucid )
  surface.SetFont("LucidScoreFontSmall")
  local offsetX, offsetY = surface.GetTextSize(Lucid_Score_WebsiteLink)
  website:SetPos(Lucid:GetWide() / 2 - (offsetX/2), 45)
  website:SetSize(offsetX, offsetY)
  website:SetFont("LucidScoreFontSmall")
  website:SetTextColor(Color(0, 195, 165))
  website:SetText(Lucid_Score_WebsiteLink)
  website:SetCursor("hand")
  website:SetMouseInputEnabled( true )
  website.OnMousePressed = function()
      gui.OpenURL(Lucid_Score_WebsiteLink)
  end

  Lucid.PlayerList = vgui.Create("DPanelList", Lucid)
  Lucid.PlayerList:SetSize(Lucid:GetWide() - 20, Lucid:GetTall() - 130)
  Lucid.PlayerList:SetPos(10, 110)
  Lucid.PlayerList:SetSpacing(2)
  Lucid.PlayerList:EnableVerticalScrollbar(true)
  --Lucid.PlayerList:SetStretchHorizontally( false )

  Lucid.PlayerList.Paint = function( me, w, h )
      lucidDrawRect( 0, 0, w, h, Color( 26, 26, 26, 200 ) )
  end

  local sbar = Lucid.PlayerList.VBar
  function sbar:Paint( w, h )
      lucidDrawRect( 0, 0, w, h, Color( 0, 0, 0, 100 ) )
  end
  function sbar.btnUp:Paint( w, h )
      lucidDrawRect( 0, 0, w, h, Color( 44, 44, 44 ) )
  end
  function sbar.btnDown:Paint( w, h )
      lucidDrawRect( 0, 0, w, h, Color( 44, 44, 44 ) )
  end
  function sbar.btnGrip:Paint( w, h )
      lucidDrawRect( 0, 0, w, h, Color( 56, 56, 56 ) )
  end

  for k, v in pairs( player.GetAll() ) do
    local item = vgui.Create('DLabel', Lucid.PlayerList)
    item:SetSize(Lucid.PlayerList:GetWide() - 70, 30)
    item:SetCursor("hand")
    local teamCol = team.GetColor( v:Team() )

    local self = Lucid.PlayerList
    local _y = 7

    item.Paint = function( me, w, h )
      if !IsValid(v) then item:Remove() return end
      if k % 2 == 0 then
          lucidDrawRect( 0, 0, w, h, Color(54, 57, 62) )
      else
          lucidDrawRect( 0, 0, w, h, Color(44, 47, 52) )
      end
      local ugrp = v:GetUserGroup()
      draw.DrawText(v:Nick(), "LucidScoreFontSmall", 40, 4, Color(255,255,255))
      draw.DrawText(v:getDarkRPVar("job"), "LucidScoreFontSmall", 320, 4, team.GetColor(v:Team()),TEXT_ALIGN_LEFT)
      draw.DrawText(cgroups[ugrp] and cgroups[ugrp][1] or ugrp, "LucidScoreFontSmall", 500, 3, cgroups[ugrp] and cgroups[ugrp][2] or Color(255,255,255))
      draw.DrawText(v:Frags() < 0 and 0 or v:Frags(), "LucidScoreFontSmall", 739, 4, Color( 255, 255, 255 ))
      draw.DrawText(v:Deaths(), "LucidScoreFontSmall", 799, 4, Color(255, 255, 255))
      draw.DrawText(v:Ping(), "LucidScoreFontSmall", 879, 4, Color(255, 255, 255))

    end
    item.ply = v
    item.DoRightClick = function()
      if not Lucid_Score_Staff[LocalPlayer():GetUserGroup()] then return end
      if IsValid( Inspect ) then
          Inspect:Remove()
      end
      Inspect = DermaMenu()
      for k,v in pairs(Lucid_Options) do
        Inspect:AddOption(k)
      end
      function Inspect:OptionSelected(option, optionText)
        if Lucid_Options[optionText] ~= nil then
          Lucid_Options[optionText](v)
        end
      end
      Inspect:Open()
    end

    local image = vgui.Create( "AvatarImage", item )
    image:SetSize( 28, 28 )
    image:SetPos( 1, 1 )
    image:SetPlayer( v, 32 )

    local mute = vgui.Create( "DImageButton", item )
    mute:SetSize( 16, 16 )
    mute:SetPos(item:GetWide() + 35, 7 )
    mute:SetImage( v:IsMuted() and 'icon16/sound_mute.png' or 'icon16/sound.png' )

    mute.DoClick = function()
      if !v:IsMuted() then v:SetMuted( true ) else v:SetMuted( false ) end
      mute:SetImage( v:IsMuted() and 'icon16/sound_mute.png' or 'icon16/sound.png' )
    end

    Lucid.PlayerList:AddItem( item )
  end
end


hook.Add( 'ScoreboardShow', 'Lucid_CREATE_BOARD', function()
  LucidCreateBase()
  return true
end)

hook.Add( 'ScoreboardHide', 'Lucid_REMOVE_BOARD', function()
  if IsValid( Lucid ) then 
    Lucid:SetVisible(false)
    gui.EnableScreenClicker(false)
  end
  if IsValid( Inspect ) then Inspect:Remove() end
  return true
end)

-- Fix for removing default Scoreboard B-)
local function repairScoreboard()
  hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
  hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	timer.Simple(3,function(  )
		hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
		hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
	end)
end

hook.Add("OnGamemodeLoaded", "OverrideFAdminScoreboard", repairScoreboard)
hook.Add("DarkRPFinishedLoading", "OverrideFAdminScoreboard", repairScoreboard)