/*---------------------------------------------------------------------------
	
	Creator: TheCodingBeast - TheCodingBeast.com
	This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. 
	To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
	
---------------------------------------------------------------------------*/

-- Table
local CommandsTable = {}

CommandsTable[1]	= {
	type 	= 1,
	cmd 	= "/dropmoney", 
	text 	= "Drop Money", 
	args 	= { arg1_show = true, arg1_text = "Amount", arg2_show = false, arg2_text = "" } 
}

CommandsTable[2]	= {
	type 	= 1,
	cmd 	= "/give", 
	text 	= "Give Money", 
	args 	= { arg1_show = true, arg1_text = "Amount", arg2_show = false, arg2_text = "" } 
}

CommandsTable[3]	= {
	type 	= 2,
	cmd 	= "/drop", 
	text 	= "Drop Current Weapon", 
	args 	= { arg1_show = false, arg1_text = "", arg2_show = false, arg2_text = "" } 
}

CommandsTable[4]	= {
	type 	= 2,
	cmd 	= "/makeshipment", 
	text 	= "Make Shipment", 
	args 	= { arg1_show = false, arg1_text = "", arg2_show = false, arg2_text = "" } 
}

CommandsTable[5]	= {
	type 	= 2,
	cmd 	= "/unownalldoors", 
	text 	= "Sell All Doors", 
	args 	= { arg1_show = false, arg1_text = "", arg2_show = false, arg2_text = "" } 
}

CommandsTable[6]	= {
	type 	= 2,
	cmd 	= "/requestlicense", 
	text 	= "Request License", 
	args 	= { arg1_show = false, arg1_text = "", arg2_show = false, arg2_text = "" } 
}

-- Variables
local PANEL = {}

-- Panel
function PANEL:Init()

	self:SetSize( 299, 90 ) -- Height (2 Args): 130
	self.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 60, 60, 60, 255 ) )

	end

	self.parg1 = vgui.Create( "DPanel", self )
	self.parg1:SetSize( self:GetWide() - 16, 34 )
	self.parg1:SetPos( 8, 8 )
	self.parg1.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 149, 165, 166, 255 ) )
		draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 127, 140, 141, 255 ) )

	end

	self.arg1 = vgui.Create( "DTextEntry", self.parg1 )
	self.arg1:SetSize( self.parg1:GetWide() - 8, self.parg1:GetTall() - 8 )
	self.arg1:SetPos( 4, 4 )
	self.arg1:SetText( "" )
	self.arg1:SetEnabled( false )
	self.arg1.Paint = function( pnl, w, h ) pnl:DrawTextEntryText(Color(255, 255, 255), Color(52, 152, 219), Color(255, 255, 255)) end


	/*self.parg2 = vgui.Create( "DPanel", self )
	self.parg2:SetSize( self:GetWide() - 16, 34 )
	self.parg2:SetPos( 8, self.parg1:GetTall() + 14 )
	self.parg2.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 149, 165, 166, 255 ) )
		draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 127, 140, 141, 255 ) )

	end

	self.arg2 = vgui.Create( "DTextEntry", self.parg2 )
	self.arg2:SetSize( self.parg2:GetWide() - 8, self.parg2:GetTall() - 8 )
	self.arg2:SetPos( 4, 4 )
	self.arg2:SetText( "" )
	self.arg2:SetEnabled( false )
	self.arg2.Paint = function( pnl, w, h ) pnl:DrawTextEntryText(Color(255, 255, 255), Color(52, 152, 219), Color(255, 255, 255)) end*/

	self.button = vgui.Create( "DButton", self )
	self.button:SetSize( self:GetWide() - 16, 34 )
	self.button:SetPos( 8, self.arg1:GetTall() + 22 )	-- Y (2 Args): self.arg1:GetTall() * 2 + 36
	self.button:SetText( "" )
	self.button.Type 	= 1
	self.button.Text 	= ""
	self.button.Hover 	= false
	self.button.Status 	= false
	self.button.OnCursorEntered	= function() self.button.Hover = true  end
	self.button.OnCursorExited 	= function() self.button.Hover = false end
	self.button.DoClick = function() end
	self.button.Paint = function( pnl, w, h )

		draw.RoundedBox( 0, 0, 0, w - 0, h - 0, Color( 0, 0, 0, 100 ) )

		if self.button.Type == 1 then
			draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 46, 204, 113, 255 ) )
			draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 39, 174, 96, 255 ) )
		else
			draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color( 52, 152, 219, 255 ) )
			draw.RoundedBox( 0, 4, 4, w - 8, h - 8, Color( 41, 128, 185, 255 ) )
		end

		draw.DrawText( self.button.Text, "Trebuchet24", w / 2 + 1, 5 + 1, Color( 0, 0, 0, 255 ), 1 )
		draw.DrawText( self.button.Text, "Trebuchet24", w / 2 + 0, 5 + 0, Color( 255, 255, 255, 255 ), 1 )

	end

end

-- Update
function PANEL:UpdateInfo( item )

	-- Arg 1
	local Arg1_Text = item['args']['arg1_text']
	if Arg1_Text == "" then Arg1_Text = "" end

	-- Arg 2
	local Arg2_Text = item['args']['arg2_text']
	if Arg2_Text == "" then Arg2_Text = "" end

	-- Set Args
	self.arg1:SetText( Arg1_Text )
	--self.arg2:SetText( Arg2_Text )

	-- Set Status
	self.arg1:SetEnabled( item['args']['arg1_show'] )
	--self.arg2:SetEnabled( item['args']['arg2_show'] )

	-- Set Text
	self.button.Text = item['text']

	-- Set Type
	self.button.Type = item['type']

	-- Set Command
	local ButtonClick = function() end
	
	if item['args']['arg1_text'] == "" then 
		ButtonClick = function() RunConsoleCommand( "tcb_f4menu_close" ) RunConsoleCommand( "say", item['cmd'] ) end
	else
		ButtonClick = function() RunConsoleCommand( "tcb_f4menu_close" ) RunConsoleCommand( "say", item['cmd'].." "..self.arg1:GetValue() ) end
	end

	self.button.DoClick = ButtonClick

end

-- Derma
vgui.Register( "tcb_panel_item_cmd", PANEL, "DPanel" )


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
	local StartXPos = 0

	local ItemTable = CommandsTable
	for i, item in ipairs( ItemTable ) do

		CurrentItem = vgui.Create( "tcb_panel_item_cmd", parent )
		CurrentItem:SetPos( StartXPos, StartYPos )

		CurrentItem:UpdateInfo( item )

		if StartXPos == 0 then
			StartXPos = StartXPos + CurrentItem:GetWide() + 10
		elseif StartXPos > 0 then
			StartXPos = 0
			StartYPos = StartYPos + CurrentItem:GetTall() + 11
		end
		

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
vgui.Register( "tcb_panel_commands", PANEL, "DPanel" )