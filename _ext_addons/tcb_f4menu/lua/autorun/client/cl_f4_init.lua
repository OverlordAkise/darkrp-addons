--Creator: TheCodingBeast - TheCodingBeast.com

-- Variables
local TCB = {}
local TCB_F4Frame

-- Menu (Open/Create)
function TCB:OpenF4Menu()
	if TCB_F4Frame and ValidPanel( TCB_F4Frame ) then
		-- Open
    _G["F4PanelReady"] = false
		TCB_F4Frame:SetVisible( true )
		TCB_F4Frame:Show()
		
		TCB_F4Frame.ActivePanel:RefillData()

	else
		-- Create
		TCB_F4Frame = vgui.Create( "TCB_F4Menu" )

		-- Default Panel
		TCB_F4Frame:MakePanels( TCB_Settings.SidebarButtons[1]['panel'] )
		TCB_F4Frame.sidebuttons[1].Active = true

		-- Don't Check Version

		-- Update Panel
		if TCB_F4Frame.ActivePanel != nil then
			TCB_F4Frame.ActivePanel:RefillData()
		end
		
		-- Show
		TCB_F4Frame:SetVisible( true )
		TCB_F4Frame:Show()

	end
end
concommand.Add( "tcb_f4menu_open", function() TCB:OpenF4Menu() end )

-- Menu (Close)
function TCB:CloseF4Menu()
	if TCB_F4Frame then
		-- Hide
		TCB_F4Frame:SetVisible( false )
		TCB_F4Frame:Hide()

		-- Timer
		_G["F4PanelReady"] = false

	else
		-- Create
		TCB:OpenF4Menu()

	end
end
concommand.Add( "tcb_f4menu_close", function() TCB:CloseF4Menu() end )

-- Handle ( Open / Close )
function TCB:HandleF4Menu()
	if not ValidPanel(TCB_F4Frame) or not TCB_F4Frame:IsVisible() then
		-- Open
		TCB:OpenF4Menu()

	else
		-- Close
		TCB:CloseF4Menu()

	end
end
hook.Add( TCB_Settings.ActivationKey1, "TCB.HandleF4Menu", TCB.HandleF4Menu)

--Override default F4 Menu
hook.Add("InitPostEntity", "CHEF_F4_Override", function()
  function DarkRP.closeF4Menu()
	end
  function DarkRP.toggleF4Menu()
  end
	hook.Remove("PlayerBindPress", "DarkRPF4Bind")
end)
-- Removed Check Version 