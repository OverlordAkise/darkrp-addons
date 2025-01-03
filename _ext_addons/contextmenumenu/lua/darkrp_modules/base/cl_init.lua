--Uploaded by OverlordAkise
--Sent by a friend, no idea where the script is from
--Random contextmenu script here, it's cool, level 3

local C_CONFIG_POSITION = "left" -- left, right, top or bottom
local Menu = {}

local function Option(title, icon, cmd, check)
	table.insert(Menu, {
		title = title,
		icon = icon,
		cmd = cmd,
		check = check
	})
end

local function SubMenu(title, icon, func, check)
	table.insert(Menu, {
		title = title,
		icon = icon,
		func = func,
		check = check
	})
end

local function Spacer(check)
	table.insert(Menu, {
		check = check
	})
end

local function Request(title, text, func)
	return function()
		Derma_StringRequest(DarkRP.getPhrase(title) or title, DarkRP.getPhrase(text) or text, nil, function(s)
			func(s)
		end)
	end
end

local function isCP()
	return LocalPlayer():isCP()
end

local function icon( name )
	return "icon16/" .. name .. ".png"
end



Option("Toggle 3rd Person", "icon16/user_go.png",  function()
	RunConsoleCommand("simple_thirdperson_enable_toggle")
end)

Option("Buddies", "icon16/group_add.png",  function()
	RunConsoleCommand("buddies")
end)

Option("FPS Menu", "icon16/cog_add.png",  function()
	RunConsoleCommand("say", "!fps")
end)

Option("Unbox", "icon16/package_add.png",  function()
	RunConsoleCommand("say", "!unbox")
end)

Option("Coin Flips", "icon16/coins.png",  function()
	RunConsoleCommand("say", "!flips")
end)


-- Option("Unbox", "icon16/briefcase.png", function()
	-- RunConsoleCommand("say", "!unbox")
-- end)

Option("Party Menu", "icon16/group.png", function()
	RunConsoleCommand("say", "!party")
end)



SubMenu("Cash transactions", "icon16/money.png", function(self)
	self:AddOption("Drop money", Request("", "How much?", function(s)
		 RunConsoleCommand("darkrp", "dropmoney", s)
	end)):SetImage("icon16/money_delete.png")

	self:AddOption("Give money", Request("", "How much?", function(s)
		RunConsoleCommand("darkrp", "give", s)
	end)):SetImage("icon16/money.png")

	local mo, pm = self:AddSubMenu("Write a cheque")
	local localplayer = LocalPlayer()
	for k, v in ipairs(player.GetAll()) do
		if v == localplayer then continue end
		mo:AddOption(v:Name(), Request("Write a cheque", "How much?", function(s)
			 RunConsoleCommand("darkrp", "check", v:UserID(), s)
		end)):SetColor(v:getJobTable().color)
	end
	pm:SetImage("icon16/application_form_edit.png")
end)


Option("Buy ammunition for current weapon", "icon16/application.png", function()
    RunConsoleCommand("darkrp", "buyammo", LocalPlayer():GetActiveWeapon().Primary.Ammo)
end,
function()
    return IsValid(LocalPlayer():GetActiveWeapon()) and istable(LocalPlayer():GetActiveWeapon().Primary) and LocalPlayer():GetActiveWeapon().Primary.Ammo and fn.Head(fn.Filter(function(x) return x.ammoType == LocalPlayer():GetActiveWeapon().Primary.Ammo end, GAMEMODE.AmmoTypes))
end)

-- SubMenu("Advert", "icon16/page_white.png", function(self)
	-- self:AddOption("Write a note", Request("", "What do you want to write?", function(s)
		-- RunConsoleCommand("darkrp", "write", s)
	-- end)):SetImage("icon16/page_white_text.png")

	-- self:AddOption("Advert", Request("", "What do you want to advert?", function(s)
		-- RunConsoleCommand("say", "/advert " .. s)
	-- end)):SetImage("icon16/email.png")
-- end)

SubMenu("I need help", "icon16/user_go.png", function(self)
	self:AddOption("Call an admin", Request("", "What is the problem?", function(s)
	RunConsoleCommand("say", "@ " .. s)
	end)):SetImage("icon16/award_star_add.png")

	self:AddOption("Call the police", Request("", "What is the problem?", function(s)
	RunConsoleCommand("say", "/cr " .. s)
	end)):SetImage("icon16/user_go.png")
end)

