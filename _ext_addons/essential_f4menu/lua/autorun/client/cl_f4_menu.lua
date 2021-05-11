
essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}

local defaultBlur = Color(10, 10, 10, 160)
local defaultBlurOutline = Color(20, 20, 20, 210)

local buttonHovered = Color(255, 128, 10, 80)

local tabsHeaderColor = Color(10, 10, 10, 140)
local tabsColor = Color(10, 10, 10, 140)

local tabButtonHeight = 45
local buttonSpacing = 4

essentialDarkRPF4Menu.defaultCategoryColor = Color(0, 107, 0, 150)

essentialDarkRPF4Menu.bgColor1 = Color(10, 10, 10, 80)
essentialDarkRPF4Menu.bgColor2 = Color(10, 10, 10, 160)

local white = Color(255, 255, 255)
local black = Color(0, 0, 0)
local orange = Color(255, 128, 0)

local cog = 'icon16/cog.png'

local blur = Material('pp/blurscreen')

surface.CreateFont('edf_roboto24', {
	font = 'Roboto Regular',
	extended = true,
	size = 24
})

surface.CreateFont('edf_roboto20', {
	font = 'Roboto Regular',
	extended = true,
	size = 20
})

surface.CreateFont('edf_roboto18', {
	font = 'Roboto Regular',
	extended = true,
	size = 18
})

surface.CreateFont('edf_roboto16', {
	font = 'Roboto Regular',
	extended = true,
	size = 16
})

local function buttonRolloverSound()
	surface.PlaySound('ui/buttonrollover.wav')
end

local function buttonClickSound()
	surface.PlaySound('ui/buttonclick.wav')
end

-- Draw outlined blur rectangle in paint hook
local function drawBlurRectOutlined(xpos, ypos, width, height, color, layers, density)
	local x, y = 0, 0
	local scrW, scrH = ScrW(), ScrH()
	local xpos, ypos = panel:GetPos()

	surface.SetDrawColor(white)
	surface.SetMaterial(blur)

	for i = 1, layers do
		blur:SetFloat('$blur', (i / layers) * density)
		blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(xpos + 1, ypos + 1, xpos + (width + 1), ypos + (height + 1), true)
			surface.DrawTexturedRect(-x, -y, scrW, scrH)
		render.SetScissorRect(0, 0, 0, 0, false)
	end

	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width, height)

	surface.SetDrawColor(defaultBlurOutline)
	surface.DrawOutlinedRect(xpos, ypos, width + 2, height + 2)
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

-- Draw normal (non-blurred) outline panel
local function drawPanelOutlined(panel, color)
    local width, height = panel:GetWide(), panel:GetTall()
	local xpos, ypos = panel:GetPos()

    surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

    surface.SetDrawColor(defaultBlurOutline)
    surface.DrawOutlinedRect(xpos, ypos, width, height)
end

local function drawRectOutlined(xpos, ypos, width, height, color)
	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

	surface.SetDrawColor(defaultBlurOutline)
	surface.DrawOutlinedRect(xpos, ypos, width, height)
end

local function drawMainFrame(scrW, scrH)
	essentialDarkRPF4Menu.mainFrame = vgui.Create('Panel')

	if scrW < 1024 then
		essentialDarkRPF4Menu.width = scrW
	elseif scrW < 1150 then
		essentialDarkRPF4Menu.width = scrW * 0.95
	elseif scrW < 1600 then
		essentialDarkRPF4Menu.width = scrW * 0.85
	else
		essentialDarkRPF4Menu.width = scrW * 0.75
	end

	if scrH < 720 then
		essentialDarkRPF4Menu.height = scrH
	elseif scrH < 900 then
		essentialDarkRPF4Menu.height = scrH * 0.85
	else
		essentialDarkRPF4Menu.height = scrH * 0.75
	end

	essentialDarkRPF4Menu.mainFrame:SetSize(essentialDarkRPF4Menu.width, essentialDarkRPF4Menu.height)
	essentialDarkRPF4Menu.mainFrame:Center()

	essentialDarkRPF4Menu.startTime = SysTime()

	function essentialDarkRPF4Menu.mainFrame:Paint()
		Derma_DrawBackgroundBlur(essentialDarkRPF4Menu.mainFrame, essentialDarkRPF4Menu.startTime)
	end

	function essentialDarkRPF4Menu.mainFrame:Paint()
		drawBlurPanelOutlined(self, defaultBlur, 3, 8)
	end

	function essentialDarkRPF4Menu.returnMainFrame()
		return essentialDarkRPF4Menu.mainFrame
	end

	function essentialDarkRPF4Menu.mainFrame:OnRemove()
		gui.EnableScreenClicker(false)

		hook.Remove('Think', 'edf_jobChangeThink')
		hook.Remove('Think', 'edf_infoUpdate')
	end
