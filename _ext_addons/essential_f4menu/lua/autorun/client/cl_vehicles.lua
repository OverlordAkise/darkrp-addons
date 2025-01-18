
essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}

local white = Color(255, 255, 255)
local black = Color(0, 0, 0)

local defaultBlur = Color(10, 10, 10, 160)
local defaultBlurOutline = Color(20, 20, 20, 210)

local function buttonClickSound()
	surface.PlaySound('ui/buttonclick.wav')
end

-- Draw normal outlined (non-blurred) rectangle in paint hook
local function drawRectOutlined(xpos, ypos, width, height, color)
	surface.SetDrawColor(color)
	surface.DrawRect(xpos + 1, ypos + 1, width - 2, height - 2)

	surface.SetDrawColor(defaultBlurOutline)
	surface.DrawOutlinedRect(xpos, ypos, width, height)
end

local function openVehicles()
	if IsValid(essentialDarkRPF4Menu.vehiclesPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.vehiclesPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.vehiclesPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.vehiclesPanel:Dock(FILL)
	essentialDarkRPF4Menu.vehiclesPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.vehiclesPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.vehiclesPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.vehiclesPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	-- Right vehicle name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)
	nameLabel:SetText('')

	local function addVehicleName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedVehicle.name)
	end

	-- Right panel model panel
	local modelPanel = rightPanel:Add('DModelPanel')
	modelPanel:SetSize(0, 150)
	modelPanel:Dock(TOP)
	modelPanel:DockMargin(5, 4, 5, 4)
	modelPanel:SetSize(200, 200)
	modelPanel:SetFOV(49)
	modelPanel:SetCamPos(Vector(325, 90, 65))
	modelPanel:SetLookAt(Vector(9, 9, 45))

	local function addVehicleModel()
		modelPanel:SetModel(essentialDarkRPF4Menu.selectedVehicle.model)
	end

	-- Right panel price panel
	local descriptionPricePanel = rightPanel:Add('DPanel')
	descriptionPricePanel:SetWide(rightPanel:GetWide())
	descriptionPricePanel:Dock(TOP)
	descriptionPricePanel:DockMargin(5, 20, 5, 5)

	function descriptionPricePanel:Paint() return end

	local descriptionPrice = descriptionPricePanel:Add('DLabel')
	descriptionPrice:Dock(TOP)
	descriptionPrice:DockMargin(0, 0, 0, 0)
	descriptionPrice:SetFont('edf_roboto20')
	descriptionPrice:SetTextColor(white)
	descriptionPrice:SetText('')
	descriptionPrice:SetContentAlignment(5)

	local function addVehiclePrice()
		descriptionPrice:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Cost'] .. ': ' .. DarkRP.formatMoney(essentialDarkRPF4Menu.selectedVehicle.price))
	end

	-- Purchase vehicle button
	local purchaseVehicleButton = rightPanel:Add('DButton')
	purchaseVehicleButton:SetTall(45)
	purchaseVehicleButton:Dock(BOTTOM)
	purchaseVehicleButton:DockMargin(5, 4, 5, 5)
	purchaseVehicleButton:SetFont('edf_roboto20')
	purchaseVehicleButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Purchase'])
	purchaseVehicleButton:SetTextColor(white)

	function purchaseVehicleButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if purchaseVehicleButton:IsHovered() then
			purchaseVehicleButton:SetTextColor(Color(255, 128, 0))
		else
			purchaseVehicleButton:SetTextColor(white)
		end
	end

	-- Forget selected vehicle on creation
	essentialDarkRPF4Menu.selectedVehicle = nil

	function purchaseVehicleButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():RequestFocus()

		RunConsoleCommand('say', '/buyvehicle ' .. essentialDarkRPF4Menu.selectedVehicle.name)
	end

	-- Vehicle list panel
	local vehicleListPanel = essentialDarkRPF4Menu.vehiclesPanel:Add('DScrollPanel')
	vehicleListPanel:SetSize(essentialDarkRPF4Menu.vehiclesPanel:GetWide(), essentialDarkRPF4Menu.vehiclesPanel:GetTall())
	vehicleListPanel:Dock(TOP)
	vehicleListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = vehicleListPanel:GetVBar()
	scrollBar:DockMargin(0, 0, 0, 0)

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

	local validItems = {}
	local localplayer = LocalPlayer()
	local localplayer_team = localplayer:Team()
	for _, vehicle in ipairs(CustomVehicles) do
		essentialDarkRPF4Menu.displayItem = true

		-- Hide job and group restricted vehicles
		-- if essentialDarkRPF4Menu.hideRestrictedVehicles then
			if (istable(vehicle.allowed) and not table.HasValue(vehicle.allowed, localplayer_team)) or (vehicle.customCheck and not vehicle.customCheck(localplayer)) or (vehicle.canSee and not vehicle.canSee(localplayer)) then
				essentialDarkRPF4Menu.displayItem = false
			end
		-- end

		if essentialDarkRPF4Menu.displayItem then
			table.insert(validItems, vehicle)

			essentialDarkRPF4Menu.selectedVehicle = vehicle

			local vehicleCat = vehicle.category

			-- Add non-existing categories
			if not IsValid(vehicleListPanel[vehicleCat]) then
				vehicleListPanel[vehicleCat] = vehicleListPanel:Add('DCollapsibleCategory')

				local vehicleCatPanel = vehicleListPanel[vehicleCat]

				vehicleCatPanel:Dock(TOP)
				vehicleCatPanel:DockMargin(0, 0, 5, 3)
				vehicleCatPanel:SetLabel(vehicle.category)
				vehicleCatPanel:SetAnimTime(0.1)
				vehicleCatPanel:GetChildren()[1]:SetTall(35)

				function vehicleCatPanel:Paint() return end

				vehicleCatPanel.Header:SetTextColor(white)
				vehicleCatPanel.Header:SetFont('edf_roboto20')

				function vehicleCatPanel.Header:Paint(w, h)
					local categoryColor = self.color or essentialDarkRPF4Menu.defaultCategoryColor

					surface.SetDrawColor(defaultBlurOutline)
					surface.DrawOutlinedRect(0, 0, w, h)

					surface.SetDrawColor(categoryColor)
					surface.DrawRect(1, 1, w - 2, h - 2)
				end

				-- Add panel containing the vehicle contents to category
				vehicleCatPanel.catContentsPanel = vgui.Create('DPanel')
				vehicleCatPanel.catContentsPanel:SizeToContents()

				function vehicleCatPanel.catContentsPanel:Paint() return end

				vehicleCatPanel:SetContents(vehicleCatPanel.catContentsPanel)
			end

			local vehicleCatPanel = vehicleListPanel[vehicleCat]

			local vehicleCategories = DarkRP.getCategories().vehicles

			for _, category in ipairs(vehicleCategories) do
				if vehicleCat == category.name then
					vehicleCatPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
				end
			end

			-- Add vehicle to category contents panel
			local vehicleButton = vehicleCatPanel.catContentsPanel:Add('DButton')
			vehicleButton:SetText('')
			vehicleButton:SetSize(0, 66)
			vehicleButton:Dock(TOP)
			vehicleButton:DockMargin(0, 3, 0, 0)

			function vehicleButton:Paint()
				drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
			end

			function vehicleButton.DoClick()
				essentialDarkRPF4Menu.selectedVehicle = vehicle

				-- Add stuff to right panel
				addVehicleName()
				addVehicleModel()
				addVehiclePrice()

				buttonClickSound()
			end

			function vehicleButton.DoDoubleClick()
				if IsValid(purchaseVehicleButton) then
					purchaseVehicleButton:DoClick()
				end
			end

			local vehicleModel = vehicleButton:Add('SpawnIcon')
			vehicleModel:SetSize(64, 0)
			vehicleModel:Dock(LEFT)
			vehicleModel:DockMargin(1, 1, 1, 1)
			vehicleModel:SetModel(vehicle.model)

			function vehicleModel.DoClick()
				vehicleButton:DoClick()
			end

			local vehicleName = vehicleButton:Add('DLabel')
			vehicleName:Dock(LEFT)
			vehicleName:DockMargin(6, 0, 0, 0)
			vehicleName:SetText(vehicle.name)
			vehicleName:SetFont('edf_roboto20')
			vehicleName:SetTextColor(white)
			vehicleName:SizeToContentsX()

			local pricePanel = vehicleButton:Add('DPanel')
			pricePanel:Dock(RIGHT)
			pricePanel:DockMargin(0, 0, 5, 0)
			pricePanel:SizeToContentsX()

			function pricePanel.Paint(w, h)
				draw.RoundedBox(28.49, 5, 5, pricePanel:GetTall() - 8, pricePanel:GetWide() - 8, Color(10, 10, 10, 120))
			end

			function pricePanel:OnMousePressed()
				vehicleButton:DoClick()
			end

			-- Vehicle price
			local vehiclePrice = pricePanel:Add('DLabel')
			vehiclePrice:Dock(FILL)
			vehiclePrice:DockMargin(0, 0, 0, 0)
			vehiclePrice:SetText('$' .. vehicle.price)

			if vehicle.price < 1000 then
				vehiclePrice:SetFont('edf_roboto20')
			elseif vehicle.price < 100000 then
				vehiclePrice:SetFont('edf_roboto18')
			else
				vehiclePrice:SetFont('edf_roboto16')
			end

			vehiclePrice:SetContentAlignment(5)
			vehiclePrice:SetTextColor(white)

			-- Add initial stuff to right panel
			addVehicleName()
			addVehicleModel()
			addVehiclePrice()
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.vehiclesPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openVehiclesTab()
	openVehicles()
end