Option("Sell all doors", "icon16/door.png",  function()
	RunConsoleCommand("say", "/unownalldoors")
end)

Spacer()

Spacer()

Option("Drop weapon", "icon16/gun.png", function()
	RunConsoleCommand("darkrp", "dropweapon")
end)
SubMenu("Demote a player", "icon16/user_delete.png", function(self)
	local localplayer = LocalPlayer()
	for k, v in ipairs(player.GetAll()) do
		if v == localplayer then continue end

		self:AddOption(v:Name(), Request("Demote a player", "What is the reason?", function(s)
			RunConsoleCommand("darkrp", "demote", v:UserID(), s)
		end)):SetColor(v:getJobTable().color)
	end
end)
Option("Change RP name", "icon16/vcard_edit.png", Request("Change RP name", "What do you want to be called?", function(s)
	RunConsoleCommand("darkrp", "rpname", s)
end))


Option("Change job title", "icon16/user.png", Request("Job title", "What is the job name?", function(s)
	RunConsoleCommand("darkrp", "job", s)
end))


Spacer(isCP)

SubMenu("Make a player wanted", "icon16/flag_red.png", function(self)
	local localplayer = LocalPlayer()
	for k, v in ipairs(player.GetAll()) do
		if v == localplayer then continue end

		if not v:isWanted() then
			self:AddOption(v:Name(), Request("Make a player wanted", "What is the reason?", function(s)
				RunConsoleCommand("darkrp", "wanted", v:UserID(), s)
			end)):SetColor(v:getJobTable().color)
		end
	end
end, isCP)

SubMenu("Make a player unwanted", "icon16/flag_green.png", function(self)
	for k, v in ipairs(player.GetAll()) do
		if v:isWanted() then
			self:AddOption(v:Name(), function()
				RunConsoleCommand("darkrp", "unwanted", v:UserID(), s)
			end):SetColor(v:getJobTable().color)
		end
	end
end, isCP)

SubMenu("Request a warrant", "icon16/door_in.png", function(self)
	local localplayer = LocalPlayer()
	for k, v in ipairs(player.GetAll()) do
		if v == localplayer then continue end
		if not v:isWanted() then
			self:AddOption(v:Name(), Request("Request a warrant", "What is the reason?", function(s)
				RunConsoleCommand("darkrp", "warrant", v:UserID(), s)
			end)):SetColor(v:getJobTable().color)
		end
	end
end, isCP)

Option("Give License", "icon16/page_add.png", function(self)
	RunConsoleCommand("darkrp", "givelicense")
end, function()
	local ply = LocalPlayer()
	local noMayorExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isMayor), player.GetAll}
	local noChiefExists = fn.Compose{fn.Null, fn.Curry(fn.Filter, 2)(ply.isChief), player.GetAll}
	local canGiveLicense = fn.FOr{ply.isMayor, fn.FAnd{ply.isChief, noMayorExists}, fn.FAnd{ply.isCP, noChiefExists, noMayorExists}}

	-- Mayors can hand out licenses
	-- Chiefs can if there is no mayor
	-- CP's can if there are no chiefs nor mayors
	return canGiveLicense(ply)
end)


Spacer(function() return LocalPlayer():isMayor() end)

Option("Start a lottery", "icon16/coins.png",
	Request("Start a lottery", "How much to enter? ($100 - $1M)", function(s)
		RunConsoleCommand("darkrp", "lottery", s)
	end),
  function() 
    return LocalPlayer():isMayor() and not GetGlobalBool("LockDown1") 
end)

Option("Add a law", "icon16/application_side_list.png", Request("Add a law", "What law do you want to add?", function(s)
		RunConsoleCommand("say", "/addlaw " .. s)
end), function() return LocalPlayer():isMayor() end)

Option("Reset laws", "icon16/arrow_refresh.png", function()
	RunConsoleCommand("say", "/resetlaws")
end, function() return LocalPlayer():isMayor() end)

Option("Spawn law board", "icon16/application_view_list.png", function()
	RunConsoleCommand("say", "/placelaws")
end, function() return LocalPlayer():isMayor() end)
	
Option("Lockdown", "icon16/stop.png", Request("Lockdown", "What is the reason?", function(s)
	--RunConsoleCommand("darkrp", "lockdown")
	RunConsoleCommand("say", "/lockdown " .. s)
end), function() return LocalPlayer():isMayor() end)