end

local function drawTabsPanel()
	local mainFrame = essentialDarkRPF4Menu.returnMainFrame()

	local xpos, ypos = 0, 0

	local tabsPanelWidth = 210

	local tabsPanel = mainFrame:Add('DPanel')
	tabsPanel:Dock(LEFT)
	tabsPanel:DockMargin(0, 0, 8, 0)
	tabsPanel:SetSize(tabsPanelWidth, mainFrame:GetTall() - (ypos + ypos))

	function tabsPanel:Paint()
		drawPanelOutlined(self, essentialDarkRPF4Menu.bgColor1)
	end

	local panelWidth, panelHeight = tabsPanel:GetWide(), tabsPanel:GetTall()

	local tabsHeader = tabsPanel:Add('DPanel')
	tabsHeader:Dock(TOP)
	tabsHeader:SetTall(tabButtonHeight)

	function tabsHeader:Paint()
		drawPanelOutlined(self, tabsHeaderColor)
	end

	local osTime = os.date('%a, %H:%M:%S %p')

	local dateTime = tabsHeader:Add('DLabel')
	dateTime:SizeToContentsX()
	dateTime:SetFont('edf_roboto24')
	dateTime:SetTextColor(white)
	dateTime:SetText(osTime)
	dateTime:Dock(FILL)
	dateTime:SetContentAlignment(5)

	function dateTime:Paint()
		local osTime = os.date('%a, %H:%M:%S %p')

		dateTime:SetText(osTime)
	end

	-- Tab buttons scroll panel
	local tabsHeaderPosX, tabsHeaderPosY = tabsHeader:GetPos()
	local tabsHeaderHeight = tabsHeader:GetTall()

	local tabButtonsPanel = vgui.Create('DScrollPanel', tabsPanel)
	tabButtonsPanel:Dock(FILL)
	tabButtonsPanel:DockMargin(0, buttonSpacing, 0, buttonSpacing)
	tabButtonsPanel:SetPos(tabsHeaderPosX, tabsHeaderPosY + tabsHeaderHeight)
	tabButtonsPanel:SetTall(mainFrame:GetTall() - (tabsHeaderHeight + tabsHeaderHeight))

	local scrollBar = tabButtonsPanel:GetVBar()
	scrollBar:DockMargin(-5, 0, 0, 0)

	function scrollBar:Paint() return end

	function scrollBar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function scrollBar.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	function scrollBar.btnDown:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, defaultBlur)
	end

	local tabs = {
		'Commands'
	}

	essentialDarkRPF4Menu.tabPos = #tabs

	if #RPExtraTeams > 0 then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Jobs')
	end

	if #DarkRPEntities > 0 then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Entities')
	end

	if #CustomShipments > 0 then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Shipments')

		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Weapons')
	end

	if #GAMEMODE.AmmoTypes > 0 then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Ammo')
	end

	if #CustomVehicles > 0 then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Vehicles')
	end

	if not DarkRP.disabledDefaults['modules']['hungermod'] then
		essentialDarkRPF4Menu.tabPos = essentialDarkRPF4Menu.tabPos + 1

		table.insert(tabs, essentialDarkRPF4Menu.tabPos, 'Food')
	end

	-- Remove other opened tabs when clicking on a tab
	function essentialDarkRPF4Menu.removeOpenedTabs()
		for _, tab in ipairs(tabs) do
			local lowerCaseTab = string.lower(tab)

			RunString('if IsValid(essentialDarkRPF4Menu.' .. lowerCaseTab .. 'Panel) then ' ..
				'essentialDarkRPF4Menu.' .. lowerCaseTab .. 'Panel:Remove() ' ..
			'end')
		end
	end

	for i = 1, #tabs do
		local tab = vgui.Create('DButton', tabButtonsPanel)
		tab:Dock(TOP)
		tab:DockMargin(buttonSpacing + 1, 0, buttonSpacing + 1, buttonSpacing)
		tab:SetTall(tabButtonHeight)
		tab:SetFont('edf_roboto24')
		tab:SetTextColor(white)
		tab:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage][tabs[i]])

		function tab:Paint(w, h)
			if self:IsHovered() then
				tab:SetTextColor(orange)
			else
				tab:SetTextColor(white)
			end

			surface.SetDrawColor(defaultBlurOutline)
			surface.DrawOutlinedRect(0, 0, w, h)

			surface.SetDrawColor(tabsColor)
			surface.DrawRect(1, 1, w - 2, h - 2)
		end

		function tab:DoClick()
			essentialDarkRPF4Menu.removeOpenedTabs()

			RunString('essentialDarkRPF4Menu.open' .. tabs[i] .. 'Tab()')

			-- Remember the last tab
			essentialDarkRPF4Menu.rememberedTab = tabs[i]

			buttonClickSound()
		end
	end

	-- Exit button
	local closeButton = vgui.Create('DButton', tabsPanel)
	closeButton:Dock(BOTTOM)
	closeButton:DockMargin(0, 0, 0, 0)
	closeButton:SetTall(tabButtonHeight)
	closeButton:SetTextColor(white)
	closeButton:SetFont('edf_roboto24')
	closeButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Exit'])

	function closeButton:Paint()
		if self:IsHovered() then
			closeButton:SetTextColor(orange)
		else
			closeButton:SetTextColor(white)
		end

		surface.SetDrawColor(tabsHeaderColor)
		surface.DrawRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)

		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall())
	end

	function closeButton:DoClick()
		if IsValid(mainFrame) then
			mainFrame:Remove()
		end
	end

	function essentialDarkRPF4Menu.returnTabsPanel()
		return tabsPanel
	end
