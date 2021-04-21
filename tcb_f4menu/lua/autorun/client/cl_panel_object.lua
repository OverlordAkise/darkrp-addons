/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( self:GetParent():GetWide() - 20, self:GetParent():GetTall() - 20 )
	self:SetPos( 10, 10 )
	self.Paint = function() end

	self.VBar.Paint 			= function( pnl, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 50) ) end 
	self.VBar.btnUp.Paint 		= function( pnl, w, h ) draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 255, 255, 255, 25 ) ) draw.DrawText( "▲", "HudHintTextSmall", 3, 2, Color( 255, 255, 255, 255 ) ) end
	self.VBar.btnDown.Paint 	= function( pnl, w, h ) draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 255, 255, 255, 25 ) ) draw.DrawText( "▼", "HudHintTextSmall", 3, 2, Color( 255, 255, 255, 255 ) ) end
	self.VBar.btnGrip.Paint 	= function( pnl, w, h ) draw.RoundedBox( 4, 2, 2, w - 4, h - 4, Color( 255, 255, 255, 25 ) ) end

	-- Dirty Fix
	self:ScrollFix()

end

-- Scroll Fix
function PANEL:ScrollFix()

	-- Dirty Fix
	local ScrollFix = vgui.Create( "DPanel", self )
	ScrollFix:SetSize( 0, self:GetTall() + 1 )
	ScrollFix:SetPos( 0, 0 )
	ScrollFix.Paint = function() end 

end

-- Derma
vgui.Register( "tcb_panel_scroll", PANEL, "DScrollPanel" )



-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 608, 30 )
	self.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 60, 60, 60, 255 ) )

		draw.DrawText( "Some items might be hidden because you have the wrong job or rank!", "Trebuchet18", w/2+1, 7+1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( "Some items might be hidden because you have the wrong job or rank!", "Trebuchet18", w/2+0, 7+0, Color( 255, 255, 255, 255 ), 1 )

	end

end

-- Derma
vgui.Register( "tcb_panel_hidden", PANEL, "DPanel" )