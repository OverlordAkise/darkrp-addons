/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

		draw.DrawText( "Loading Website ...", "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), 1 )

	end

	local WebPanel = vgui.Create( "HTML", self )
	WebPanel:SetPos( 6, 6 )
	WebPanel:SetSize( self:GetWide() - 12, self:GetTall() - 12 )
	WebPanel:OpenURL( TCB_Settings.WebPanel_1 )

end

-- Refill
function PANEL:RefillData()

end

-- Derma 
vgui.Register( "tcb_panel_custom1", PANEL, "DPanel" )

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

		draw.DrawText( "Loading Website ...", "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), 1 )

	end

	local WebPanel = vgui.Create( "HTML", self )
	WebPanel:SetPos( 6, 6 )
	WebPanel:SetSize( self:GetWide() - 12, self:GetTall() - 12 )
	WebPanel:OpenURL( TCB_Settings.WebPanel_2 )

end

-- Refill
function PANEL:RefillData()

end

-- Derma 
vgui.Register( "tcb_panel_custom2", PANEL, "DPanel" )

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

		draw.DrawText( "Loading Website ...", "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), 1 )

	end

	local WebPanel = vgui.Create( "HTML", self )
	WebPanel:SetPos( 6, 6 )
	WebPanel:SetSize( self:GetWide() - 12, self:GetTall() - 12 )
	WebPanel:OpenURL( TCB_Settings.WebPanel_3 )

end

-- Refill
function PANEL:RefillData()

end

-- Derma 
vgui.Register( "tcb_panel_custom3", PANEL, "DPanel" )

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

		draw.DrawText( "Loading Website ...", "Trebuchet24", self:GetWide() / 2, self:GetTall() / 2, Color( 255, 255, 255, 255 ), 1 )

	end

	local WebPanel = vgui.Create( "HTML", self )
	WebPanel:SetPos( 6, 6 )
	WebPanel:SetSize( self:GetWide() - 12, self:GetTall() - 12 )
	WebPanel:OpenURL( TCB_Settings.WebPanel_4 )

end

-- Refill
function PANEL:RefillData()

end

-- Derma 
vgui.Register( "tcb_panel_custom4", PANEL, "DPanel" )