end

local function drawMainFrameHeader()
	localPlayer = LocalPlayer()

	local mainFrame = essentialDarkRPF4Menu.returnMainFrame()
	local tabsPanel = essentialDarkRPF4Menu.returnTabsPanel()

	local tabsPanelPosX, tabsPanelPosY = tabsPanel:GetPos()

	local mainFrameHeader = mainFrame:Add('DPanel')
	mainFrameHeader:Dock(TOP)
	mainFrameHeader:DockMargin(0, 8, 0, 8)
	mainFrameHeader:SetTall(58)

	function mainFrameHeader:Paint()
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawRect(0, 0, 58, 58)
	end

	function essentialDarkRPF4Menu.returnMainFrameHeader()
		return mainFrameHeader
	end

	-- Player info
	local playerAvatar = vgui.Create('AvatarImage', mainFrameHeader)
	playerAvatar:SetPos(1, 1)
	playerAvatar:SetSize(56, 56)
	playerAvatar:SetPlayer(localPlayer, 128)

	local job = localPlayer:getDarkRPVar('job') or ''

	local jobLabel = vgui.Create('DLabel', mainFrameHeader)
	jobLabel:SetPos((playerAvatar:GetPos() + playerAvatar:GetWide()) + 10, playerAvatar:GetPos() + 6)
	jobLabel:SetTextColor(white)
	jobLabel:SetFont('edf_roboto20')
	jobLabel:SetText(job)
	jobLabel:SizeToContents()

	local moneyLabel = vgui.Create('DLabel', mainFrameHeader)
	moneyLabel:SetPos((playerAvatar:GetPos() + playerAvatar:GetWide()) + 9, playerAvatar:GetPos() + 29)
	moneyLabel:SetTextColor(Color(0, 220, 0))
	moneyLabel:SetFont('edf_roboto20')

	-- Update player money in header
	local function updateHeaderMoney()
		local money = DarkRP.formatMoney(localPlayer:getDarkRPVar('money'), '') or ''

		moneyLabel:SetText(money)
		moneyLabel:SizeToContents()
	end

	updateHeaderMoney()

	function moneyLabel:Paint()
		updateHeaderMoney()
	end

	local settingsButtonPanel = mainFrameHeader:Add('DPanel')
	settingsButtonPanel:SizeToContents()
	settingsButtonPanel:DockMargin(0, 0, 8, 0)
	settingsButtonPanel:Dock(RIGHT)

	function settingsButtonPanel:Paint() return end

	-- Settings button
	local buttonSize = 24

	local settingsButton = settingsButtonPanel:Add('DButton')
	settingsButton:SetPos(settingsButtonPanel:GetWide() - buttonSize, 0)
	settingsButton:SetSize(buttonSize, buttonSize)
	settingsButton:SetText('')
	settingsButton:SetImage(cog)

	if essentialDarkRPF4Menu.settings.hideSettingsButton or (not localPlayer:IsSuperAdmin() or localPlayer:IsUserGroup('owner')) then
		settingsButton:SetVisible(false)
	else
		settingsButton:SetVisible(true)
	end

	function settingsButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)
	end

	settingsButton.DoClick = function()
		essentialDarkRPF4Menu.openSettingsMenu()

		buttonClickSound()
	end
