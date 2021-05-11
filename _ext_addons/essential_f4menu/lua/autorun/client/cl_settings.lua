
essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}

local defaultBlur = Color(10, 10, 10, 160)
local defaultBlurOutline = Color(20, 20, 20, 210)

local white = Color(255, 255, 255)

local blur = Material('pp/blurscreen')

surface.CreateFont('edf_roboto_thin20', {
	font = 'Roboto Th',
	extended = true,
	size = 20
})

local function buttonClickSound()
	surface.PlaySound('ui/buttonclick.wav')
end

local function buttonClickReleaseSound()
	surface.PlaySound('ui/buttonclickrelease.wav')
end

-- Draw outlined blur panel
local function drawBlurPanelOutlined(panel, color, layers, density)
    local x, y = panel:LocalToScreen(0, 0)
    local width, height = panel:GetWide(), panel:GetTall()
	local xpos, ypos = panel:GetPos()

    surface.SetDrawColor(white)
    surface.SetMaterial(blur)

    for i = 1, layers do
        blur:SetFloat('$blur', (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end

    surface.SetDrawColor(color)
	surface.DrawRect(xpos - (x - 1), ypos - (y - 1), width - 2, height - 2)

    surface.SetDrawColor(defaultBlurOutline)
    surface.DrawOutlinedRect(xpos - x, ypos - y, width, height)
end

local langTable = {
	'English',
	'French',
	'Russian',
	'Ukrainian',
	'Polish',
  'Spanish',
  'German'
}

local langCodes = {
	['English'] = 'gb',
	['French'] = 'fr',
	['Russian'] = 'ru',
	['Ukrainian'] = 'ua',
	['Polish'] = 'pl',
  ['Spanish'] = 'es',
  ['German'] = 'de'
}

net.Receive('edf_settingsUpdate', function()
	local updatedSettings = net.ReadTable()

	essentialDarkRPF4Menu.settings.displayLanguage = updatedSettings['display_language']
	essentialDarkRPF4Menu.settings.hideSettingsButton = updatedSettings['hide_settings_button']

	if IsValid(essentialDarkRPF4Menu.languageBox) then
		essentialDarkRPF4Menu.languageBox:SetValue(essentialDarkRPF4Menu.settings['displayLanguage'])
	end

	if IsValid(essentialDarkRPF4Menu.languageIcon) then
		essentialDarkRPF4Menu.languageIcon:SetImage('flags16/' .. langCodes[essentialDarkRPF4Menu.settings['displayLanguage']] .. '.png')
	end

	if IsValid(essentialDarkRPF4Menu.hideSettingsButtonCheckBox) then
		essentialDarkRPF4Menu.hideSettingsButtonCheckBox:SetChecked(essentialDarkRPF4Menu.settings.hideSettingsButton)
	end
end)

function essentialDarkRPF4Menu.openSettingsMenu()
	local localPlayer = LocalPlayer()

	if not localPlayer:IsSuperAdmin() or localPlayer:IsUserGroup('owner') then
		local msg = 'You must be a superadmin or owner!'

		print(msg)
		chat.AddText(msg)

		return
	end

	if IsValid(essentialDarkRPF4Menu.settingsMenu) then
		essentialDarkRPF4Menu.settingsMenu:Remove()
	end

	if IsValid(essentialDarkRPF4Menu.mainFrame) then
		essentialDarkRPF4Menu.mainFrame:Remove()
	end

	essentialDarkRPF4Menu.settingsMenu = vgui.Create('DFrame')
	essentialDarkRPF4Menu.settingsMenu:SetSize(275, 125)
	essentialDarkRPF4Menu.settingsMenu:Center()
	essentialDarkRPF4Menu.settingsMenu:MakePopup()
	essentialDarkRPF4Menu.settingsMenu:SetTitle('')
	essentialDarkRPF4Menu.settingsMenu:SetDraggable(false)
	essentialDarkRPF4Menu.settingsMenu.btnMaxim:Hide()
	essentialDarkRPF4Menu.settingsMenu.btnMinim:Hide()

	function essentialDarkRPF4Menu.settingsMenu.btnClose:Paint(w, h)
		surface.SetDrawColor(Color(0, 0, 0))
		surface.DrawOutlinedRect(0, 0, w, h)

		if self:IsHovered() then
			surface.SetDrawColor(Color(110, 10, 10, 180))
		else
			surface.SetDrawColor(Color(70, 10, 10, 180))
		end

		surface.DrawRect(0, 0, w, h)

		draw.DrawText('x', 'edf_roboto24', 15, -2, white, TEXT_ALIGN_CENTER)
	end

	function essentialDarkRPF4Menu.settingsMenu:Paint()
		drawBlurPanelOutlined(self, defaultBlur, 3, 8)
	end

	function essentialDarkRPF4Menu:OnRemove()
		hook.Remove('Think', 'edf_settingsGroupChangeThink')
	end

	local windowTitle = essentialDarkRPF4Menu.settingsMenu:Add('DLabel')
    windowTitle:SetPos(5, 2)
    windowTitle:SetText('Settings')
    windowTitle:SetFont('edf_roboto24')
    windowTitle:SetTextColor(white)
	windowTitle:SizeToContents()

	local languagePanel = essentialDarkRPF4Menu.settingsMenu:Add('DPanel')
	languagePanel:Dock(FILL)
	languagePanel:DockMargin(0, 10, 0, 5)

	function languagePanel:Paint() return end

	local languageTitle = languagePanel:Add('DLabel')
	languageTitle:Dock(TOP)
    languageTitle:SetPos(0, 0)
    languageTitle:SetText('Set display language')
    languageTitle:SetFont('edf_roboto_thin20')
    languageTitle:SetTextColor(white)
	languageTitle:SizeToContents()

	essentialDarkRPF4Menu.languageIcon = languagePanel:Add('DImage')
	essentialDarkRPF4Menu.languageIcon:SetImage('flags16/' .. langCodes[essentialDarkRPF4Menu.settings['displayLanguage']] .. '.png')
	essentialDarkRPF4Menu.languageIcon:SetSize(20, 14)
	essentialDarkRPF4Menu.languageIcon:SetPos(244, 35)

	essentialDarkRPF4Menu.languageBox = languagePanel:Add('DComboBox')
	essentialDarkRPF4Menu.languageBox:SetSize(125, 25)
	essentialDarkRPF4Menu.languageBox:SetPos(0, 30)
	essentialDarkRPF4Menu.languageBox:SetValue(essentialDarkRPF4Menu.settings['displayLanguage'])

	for _, lang in ipairs(langTable) do
		essentialDarkRPF4Menu.languageBox:AddChoice(lang, langCodes[lang])
	end

	essentialDarkRPF4Menu.languageBox.OnSelect = function(panel, index, value)
		buttonClickSound()

		if not localPlayer:IsSuperAdmin() or localPlayer:IsUserGroup('owner') then
			local msg = 'You must be a superadmin or owner!'

			print(msg)
			chat.AddText(msg)

			return
		end

		local selectedLang, selectedLangCode = essentialDarkRPF4Menu.languageBox:GetSelected()

		net.Start('edf_changeLanguage')
			net.WriteString(selectedLang)
		net.SendToServer()

		local confirmMsg = 'Server-wide display language set to \'' .. selectedLang .. '\'.'

		print(confirmMsg)
		chat.AddText(confirmMsg)
	end

	essentialDarkRPF4Menu.hideSettingsButtonCheckBox = essentialDarkRPF4Menu.settingsMenu:Add('DCheckBoxLabel')
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:SetPos(25, 0)
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:SetText('Hide settings button on F4 menu (use !f4menu)')
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:SizeToContents()
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:Dock(BOTTOM)
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:DockMargin(0, 0, 0, 0)
	essentialDarkRPF4Menu.hideSettingsButtonCheckBox:SetChecked(essentialDarkRPF4Menu.settings.hideSettingsButton)

	function essentialDarkRPF4Menu.hideSettingsButtonCheckBox:OnChange(bVal)
		buttonClickReleaseSound()

		if not localPlayer:IsSuperAdmin() or localPlayer:IsUserGroup('owner') then
			local msg = 'You must be a superadmin or owner!'

			print(msg)
			chat.AddText(msg)

			return
		end

		net.Start('edf_changeHideSettingsButton')
		net.SendToServer()

		local confirmMsg = 'Hide settings button on F4 menu set to \'' .. tostring(not essentialDarkRPF4Menu.settings.hideSettingsButton) .. '\'.'

		print(confirmMsg)
		chat.AddText(confirmMsg)
	end

	local originalPlayerGroup = localPlayer:GetUserGroup()

	-- Close settings if player's user group changes
	hook.Add('Think', 'edf_settingsGroupChangeThink', function()
		if IsValid(essentialDarkRPF4Menu.settingsMenu) and (localPlayer:GetUserGroup() ~= originalPlayerGroup) then
			essentialDarkRPF4Menu.settingsMenu:Remove()
		end
	end)
end