Option("Unlockdown", "icon16/stop.png", function()
	--RunConsoleCommand("darkrp", "unlockdown")
	RunConsoleCommand("say", "/unlockdown")
end, function() return LocalPlayer():isMayor() end)

Spacer()
if ulx then
SubMenu("Admin", "icon16/book.png", function(self)
  self:AddOption("Go on duty", function()
    RunConsoleCommand("say", "/aduty")
  end):SetIcon("icon16/bell.png")

  self:AddOption("Stats", function()
    RunConsoleCommand("say", "/astats")
  end):SetIcon("icon16/application.png")

  self:AddOption("Logs", function()
    RunConsoleCommand("say", "!blogs")
  end):SetIcon("icon16/report_add.png")
    
  self:AddOption("Spectate", function()
    RunConsoleCommand("say", "!spectate")
  end):SetIcon("icon16/zoom.png")

  self:AddOption("Cloak", function()
    RunConsoleCommand("ulx", "cloak")
  end):SetIcon("icon16/status_offline.png")

  self:AddOption("Uncloak", function()
    RunConsoleCommand("ulx", "uncloak")
  end):SetIcon("icon16/status_offline.png")

  self:AddOption("God", function()
    RunConsoleCommand("ulx", "god")
  end):SetIcon("icon16/shield.png")

  self:AddOption("Ungod", function()
    RunConsoleCommand("ulx", "ungod")
  end):SetIcon("icon16/shield.png")

  self:AddOption("Noclip", function()
    RunConsoleCommand("ulx", "noclip")
  end):SetIcon("icon16/arrow_out.png")
end, function() return ULib.ucl.query(LocalPlayer(), "ulx noclip") end)
end

local menu
hook.Add("OnContextMenuOpen", "CMenuOnContextMenuOpen", function()
	if not g_ContextMenu:IsVisible() then
		local orig = g_ContextMenu.Open
		g_ContextMenu.Open = function(self, ...)
			self.Open = orig
			orig(self, ...)

			menu = vgui.Create("CMenuExtension")
			menu:SetDrawOnTop(false)

			for k, v in pairs(Menu) do
				if not v.check or v.check() then
					if v.cmd then
						menu:AddOption(v.title, isfunction(v.cmd) and v.cmd or function() RunConsoleCommand(v.cmd) end):SetImage(v.icon)
					elseif v.func then
						local m, s = menu:AddSubMenu(v.title)
						s:SetImage(v.icon)
						v.func(m)
					else
						menu:AddSpacer()
					end
				end
			end

			menu:Open()
			if C_CONFIG_POSITION == "bot" then
				menu:CenterHorizontal()
				menu.y = ScrH()
				menu:MoveTo(menu.x, ScrH() - menu:GetTall() - 8, .1, 0)
			elseif C_CONFIG_POSITION == "right" then
				menu:CenterVertical()
				menu.x = ScrW()
				menu:MoveTo(ScrW() - menu:GetWide() - 8, menu.y, .1, 0)
			elseif C_CONFIG_POSITION == "left" then
				menu:CenterVertical()
				menu.x = - menu:GetWide()
				menu:MoveTo(8, menu.y, .1, 0)
			else
				menu:CenterHorizontal()
				menu.y = - menu:GetTall()
				menu:MoveTo(menu.x, 30 + 8, .1, 0)
			end


			menu:MakePopup()
		end
	end
end)

hook.Add( "CloseDermaMenus", "CMenuCloseDermaMenus", function()
	if menu && menu:IsValid() then
		menu:MakePopup()
	end
end)

hook.Add("OnContextMenuClose", "CMenuOnContextMenuClose", function()
	menu:Remove()
end)



local f = RegisterDermaMenuForClose

local PANEL = {}

AccessorFunc( PANEL, "m_bBorder", 			"DrawBorder" )
AccessorFunc( PANEL, "m_bDeleteSelf", 		"DeleteSelf" )
AccessorFunc( PANEL, "m_iMinimumWidth", 	"MinimumWidth" )
AccessorFunc( PANEL, "m_bDrawColumn", 		"DrawColumn" )
AccessorFunc( PANEL, "m_iMaxHeight", 		"MaxHeight" )

AccessorFunc( PANEL, "m_pOpenSubMenu", 		"OpenSubMenu" )



function PANEL:Init()

	self:SetIsMenu( true )
	self:SetDrawBorder( true )
	self:SetDrawBackground( true )
	self:SetMinimumWidth( 100 )
	self:SetDrawOnTop( true )
	self:SetMaxHeight( ScrH() * 0.9 )
	self:SetDeleteSelf( true )
		
	self:SetPadding( 0 )
	