end

-- Middle panel
local function drawMidPanel()
	local mainFrame = essentialDarkRPF4Menu.returnMainFrame()
	local tabsPanel = essentialDarkRPF4Menu.returnTabsPanel()
	local mainFrameHeader = essentialDarkRPF4Menu.returnMainFrameHeader()

	local mainFrameHeaderHeight = mainFrameHeader:GetTall()

	local midPanel = mainFrame:Add('DPanel')
	midPanel:SetSize(mainFrame:GetWide(), mainFrame:GetTall() - (mainFrameHeaderHeight + 24))
	midPanel:Dock(TOP)
	midPanel:DockMargin(0, 0, 8, 100)

	function midPanel:Paint() return end

	function essentialDarkRPF4Menu.returnMidPanel()
		return midPanel
	end
end

local function createF4Menu()
	if not DarkRP then return end

	local scrW, scrH = ScrW(), ScrH()

	drawMainFrame(scrW, scrH)
	drawTabsPanel()
	drawMainFrameHeader()
	drawMidPanel()

	local localPlayer = LocalPlayer()

	local mainFrame = essentialDarkRPF4Menu.returnMainFrame()

	local originalPlayerJob = localPlayer:getJobTable().name
	local originalPlayerGroup = localPlayer:GetUserGroup()

	-- Close F4 Menu if player's job OR user group changes
	hook.Add('Think', 'edf_jobChangeThink', function()
		if IsValid(mainFrame) and (localPlayer:getJobTable().name ~= originalPlayerJob or localPlayer:GetUserGroup() ~= originalPlayerGroup) then
			mainFrame:Remove()
		end
	end)

	local originalPlayerMoney = localPlayer:getDarkRPVar('money')

	-- Update player money in header
	hook.Add('Think', 'edf_infoUpdate', function()
		if IsValid(moneyLabel) then
			updateHeaderMoney()
		end
	end)
end

-- Forget remembered tab on start
essentialDarkRPF4Menu.rememberedTab = nil

local function openF4MenuToggle()
	if not DarkRP then return end

	if IsValid(essentialDarkRPF4Menu.mainFrame) then
		essentialDarkRPF4Menu.mainFrame:Remove()

		buttonRolloverSound()
	else
		createF4Menu()

		if essentialDarkRPF4Menu.rememberedTab == nil then

			-- Open Jobs tab on start
			essentialDarkRPF4Menu.openJobsTab()
		else

			-- Open last opened tab
			RunString('essentialDarkRPF4Menu.open' .. essentialDarkRPF4Menu.rememberedTab .. 'Tab()')
		end

		gui.EnableScreenClicker(true)

		buttonRolloverSound()
	end
end

hook.Add('ShowSpare2', 'edf_openF4Menu', function()
	openF4MenuToggle()

	return false
end)

hook.Add('OnPlayerChat', 'edf_openF4MenuCommand', function(ply, text)
	if string.lower(text) == '!f4' then
		openF4MenuToggle()
	end
end)

hook.Add('OnPlayerChat', 'edf_openF4MenuSettingsCommand', function(ply, text)
	if string.lower(text) == '!f4menu' then
		if IsValid(essentialDarkRPF4Menu.settingsMenu) then
			essentialDarkRPF4Menu.settingsMenu:Remove()
		end

		essentialDarkRPF4Menu.openSettingsMenu()

		buttonClickSound()
	end
end)
