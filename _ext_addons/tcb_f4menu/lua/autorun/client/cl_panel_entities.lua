/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Variables
local PANEL = {}
local TCB_Scroll

-- Panel
function PANEL:Init()

	self:SetSize( 650 - 2, 620 - 2 )
	self:SetPos( 250, 2 )
	self.Paint = function()

		draw.RoundedBoxEx( 0, 0, 0, self:GetWide(), self:GetTall(), Color( 0, 0, 0, 0 ), false, true, false, false )

	end

	TCB_Scroll = vgui.Create( "tcb_panel_scroll", self )

	-- Fill Data
	self:FillData( TCB_Scroll )

end

-- Fill Data
function PANEL:FillData( parent )

	local StartYPos = 0

	for i, item in ipairs(DarkRPEntities) do

		local ShowThisItem = true
		if TCB_Settings.HideWrongJob == true then

			if istable(item.allowed) 	and not table.HasValue( item.allowed, LocalPlayer():Team() ) 	then ShowThisItem = false end
			if item.customCheck 		and not item.customCheck( LocalPlayer() ) 						then ShowThisItem = false end

		end

		if ShowThisItem == true then

			CurrentItem = vgui.Create( "tcb_panel_item", parent )
			CurrentItem:SetPos( 0, StartYPos )

			CurrentItem:UpdateInfo( item, "entities", "entities" )

			StartYPos = StartYPos + CurrentItem:GetTall() + 11

		end

	end

	if TCB_Settings.HideWrongJob == true then
		
		local HideElementsMsg = vgui.Create( "tcb_panel_hidden", parent )
		HideElementsMsg:SetPos( 0, StartYPos )

	end

end

-- Refill Data
function PANEL:RefillData()

	-- Remove Items
	TCB_Scroll:Clear()

	-- Scroll Fix
	TCB_Scroll:ScrollFix()
	
	-- Fill Items
	self:FillData( TCB_Scroll )

end

-- Derma 
vgui.Register( "tcb_panel_entities", PANEL, "DPanel" )