end


function PANEL:AddPanel( pnl )

	self:AddItem( pnl )
	pnl.ParentMenu = self
	
end

function PANEL:AddOption( strText, funcFunction )

	local pnl = vgui.Create( "CMenuOption", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	pnl:SetTextColor( Color( 255, 255, 255, 255 ) )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	self:AddPanel( pnl )
	
	return pnl

end

function PANEL:AddCVar( strText, convar, on, off, funcFunction )

	local pnl = vgui.Create( "DMenuOptionCVar", self )
	pnl:SetMenu( self )
	pnl:SetText( strText )
	pnl:SetTextColor( Color( 255, 255, 255, 255 ) )
	if ( funcFunction ) then pnl.DoClick = funcFunction end
	
	pnl:SetConVar( convar )
	pnl:SetValueOn( on )
	pnl:SetValueOff( off )
	
	self:AddPanel( pnl )
	
	return pnl

end

function PANEL:AddSpacer( strText, funcFunction )

	local pnl = vgui.Create( "DPanel", self )
	pnl.Paint = function( p, w, h )
		surface.SetDrawColor( Color( 90, 90, 90, 0 ) )
		surface.DrawRect( 0, 0, w, h )
	end
	
	pnl:SetTall( 1 )	
	self:AddPanel( pnl )
	
	return pnl

end

function PANEL:AddSubMenu( strText, funcFunction )

	local pnl = vgui.Create( "CMenuOption", self )
	local SubMenu = pnl:AddSubMenu( strText, funcFunction )

	pnl:SetText( strText )
	pnl:SetTextColor( Color( 255, 255, 255, 255 ) )
	if ( funcFunction ) then pnl.DoClick = funcFunction end

	self:AddPanel( pnl )

	return SubMenu, pnl

end

function PANEL:Hide()

	local openmenu = self:GetOpenSubMenu()
	if ( openmenu ) then
		openmenu:Hide()
	end
	
	self:SetVisible( false )
	self:SetOpenSubMenu( nil )
	
end

function PANEL:OpenSubMenu( item, menu )

	local openmenu = self:GetOpenSubMenu()
	if ( IsValid( openmenu ) ) then
	
		if ( menu && openmenu == menu ) then return end
	
		self:CloseSubMenu( openmenu )
	
	end
	
	if ( !IsValid( menu ) ) then return end

	local x, y = item:LocalToScreen( self:GetWide(), 0 )
	menu:Open( x-3, y, false, item )
	
	self:SetOpenSubMenu( menu )

end


function PANEL:CloseSubMenu( menu )

	menu:Hide()
	self:SetOpenSubMenu( nil )

end

function PANEL:Paint( w, h )

	if ( !self:GetDrawBackground() ) then return end
	
	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,200))
	surface.SetDrawColor( 0, 0, 0, 240 )
	surface.DrawOutlinedRect( 0, 0, w, h )
end

function PANEL:ChildCount()
	return #self:GetCanvas():GetChildren()
end

function PANEL:GetChild( num )
	return self:GetCanvas():GetChildren()[ num ]
end

function PANEL:PerformLayout()

	local w = self:GetMinimumWidth()
	
	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
	
		pnl:PerformLayout()
		w = math.max( w, pnl:GetWide() )
	
	end

	self:SetWide( w )
	
	local y = 0
	
	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
	
		pnl:SetWide( w )
		pnl:SetPos( 0, y )
		pnl:InvalidateLayout( true )
		
		y = y + pnl:GetTall()
	
	end
	
	y = math.min( y, self:GetMaxHeight() )
	
	self:SetTall( y )

	derma.SkinHook( "Layout", "Menu", self )
	
	DScrollPanel.PerformLayout( self )

end


function PANEL:Open( x, y, skipanimation, ownerpanel )

	local maunal = x and y

	x = x or gui.MouseX()
	y = y or gui.MouseY()
	
	local OwnerHeight = 0
	local OwnerWidth = 0
	
	if ( ownerpanel ) then
		OwnerWidth, OwnerHeight = ownerpanel:GetSize()
	end
		
	self:PerformLayout()
		
	local w = self:GetWide()
	local h = self:GetTall()
	
	self:SetSize( w, h )
	
	
	if ( y + h > ScrH() ) then y = ((maunal and ScrH()) or (y + OwnerHeight)) - h end
	if ( x + w > ScrW() ) then x = ((maunal and ScrW()) or x) - w end
	if ( y < 1 ) then y = 1 end
	if ( x < 1 ) then x = 1 end
	
	self:SetPos( x, y )
	self:MakePopup()
	self:SetVisible( true )
	
	self:SetKeyboardInputEnabled( false )
	
