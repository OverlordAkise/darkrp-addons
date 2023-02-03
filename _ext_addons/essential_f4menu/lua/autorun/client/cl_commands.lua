
essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}

local white = Color(255, 255, 255)
local black = Color(0, 0, 0)
local orange = Color(255, 128, 0)

local defaultBlur = Color(10, 10, 10, 160)
local defaultBlurOutline = Color(20, 20, 20, 210)

local blur = Material('pp/blurscreen')

local function buttonClickSound()
	surface.PlaySound('ui/buttonclick.wav')
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

-- Draw normal outlined (non-blurred) rectangle in paint hook
local function drawRectOutlined(xpos, ypos, width, height, color)
	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

	surface.SetDrawColor(defaultBlurOutline)
	surface.DrawOutlinedRect(xpos, ypos, width, height)
end

local rowOneCommands = {}
local rowTwoCommands = {}
local rowThreeCommands = {}
local rowFourCommands = {}

-- Row one commands
local onePos = 1

rowOneCommands[onePos]	= {
	cmd = '/dropmoney',
	text = 'Drop Money',
	argAmount = 1,
	argOne = 'Number',
	placeholder = 'Money Amount'
}

local onePos = onePos + 1

rowOneCommands[onePos]	= {
	cmd = '/give',
	text = 'Give Money',
	argAmount = 1,
	argOne = 'Number',
	placeholder = 'Money Amount'
}

local onePos = onePos + 1

rowOneCommands[onePos]	= {
	cmd = '/cheque',
	text = 'Write Cheque',
	argAmount = 2,
	argOne = 'Player',
	argTwo = 'Number',
	placeholder = 'Money Amount'
}

local onePos = onePos + 1

rowOneCommands[onePos] = {
	cmd = '/agenda',
	text = 'Set Agenda',
	argAmount = 1,
	argOne = 'Text',
	placeholder = 'Agenda Text'
}

local onePos = onePos + 1

rowOneCommands[onePos] = {
	cmd = '/advert',
	text = 'Advert',
	argAmount = 1,
	argOne = 'Text',
	placeholder = 'Advert Text'
}

-- Row two commands
local twoPos = 1

rowTwoCommands[twoPos] = {
	cmd = '/dropweapon',
	text = 'Drop Weapon',
	argAmount = 0
}

local twoPos = twoPos + 1

rowTwoCommands[twoPos] = {
	cmd = '/makeshipment',
	text = 'Make Shipment',
	argAmount = 0
}

local twoPos = twoPos + 1

rowTwoCommands[twoPos] = {
	cmd = '/splitshipment',
	text = 'Split Shipment',
	argAmount = 0
}

local twoPos = twoPos + 1

rowTwoCommands[twoPos] = {
	cmd = '/unownalldoors',
	text = 'Sell All Doors',
	argAmount = 0
}

local twoPos = twoPos + 1

rowTwoCommands[twoPos] = {
	cmd = '/requestlicense',
	text = 'Request License',
	argAmount = 0
}

-- Row three commands
local threePos = 1

rowThreeCommands[threePos] = {
	cmd = '/lockdown',
	text = 'Lockdown',
	argAmount = 0,
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/unlockdown',
	text = 'End Lockdown',
	argAmount = 0,
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/addlaw',
	text = 'Add Law',
	argAmount = 1,
	argOne = 'Text',
	placeholder = 'Law Text',
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/removelaw',
	text = 'Remove Law',
	argAmount = 1,
	argOne = 'Number',
	placeholder = 'Law Number',
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/placelaws',
	text = 'Place Law Board',
	argAmount = 0,
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/broadcast',
	text = 'Broadcast',
	argAmount = 1,
	argOne = 'Text',
	placeholder = 'Broadcast Text',
	mayorOnly = true
}

local threePos = threePos + 1

rowThreeCommands[threePos] = {
	cmd = '/lottery',
	text = 'Lottery',
	argAmount = 1,
	argOne = 'Number',
	placeholder = 'Entry Fee',
	mayorOnly = true
}

-- Row four commands
local fourPos = 1

rowFourCommands[fourPos] = {
	cmd = '/warrant',
	text = 'Search Warrant',
	argAmount = 2,
	argOne = 'Player',
	argTwo = 'Text',
	placeholder = 'Reason',
	cpOnly = true
}

local fourPos = fourPos + 1

rowFourCommands[fourPos] = {
	cmd = '/unwarrant',
	text = 'Remove Warrant',
	argAmount = 1,
	argOne = 'Player',
	cpOnly = true
}

local fourPos = fourPos + 1

