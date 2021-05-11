
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

local function openShipments()
	if IsValid(essentialDarkRPF4Menu.shipmentsPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.shipmentsPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.shipmentsPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.shipmentsPanel:Dock(FILL)
	essentialDarkRPF4Menu.shipmentsPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.shipmentsPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.shipmentsPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.shipmentsPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	-- Right panel shipment name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)
	nameLabel:SetText('')

	local function addShipmentName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedShipment.name)
	end

	-- Right panel model panel
	local modelPanel = rightPanel:Add('DModelPanel')
	modelPanel:SetSize(0, 150)
	modelPanel:Dock(TOP)
	modelPanel:DockMargin(5, 4, 5, 4)
	modelPanel:SetSize(200, 200)
	modelPanel:SetFOV(27)
	modelPanel:SetCamPos(Vector(100, 90, 65))
	modelPanel:SetLookAt(Vector(9, 9, 17))

	local function addShipmentModel()
		modelPanel:SetModel(essentialDarkRPF4Menu.selectedShipment.shipmodel)
	end

	-- Right panel shipment type panel
	local descriptionTypePanel = rightPanel:Add('DPanel')
	descriptionTypePanel:SetWide(rightPanel:GetWide())
	descriptionTypePanel:Dock(TOP)
	descriptionTypePanel:DockMargin(5, 20, 5, 5)

	function descriptionTypePanel:Paint() return end

	local descriptionType = descriptionTypePanel:Add('DLabel')
	descriptionType:Dock(TOP)
	descriptionType:DockMargin(0, 0, 0, 0)
	descriptionType:SetFont('edf_roboto20')
	descriptionType:SetTextColor(white)
	descriptionType:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Shipment'])
	descriptionType:SetContentAlignment(5)

	-- Right panel price panel
	local descriptionPricePanel = rightPanel:Add('DPanel')
	descriptionPricePanel:SetWide(rightPanel:GetWide())
	descriptionPricePanel:Dock(TOP)
	descriptionPricePanel:DockMargin(5, 0, 5, 5)

	function descriptionPricePanel:Paint() return end

	descriptionPrice = descriptionPricePanel:Add('DLabel')
	descriptionPrice:Dock(TOP)
	descriptionPrice:DockMargin(0, 0, 0, 0)
	descriptionPrice:SetFont('edf_roboto20')
	descriptionPrice:SetTextColor(white)
	descriptionPrice:SetText('')
	descriptionPrice:SetContentAlignment(5)

	local function addShipmentPrice()
		descriptionPrice:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Cost'] .. ': ' .. DarkRP.formatMoney(essentialDarkRPF4Menu.selectedShipment.price))
	end

	-- Right panel amount panel
	local descriptionAmountPanel = rightPanel:Add('DPanel')
	descriptionAmountPanel:SetWide(rightPanel:GetWide())
	descriptionAmountPanel:Dock(TOP)
	descriptionAmountPanel:DockMargin(5, 0, 5, 5)

	function descriptionAmountPanel:Paint() return end

	descriptionAmount = descriptionAmountPanel:Add('DLabel')
	descriptionAmount:Dock(TOP)
	descriptionAmount:DockMargin(0, 0, 0, 0)
	descriptionAmount:SetFont('edf_roboto20')
	descriptionAmount:SetTextColor(white)
	descriptionAmount:SetText('')
	descriptionAmount:SetContentAlignment(5)

	local function addShipmentAmount()
		descriptionAmount:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Holds'] .. ': ' .. essentialDarkRPF4Menu.selectedShipment.amount)
	end

	-- Purchase shipment button
	local purchaseShipmentButton = rightPanel:Add('DButton')
	purchaseShipmentButton:SetTall(45)
	purchaseShipmentButton:Dock(BOTTOM)
	purchaseShipmentButton:DockMargin(5, 4, 5, 5)
	purchaseShipmentButton:SetFont('edf_roboto20')
	purchaseShipmentButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Purchase'])
	purchaseShipmentButton:SetTextColor(white)

	function purchaseShipmentButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if purchaseShipmentButton:IsHovered() then
			purchaseShipmentButton:SetTextColor(Color(255, 128, 0))
		else
			purchaseShipmentButton:SetTextColor(white)
		end
	end

	-- Forget selected shipment on creation
	essentialDarkRPF4Menu.selectedShipment = nil

	function purchaseShipmentButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():RequestFocus()

		RunConsoleCommand('darkrp', 'buyshipment', essentialDarkRPF4Menu.selectedShipment.name)
	end

	-- Shipments list panel
	local shipmentsListPanel = essentialDarkRPF4Menu.shipmentsPanel:Add('DScrollPanel')
	shipmentsListPanel:SetSize(essentialDarkRPF4Menu.shipmentsPanel:GetWide(), essentialDarkRPF4Menu.shipmentsPanel:GetTall())
	shipmentsListPanel:Dock(TOP)
	shipmentsListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = shipmentsListPanel:GetVBar()
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

	for _, shipment in ipairs(CustomShipments) do
		if not shipment.noship then
			essentialDarkRPF4Menu.displayItem = true

			-- Hide job and group restricted shipments
			-- if essentialDarkRPF4Menu.hideRestrictedShipments then
				if istable(shipment.allowed) and not table.HasValue(shipment.allowed, LocalPlayer():Team()) then
					essentialDarkRPF4Menu.displayItem = false
				end

				if shipment.customCheck and not shipment.customCheck(LocalPlayer()) then
					essentialDarkRPF4Menu.displayItem = false
				end

				if shipment.canSee and not shipment.canSee(LocalPlayer()) then
					essentialDarkRPF4Menu.displayItem = false
				end
			-- end

			if essentialDarkRPF4Menu.displayItem then
				table.insert(validItems, shipment)

				essentialDarkRPF4Menu.selectedShipment = shipment

				local shipmentCat = shipment.category

				-- Add non-existing categories
				if not IsValid(shipmentsListPanel[shipmentCat]) then
					shipmentsListPanel[shipmentCat] = shipmentsListPanel:Add('DCollapsibleCategory')

					local shipmentCatPanel = shipmentsListPanel[shipmentCat]

					shipmentCatPanel:Dock(TOP)
					shipmentCatPanel:DockMargin(0, 0, 5, 3)
					shipmentCatPanel:SetLabel(shipment.category)
					shipmentCatPanel:SetAnimTime(0.1)
					shipmentCatPanel:GetChildren()[1]:SetTall(35)

					function shipmentCatPanel:Paint() return end

					shipmentCatPanel.Header:SetTextColor(white)
					shipmentCatPanel.Header:SetFont('edf_roboto20')

					function shipmentCatPanel.Header:Paint(w, h)
						local categoryColor = self.color or essentialDarkRPF4Menu.defaultCategoryColor

						surface.SetDrawColor(defaultBlurOutline)
						surface.DrawOutlinedRect(0, 0, w, h)

						surface.SetDrawColor(categoryColor)
						surface.DrawRect(1, 1, w - 2, h - 2)
					end

					-- Add panel containing the shipment contents to category
					shipmentCatPanel.catContentsPanel = vgui.Create('DPanel')
					shipmentCatPanel.catContentsPanel:SizeToContents()

					function shipmentCatPanel.catContentsPanel:Paint() return end

					shipmentCatPanel:SetContents(shipmentCatPanel.catContentsPanel)
				end

				local shipmentCatPanel = shipmentsListPanel[shipmentCat]

				local shipmentCategories = DarkRP.getCategories().shipments

				for _, category in ipairs(shipmentCategories) do
					if shipmentCat == category.name then
						shipmentCatPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
					end
				end

				-- Add shipments to category contents panel
				local shipmentButton = shipmentCatPanel.catContentsPanel:Add('DButton')
				shipmentButton:SetText('')
				shipmentButton:SetSize(0, 66)
				shipmentButton:Dock(TOP)
				shipmentButton:DockMargin(0, 3, 0, 0)

				function shipmentButton:Paint()
					drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
				end

				function shipmentButton.DoClick()
					essentialDarkRPF4Menu.selectedShipment = shipment

					-- Add stuff to right panel
					addShipmentName()
					addShipmentModel()
					addShipmentAmount()
					addShipmentPrice()

					buttonClickSound()
				end

				function shipmentButton.DoDoubleClick()
					if IsValid(purchaseShipmentButton) then
						purchaseShipmentButton:DoClick()
					end
				end

				local shipmentModel = shipmentButton:Add('SpawnIcon')
				shipmentModel:SetSize(64, 0)
				shipmentModel:Dock(LEFT)
				shipmentModel:DockMargin(1, 1, 1, 1)
				shipmentModel:SetModel(shipment.model)

				function shipmentModel.DoClick()
					shipmentButton:DoClick()
				end

				local shipmentName = shipmentButton:Add('DLabel')
				shipmentName:Dock(LEFT)
				shipmentName:DockMargin(6, 0, 0, 0)
				shipmentName:SetText(shipment.name)
				shipmentName:SetFont('edf_roboto20')
				shipmentName:SetTextColor(white)
				shipmentName:SizeToContentsX()

				local pricePanel = shipmentButton:Add('DPanel')
				pricePanel:Dock(RIGHT)
				pricePanel:DockMargin(0, 0, 5, 0)
				pricePanel:SizeToContentsX()

				function pricePanel.Paint(w, h)
					draw.RoundedBox(28.49, 5, 5, pricePanel:GetTall() - 8, pricePanel:GetWide() - 8, Color(10, 10, 10, 120))
				end

				function pricePanel:OnMousePressed()
					shipmentButton:DoClick()
				end

				-- Shipment price
				local shipmentPrice = pricePanel:Add('DLabel')
				shipmentPrice:Dock(FILL)
				shipmentPrice:DockMargin(0, 0, 0, 0)

				shipmentPrice:DockMargin(0, 0, 0, 0)
				shipmentPrice:SetText('$' .. shipment.price)

				if shipment.price < 1000 then
					shipmentPrice:SetFont('edf_roboto20')
				elseif shipment.price < 100000 then
					shipmentPrice:SetFont('edf_roboto18')
				else
					shipmentPrice:SetFont('edf_roboto16')
				end

				shipmentPrice:SetContentAlignment(5)
				shipmentPrice:SetTextColor(white)

				-- Add initial stuff to right panel
				addShipmentName()
				addShipmentModel()
				addShipmentAmount()
				addShipmentPrice()
			end
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.shipmentsPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openShipmentsTab()
	openShipments()
end