end


function PANEL:OptionSelectedInternal( option )

	self:OptionSelected( option, option:GetText() )

end

function PANEL:OptionSelected( option, text )


end

function PANEL:ClearHighlights()

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		pnl.Highlight = nil
	end

end

function PANEL:HighlightItem( item )

	for k, pnl in pairs( self:GetCanvas():GetChildren() ) do
		if ( pnl == item ) then
			pnl.Highlight = true
		end
	end

end


function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )


end

derma.DefineControl( "CMenuExtension", "ContxtMenuC", PANEL, "DScrollPanel" )

local PANEL = {}

AccessorFunc( PANEL, "m_pMenu", "Menu" )
AccessorFunc( PANEL, "m_bChecked", "Checked" )
AccessorFunc( PANEL, "m_bCheckable", "IsCheckable" )

function PANEL:Init()

	self:SetContentAlignment( 4 )
	self:SetTextInset( 30, 0 )	
	self:SetTextColor( Color( 255, 255, 255 ) )
	self:SetChecked( false )

end

function PANEL:SetSubMenu( menu )

	self.SubMenu = menu

	if ( !self.SubMenuArrow ) then

		self.SubMenuArrow = vgui.Create( "DPanel", self )
		self.SubMenuArrow.Paint = function( panel, w, h ) 
			local rightarrow = {
				{ x = 5, y = 3 },
				{ x = w-5, y = h/2 },
				{ x = 5, y = h-3 }
			}
			surface.SetDrawColor( 255, 255, 255, 255 )
			draw.NoTexture()
			surface.DrawPoly( rightarrow )
		end

	end

end

function PANEL:AddSubMenu()
	if ( !self ) then CloseDermaMenus() end
	local SubMenu = vgui.Create( "CMenuExtension", self )
		SubMenu:SetVisible( false )
		SubMenu:SetParent( self )
		SubMenu.Paint = function(p,w,h)
			draw.RoundedBox(0,3,0,w,h,Color(0,0,0,200))
			surface.SetDrawColor( 0, 0, 0, 240 )
			surface.DrawOutlinedRect( 2, 0, w - 2 , h )
		end

	self:SetSubMenu( SubMenu )

	return SubMenu

end

function PANEL:OnCursorEntered()

	if ( IsValid( self.ParentMenu ) ) then
		self.ParentMenu:OpenSubMenu( self, self.SubMenu )
		return
	end

	self:GetParent():OpenSubMenu( self, self.SubMenu )

end

function PANEL:OnCursorExited()
end

function PANEL:Paint( w, h )

	if self:IsHovered() then
		draw.RoundedBox(0,2,1,w - 3,h - 2,Color(255, 255, 255, 3))		
	end
	return false

end

function PANEL:OnMousePressed( mousecode )
	
	self.m_MenuClicking = true

	DButton.OnMousePressed( self, mousecode )

end

function PANEL:OnMouseReleased( mousecode )

	DButton.OnMouseReleased( self, mousecode )

	if ( self.m_MenuClicking && mousecode == MOUSE_LEFT ) then

		self.m_MenuClicking = false
		CloseDermaMenus()

	end

end

function PANEL:DoRightClick()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

end

function PANEL:DoClickInternal()

	if ( self:GetIsCheckable() ) then
		self:ToggleCheck()
	end

	if ( self.m_pMenu ) then

		self.m_pMenu:OptionSelectedInternal( self )

	end

end

function PANEL:ToggleCheck()

	self:SetChecked( !self:GetChecked() )
	self:OnChecked( self:GetChecked() )

end

function PANEL:OnChecked( b )
end

function PANEL:PerformLayout()

	self:SizeToContents()
	self:SetWide( self:GetWide() + 30 )

	local w = math.max( self:GetParent():GetWide(), self:GetWide() )

	self:SetSize( w, 22 )

	if ( self.SubMenuArrow ) then

		self.SubMenuArrow:SetSize( 15, 15 )
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight( 4 )

	end

	DButton.PerformLayout( self )

end

function PANEL:GenerateExample()

end

derma.DefineControl( "CMenuOption", "ContxtMenuD", PANEL, "DButton" )