rowFourCommands[fourPos] = {
	cmd = '/wanted',
	text = 'Add Wanted',
	argAmount = 2,
	argOne = 'Player',
	argTwo = 'Text',
	placeholder = 'Reason',
	cpOnly = true
}

local fourPos = fourPos + 1

rowFourCommands[fourPos] = {
	cmd = '/unwanted',
	text = 'Remove Wanted',
	argAmount = 1,
	argOne = 'Player',
	cpOnly = true
}

local fourPos = fourPos + 1

rowFourCommands[fourPos] = {
	cmd = '/givelicense',
	text = 'Give License',
	argAmount = 0,
	cpOnly = true
}

local function openCommands()
	if IsValid(essentialDarkRPF4Menu.commandsPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.commandsPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.commandsPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.commandsPanel:Dock(FILL)
	essentialDarkRPF4Menu.commandsPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.commandsPanel:Paint() return end

	local function createArgsPanel(command)
		local mainArgsPanel = vgui.Create('DFrame')
		mainArgsPanel:SetPos(0, 0)
		mainArgsPanel:SetSize(300, 135)
		mainArgsPanel:MakePopup()
		mainArgsPanel:Center()
		mainArgsPanel:SetDraggable(false)
		mainArgsPanel:SizeToContents()
		mainArgsPanel:SetTitle('')
		mainArgsPanel.btnMaxim:Hide()
		mainArgsPanel.btnMinim:Hide()

		function mainArgsPanel.btnClose:Paint(w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawOutlinedRect(0, 0, w, h)

			if self:IsHovered() then
				surface.SetDrawColor(Color(110, 10, 10, 180))
			else
				surface.SetDrawColor(Color(70, 10, 10, 180))
			end

			surface.DrawRect(0, 0, w, h)

			draw.DrawText('x', 'edf_roboto24', 15, -2, white, TEXT_ALIGN_CENTER)
		end

		function mainArgsPanel:Paint(w, h)
			drawBlurPanelOutlined(self, defaultBlur, 3, 8)
		end

		local windowTitle = mainArgsPanel:Add('DLabel')
		windowTitle:SetPos(5, 3)
		windowTitle:SetText(command.text)
		windowTitle:SetFont('edf_roboto20')
		windowTitle:SetTextColor(white)
		windowTitle:SizeToContents()

		-- Forget argument values
		essentialDarkRPF4Menu.argOneVal = ''
		essentialDarkRPF4Menu.argTwoVal = ''
		essentialDarkRPF4Menu.firstArg = ''
		essentialDarkRPF4Menu.secondArg = ''

		if command.argOne == 'Player' then
			local playerBox = mainArgsPanel:Add('DComboBox')
			playerBox:SetPos(5, 5)
			playerBox:SetSize(100, 20)
			playerBox:SetValue('Select Player')
			playerBox:SetTall(25)
			playerBox:Dock(TOP)
			playerBox:DockMargin(0, 10, 0, 0)

			for _, ply in ipairs(player.GetAll()) do
				playerBox:AddChoice(ply:Nick(), ply)
			end

			playerBox.OnSelect = function(panel, index, value)
				buttonClickSound()

				local selectedName, selectedPlayer = playerBox:GetSelected()

				essentialDarkRPF4Menu.argOneVal = selectedPlayer

				if command.argAmount > 1 then
					essentialDarkRPF4Menu.returnArgTwoEntry():RequestFocus()
				end
			end
		else
			local argOneEntry = mainArgsPanel:Add('DTextEntry')
			argOneEntry:SetTall(25)
			argOneEntry:SetPlaceholderText(' ' .. command.placeholder)
			argOneEntry:Dock(BOTTOM)
			argOneEntry:DockMargin(0, 10, 0, 0)
			argOneEntry:RequestFocus()

			argOneEntry.OnChange = function(self)
				essentialDarkRPF4Menu.argOneVal = self:GetValue()
			end

			argOneEntry.OnEnter = function(self)
				essentialDarkRPF4Menu.returnCommandConfirmButton():DoClick()
			end
		end

		if command.argAmount > 1 then
			local argTwoEntry = mainArgsPanel:Add('DTextEntry')
			argTwoEntry:SetTall(25)
			argTwoEntry:SetPlaceholderText(' ' .. command.placeholder)
			argTwoEntry:Dock(BOTTOM)
			argTwoEntry:DockMargin(0, 5, 0, 0)
			argTwoEntry:RequestFocus()

			argTwoEntry.OnChange = function(self)
				essentialDarkRPF4Menu.argTwoVal = self:GetValue()
			end

			argTwoEntry.OnEnter = function(self)
				essentialDarkRPF4Menu.returnCommandConfirmButton():DoClick()
			end

			function essentialDarkRPF4Menu.returnArgTwoEntry()
				if IsValid(argTwoEntry) then
					return argTwoEntry
				end
			end
		end

		local confirmButton = mainArgsPanel:Add('DButton')
		confirmButton:SetTextColor(white)
		confirmButton:SetFont('edf_roboto18')
		confirmButton:SetText('Confirm')
		confirmButton:SetTall(30)
		confirmButton:Dock(BOTTOM)
		confirmButton:DockMargin(0, 5, 0, 0)

		function confirmButton:Paint(w, h)
			drawRectOutlined(0, 0, w, h, essentialDarkRPF4Menu.bgColor2)

			if self:IsHovered() then
				confirmButton:SetTextColor(orange)
			else
				confirmButton:SetTextColor(white)
			end
		end

		function confirmButton.DoClick()
			mainArgsPanel:Remove()
			essentialDarkRPF4Menu.returnMainFrame():Remove()

			if command.argOne == 'Player' then
				if isentity(essentialDarkRPF4Menu.argOneVal) then
					essentialDarkRPF4Menu.firstArg = essentialDarkRPF4Menu.argOneVal:Nick()
				end
			else
				essentialDarkRPF4Menu.firstArg = essentialDarkRPF4Menu.argOneVal
			end

			local secondArg = essentialDarkRPF4Menu.argTwoVal

			if command.argAmount > 1 then
				LocalPlayer():ConCommand('say ' .. command.cmd .. ' \"' .. essentialDarkRPF4Menu.firstArg .. '\" ' .. secondArg)
			else
				RunConsoleCommand('say', command.cmd .. ' ' .. essentialDarkRPF4Menu.firstArg)
			end

			buttonClickSound()
		end

		function essentialDarkRPF4Menu.returnCommandConfirmButton()
			if IsValid(confirmButton) then
				return confirmButton
			end
		end
	end

	-- Create a row of buttons
	local function makeRowOfButtons(tbl, pnl)
		for _, command in ipairs(tbl) do
			if not ((command.mayorOnly and not LocalPlayer():isMayor()) or (command.cpOnly and not LocalPlayer():isCP())) then
				local button = pnl:Add('DButton')
				button:SetTextColor(white)
				button:SetFont('edf_roboto18')
				button:SetText('  ' .. command.text .. '  ')
				button:SizeToContentsX()
				button:Dock(LEFT)
				button:DockMargin(0, 0, 5, 0)

				function button:Paint(w, h)
					drawRectOutlined(0, 0, w, h, defaultBlur)

					if self:IsHovered() then
						button:SetTextColor(orange)
					else
						self:SetTextColor(white)
					end
				end

				function button.DoClick()
					if command.argAmount > 0 then
						createArgsPanel(command)
					else
						RunConsoleCommand('say', command.cmd)
					end

					buttonClickSound()
				end
			end
		end
	end

	-- Row one
	local buttonRowOne = essentialDarkRPF4Menu.commandsPanel:Add('DPanel')
	buttonRowOne:Dock(TOP)
	buttonRowOne:DockMargin(0, 0, 0, 5)
	buttonRowOne:SetTall(35)

	function buttonRowOne:Paint() return end

	makeRowOfButtons(rowOneCommands, buttonRowOne)

	-- Row two
	local buttonRowTwo = essentialDarkRPF4Menu.commandsPanel:Add('DPanel')
	buttonRowTwo:Dock(TOP)
	buttonRowTwo:DockMargin(0, 0, 0, 5)
	buttonRowTwo:SetTall(35)

	function buttonRowTwo:Paint() return end

	makeRowOfButtons(rowTwoCommands, buttonRowTwo)

	-- Row three
	local buttonRowThree = essentialDarkRPF4Menu.commandsPanel:Add('DPanel')
	buttonRowThree:Dock(TOP)
	buttonRowThree:DockMargin(0, 0, 0, 5)
	buttonRowThree:SetTall(35)

	function buttonRowThree:Paint() return end

	-- Hide row if player is not a mayor
	if not LocalPlayer():isMayor() then
		buttonRowThree:SetVisible(false)
	else
		buttonRowThree:SetVisible(true)
		makeRowOfButtons(rowThreeCommands, buttonRowThree)
	end

	-- Row four
	local buttonRowFour = essentialDarkRPF4Menu.commandsPanel:Add('DPanel')
	buttonRowFour:Dock(TOP)
	buttonRowFour:DockMargin(0, 0, 0, 5)
	buttonRowFour:SetTall(35)

	function buttonRowFour:Paint() return end

	makeRowOfButtons(rowFourCommands, buttonRowFour)
end

function essentialDarkRPF4Menu.openCommandsTab()
	openCommands()
end
