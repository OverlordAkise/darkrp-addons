/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Variables
local PANEL = {}
local TCB 	= {}

_G["F4PanelReady"] 	= false
PANEL.ActivePanel	= nil

-- Fonts
surface.CreateFont( "TCB_F4Menu_Big", {
	font = "Trebuchet MS",
	size = 28,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "TCB_F4Menu_Medium", {
	font = "Trebuchet MS",
	size = 24,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "TCB_F4Menu_Medium", {
	font = "Trebuchet MS",
	size = 20,
	weight = 600,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "TCB_F4Menu_Small", {
	font = "Trebuchet MS",
	size = 16,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

-- Format Number
local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
	n = tostring(n)
	local sep = sep or ","
	local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
	end
	return n
end

-- Base Stuff
function PANEL:Init()

	-- Status
	timer.Simple( 0.2, function() _G["F4PanelReady"] = true end)

	-- Frame
	self:SetSize( 900, 650 )
	self:SetTitle( "" )
	self:SetVisible( true )
	self:SetDraggable( false )
	self:ShowCloseButton( false )
	self:SetDeleteOnClose( false )
	self:MakePopup()
	self:Center()
	self.Paint = function( pnl, w, h )

		draw.RoundedBoxEx( 10, 0, 0, self:GetWide()-0, self:GetTall()-0, Color( 255, 255, 255, 2 ), true, true, false, false )
		draw.RoundedBoxEx( 10, 2, 2, self:GetWide()-4, self:GetTall()-4, Color( 45, 45, 45, 255 ), true, true, false, false )

	end

	-- Open Frame
	self:Frame()

end

-- Panel Status
function PANEL:Show()
	if _G["F4PanelReady"] != true then
		timer.Simple( 0.2, function() _G["F4PanelReady"] = true end)
	end
end

-- Close Frame
function PANEL:Think()
	if _G["F4PanelReady"] == true and input.IsKeyDown( KEY_F4 ) then -- <!-- Fix
    hook.Run(TCB_Settings.ActivationKey1)
	end
end

-- Base VGUI
function PANEL:Frame()

	-- Status Bar
	self.StatusBar = vgui.Create( "DPanel", self )
	self.StatusBar:SetSize( self:GetWide(), 28 )
	self.StatusBar:SetPos( 0, self:GetTall() - self.StatusBar:GetTall() - 2)
	self.StatusBar.NewVersion = 0.0
	self.StatusBar.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 2, 0, w - 4, h - 0, Color( 30, 30, 30, 255 ) )

		local VersionText = ""

		if tonumber(self.StatusBar.NewVersion) != 0.0 and tonumber(self.StatusBar.NewVersion) > tonumber(TCB_Settings.Version) then
			VersionText = "Version: "..TCB_Settings.Version.." | New Version Available! ("..self.StatusBar.NewVersion..")"
		else
			VersionText = "Version: "..TCB_Settings.Version
		end

		draw.DrawText( VersionText, "TCB_F4Menu_Small", 10, 6, Color( 255, 255, 255, 255 ) )

		draw.DrawText( "Coded By: TheCodingBeast", "TCB_F4Menu_Small", 886, 6, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT )

	end

	-- Side Bar
	local TCB_SideBar = vgui.Create( "DPanel", self )
	TCB_SideBar:SetSize( 250, self:GetTall() - self.StatusBar:GetTall() - 4)
	TCB_SideBar:SetPos( 2, 2 )
	TCB_SideBar.Paint = function( pnl, w, h )

		draw.RoundedBoxEx( 10, 0, 0, w, h, Color( 38, 38, 38, 255 ), true, false, false, false )

		-- Title One
		draw.DrawText( TCB_Settings.TitleOne, "TCB_F4Menu_Big", 250 / 2 + 1, 10 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( TCB_Settings.TitleOne, "TCB_F4Menu_Big", 250 / 2 + 0, 10 + 0, TCB_Settings.PrimaryColor, 1 )

		-- Title Two
		draw.DrawText( TCB_Settings.TitleTwo, "TCB_F4Menu_Medium", 250 / 2 + 1, 40 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( TCB_Settings.TitleTwo, "TCB_F4Menu_Medium", 250 / 2 + 0, 40 + 0, TCB_Settings.SecondaryColor, 1 )

	end

	-- Close Button
	local CloseButton = vgui.Create( "DButton", TCB_SideBar )
	CloseButton:SetSize( TCB_SideBar:GetWide() - 4, 40 )
	CloseButton:SetPos( 2, TCB_SideBar:GetTall() - 2 - 40 )
	CloseButton:SetText( "" )
	CloseButton.Hover 	= false
	CloseButton.Active 	= false
	CloseButton.OnCursorEntered	= function() CloseButton.Hover = true  end
	CloseButton.OnCursorExited 	= function() CloseButton.Hover = false end
	CloseButton.DoClick = function() RunConsoleCommand( "tcb_f4menu_close" ) end
	CloseButton.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w, h, Color( 36, 36, 36, 255 ) )

		if CloseButton.Hover == false then
			draw.RoundedBox( 0, 0, 0, w, h, Color( 42, 42, 42, 255 ) )
		else
			draw.RoundedBox( 0, 0, 0, w, h, Color( 36, 36, 36, 255 ) )
		end

		draw.DrawText( "Close", "TCB_F4Menu_Medium", w/2, 10, Color( 200, 200, 200, 255 ), 1 )

	end


	-- Add Buttons
	SidebarY = 75
	pb = {}
	bb = {}
	for _, button in pairs(TCB_Settings.SidebarButtons) do

		if button['text'] == "Divider" then
			
			SidebarY = SidebarY + 11 + 2

		else

			local CurButton = vgui.Create( "DButton", TCB_SideBar )
			CurButton:SetSize( TCB_SideBar:GetWide()-4, 40 )
			CurButton:SetPos( 2, SidebarY )
			CurButton:SetText( "" )
			CurButton.Hover 	= false
			CurButton.Active 	= false
			CurButton.OnCursorEntered	= function() CurButton.Hover = true  end
			CurButton.OnCursorExited 	= function() CurButton.Hover = false end

			if isnumber(button['func']) then
			
				button['func'] = button['func']
			
			else
			
				if button['func'] == "jobs" then 

					button['func'] = #RPExtraTeams 

				elseif button['func'] == "entities" then 

					button['func'] = #DarkRPEntities 

				elseif button['func'] == "weapons" then 

					button['func'] = 0
					for k,v in ipairs(CustomShipments) do
						if v['seperate'] then
							button['func'] = button['func'] + 1
						end
					end

				elseif button['func'] == "shipments" then 

					button['func'] = 0
					for k,v in ipairs(CustomShipments) do
						if !v['noship'] then
							button['func'] = button['func'] + 1
						end
					end

				elseif button['func'] == "ammo" then 

					button['func'] = #GAMEMODE.AmmoTypes 

				elseif button['func'] == "vehicles" then 

					button['func'] = #CustomVehicles
				
				else
				
					button['func'] = 0
				
				end
			
			end

			CurButton.DoClick = function() 
	 
				self:ButtonStatus()
				self:HidePanels()
				self:MakePanels( button['panel'] )

				CurButton.Active = true

			end

			CurButton.Paint = function( pnl, w, h )

				if CurButton.Active == false then

					draw.RoundedBox( 0, 0, 0, w, h, Color( 36, 36, 36, 255 ) )

					if CurButton.Hover == false then
						draw.RoundedBox( 0, 0, 0, w, h, Color( 42, 42, 42, 255 ) )
					else
						draw.RoundedBox( 0, 0, 0, w, h, Color( 36, 36, 36, 255 ) )
					end

					draw.DrawText( button['text'], "TCB_F4Menu_Medium", 10, 10, Color( 200, 200, 200, 255 ) )

				else

					draw.RoundedBox( 0, 0, 0, w, h, TCB_Settings.PrimaryColor )

					draw.DrawText( button['text'], "TCB_F4Menu_Medium", 10, 10, Color( 255, 255, 255, 255 ) )

				end

				if button['info'] then
					if button['func'] > 0 then

						draw.RoundedBox( 4, w - 50 + 0, 8 + 0, 40 - 0, 26 - 0, Color( 0, 0, 0, 100 ) )
						draw.RoundedBox( 4, w - 50 + 2, 8 + 2, 40 - 4, 26 - 4, Color( 52, 152, 219, 255 ) )

					else

						draw.RoundedBox( 4, w - 50 + 0, 8 + 0, 40 - 0, 26 - 0, Color( 0, 0, 0, 100 ) )
						draw.RoundedBox( 4, w - 50 + 2, 8 + 2, 40 - 4, 26 - 4, Color( 231, 76, 60, 255 ) )

					end
					draw.DrawText( tonumber(button['func']), "TCB_F4Menu_Medium", w - 30, 11, Color( 255, 255, 255, 255 ), 1 )
				else

					draw.RoundedBox( 4, w - 50 + 0, 8 + 0, 40 - 0, 26 - 0, Color( 0, 0, 0, 100 ) )
					draw.RoundedBox( 4, w - 50 + 2, 8 + 2, 40 - 4, 26 - 4, Color( 46, 204, 113, 255 ) )

					draw.DrawText( "-", "TCB_F4Menu_Medium", w - 30, 11, Color( 255, 255, 255, 255 ), 1 )

				end

			end

			SidebarY = SidebarY + 40 + 2

			table.insert( bb, CurButton )

		end

	end

	self.sidebuttons = bb

end

-- Check Version
function PANEL:UpdateVersion( version )

	self.StatusBar.NewVersion = version

end

-- Button Status
function PANEL:ButtonStatus()
	for k, v in pairs(bb) do

		v.Active = false

	end
end

-- Make Panels
function PANEL:MakePanels( panel )

	local CurPanelName = pb['p_'..panel]

	if ValidPanel(CurPanelName) then

		CurPanelName:RefillData()

		CurPanelName:SetVisible( true )

	else

		pb['p_'..panel] = vgui.Create( panel, self )

	end

	self.ActivePanel 	= pb['p_'..panel]

end

-- Hide Panels
function PANEL:HidePanels()
	for k, v in pairs(TCB_Settings.SidebarButtons) do
		
		local CurPanelName = pb['p_'..v['panel']]

		if ValidPanel(CurPanelName) and CurPanelName:IsVisible() then

			CurPanelName:SetVisible( false )

		end

	end
end

-- Define VGUI
vgui.Register( "TCB_F4Menu", PANEL, "DFrame" )