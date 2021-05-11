
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

local function openFood()
	if IsValid(essentialDarkRPF4Menu.foodPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.foodPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.foodPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.foodPanel:Dock(FILL)
	essentialDarkRPF4Menu.foodPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.foodPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.foodPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.foodPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	-- Right panel food name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)
	nameLabel:SetText('')

	local function addFoodName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedFood.name)
	end

	-- Right panel model panel
	local modelPanel = rightPanel:Add('DModelPanel')
	modelPanel:SetSize(0, 150)
	modelPanel:Dock(TOP)
	modelPanel:DockMargin(5, 4, 5, 4)
	modelPanel:SetSize(200, 200)
	modelPanel:SetFOV(20)
	modelPanel:SetCamPos(Vector(100, 90, 65))
	modelPanel:SetLookAt(Vector(9, 9, 10))

	local function addFoodModel()
		modelPanel:SetModel(essentialDarkRPF4Menu.selectedFood.model)
	end

	-- Energy panel
	local energyPanel = rightPanel:Add('DPanel')
	energyPanel:SetWide(rightPanel:GetWide())
	energyPanel:Dock(TOP)
	energyPanel:DockMargin(5, 20, 5, 5)

	function energyPanel:Paint() return end

	local energyText = energyPanel:Add('DLabel')
	energyText:Dock(TOP)
	energyText:DockMargin(0, 0, 0, 0)
	energyText:SetFont('edf_roboto20')
	energyText:SetTextColor(white)
	energyText:SetText('')
	energyText:SetContentAlignment(5)

	local function addFoodEnergy()
		energyText:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Energy'] .. ': ' .. essentialDarkRPF4Menu.selectedFood.energy)
	end

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

	local function addFoodPrice()
		descriptionPrice:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Cost'] .. ': ' .. DarkRP.formatMoney(essentialDarkRPF4Menu.selectedFood.price))
	end

	-- Purchase food button
	local purchaseFoodButton = rightPanel:Add('DButton')
	purchaseFoodButton:SetTall(45)
	purchaseFoodButton:Dock(BOTTOM)
	purchaseFoodButton:DockMargin(5, 4, 5, 5)
	purchaseFoodButton:SetFont('edf_roboto20')
	purchaseFoodButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Purchase'])
	purchaseFoodButton:SetTextColor(white)

	function purchaseFoodButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if purchaseFoodButton:IsHovered() then
			purchaseFoodButton:SetTextColor(Color(255, 128, 0))
		else
			purchaseFoodButton:SetTextColor(white)
		end
	end

	-- Forget selected food on creation
	essentialDarkRPF4Menu.selectedFood = nil

	function purchaseFoodButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():RequestFocus()

		RunConsoleCommand('darkrp', 'buyfood', essentialDarkRPF4Menu.selectedFood.name)
	end

	-- Food list panel
	local foodListPanel = essentialDarkRPF4Menu.foodPanel:Add('DScrollPanel')
	foodListPanel:SetSize(essentialDarkRPF4Menu.foodPanel:GetWide(), essentialDarkRPF4Menu.foodPanel:GetTall())
	foodListPanel:Dock(TOP)
	foodListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = foodListPanel:GetVBar()
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

	for _, food in ipairs(FoodItems) do
		essentialDarkRPF4Menu.displayItem = true

		-- Hide job and group restricted food
		-- if essentialDarkRPF4Menu.hideRestrictedFood then
			if istable(food.allowed) and not table.HasValue(food.allowed, LocalPlayer():Team()) then
				essentialDarkRPF4Menu.displayItem = false
			end

			if food.customCheck and not food.customCheck(LocalPlayer()) then
				essentialDarkRPF4Menu.displayItem = false
			end

			if food.canSee and not food.canSee(LocalPlayer()) then
				essentialDarkRPF4Menu.displayItem = false
			end
		-- end

		if essentialDarkRPF4Menu.displayItem then
			table.insert(validItems, food)

			essentialDarkRPF4Menu.selectedFood = food

			-- Add food category
			local foodCat = 'Food'

			if not IsValid(foodListPanel[foodCat]) then
				foodListPanel[foodCat] = foodListPanel:Add('DCollapsibleCategory')

				local foodCatPanel = foodListPanel[foodCat]

				foodCatPanel:Dock(TOP)
				foodCatPanel:DockMargin(0, 0, 5, 3)
				foodCatPanel:SetLabel(foodCat)
				foodCatPanel:SetAnimTime(0.1)
				foodCatPanel:GetChildren()[1]:SetTall(35)

				function foodCatPanel:Paint() return end

				foodCatPanel.Header:SetTextColor(white)
				foodCatPanel.Header:SetFont('edf_roboto20')

				function foodCatPanel.Header:Paint(w, h)
					local categoryColor = essentialDarkRPF4Menu.defaultCategoryColor

					surface.SetDrawColor(defaultBlurOutline)
					surface.DrawOutlinedRect(0, 0, w, h)

					surface.SetDrawColor(categoryColor)
					surface.DrawRect(1, 1, w - 2, h - 2)
				end

				-- Add panel containing the food contents to category
				foodCatPanel.catContentsPanel = vgui.Create('DPanel')
				foodCatPanel.catContentsPanel:SizeToContents()

				function foodCatPanel.catContentsPanel:Paint() return end

				foodCatPanel:SetContents(foodCatPanel.catContentsPanel)
			end

			local foodCatPanel = foodListPanel[foodCat]

			-- Add food to category contents panel
			local foodButton = foodCatPanel.catContentsPanel:Add('DButton')
			foodButton:SetText('')
			foodButton:SetSize(0, 66)
			foodButton:Dock(TOP)
			foodButton:DockMargin(0, 3, 0, 0)

			function foodButton:Paint()
				drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
			end

			function foodButton.DoClick()
				essentialDarkRPF4Menu.selectedFood = food

				-- Add stuff to right panel
				addFoodName()
				addFoodModel()
				addFoodEnergy()
				addFoodPrice()

				buttonClickSound()
			end

			function foodButton.DoDoubleClick()
				if IsValid(purchaseFoodButton) then
					purchaseFoodButton:DoClick()
				end
			end

			local foodModel = foodButton:Add('SpawnIcon')
			foodModel:SetSize(64, 0)
			foodModel:Dock(LEFT)
			foodModel:DockMargin(1, 1, 1, 1)
			foodModel:SetModel(food.model)

			function foodModel.DoClick()
				foodButton:DoClick()
			end

			local foodName = foodButton:Add('DLabel')
			foodName:Dock(LEFT)
			foodName:DockMargin(6, 0, 0, 0)
			foodName:SetText(food.name)
			foodName:SetFont('edf_roboto20')
			foodName:SetTextColor(white)
			foodName:SizeToContentsX()

			local pricePanel = foodButton:Add('DPanel')
			pricePanel:Dock(RIGHT)
			pricePanel:DockMargin(0, 0, 5, 0)
			pricePanel:SizeToContentsX()

			function pricePanel.Paint(w, h)
				draw.RoundedBox(28.49, 5, 5, pricePanel:GetTall() - 8, pricePanel:GetWide() - 8, Color(10, 10, 10, 120))
			end

			function pricePanel:OnMousePressed()
				foodButton:DoClick()
			end

			-- Food price
			local foodPrice = pricePanel:Add('DLabel')
			foodPrice:Dock(FILL)
			foodPrice:DockMargin(0, 0, 0, 0)
			foodPrice:SetText('$' .. food.price)

			if food.price < 1000 then
				foodPrice:SetFont('edf_roboto20')
			elseif food.price < 100000 then
				foodPrice:SetFont('edf_roboto18')
			else
				foodPrice:SetFont('edf_roboto16')
			end

			foodPrice:SetContentAlignment(5)
			foodPrice:SetTextColor(white)

			-- Add initial stuff to right panel
			addFoodName()
			addFoodModel()
			addFoodEnergy()
			addFoodPrice()
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.foodPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openFoodTab()
	if DarkRP.disabledDefaults['modules']['hungermod'] then return end

	openFood()
end
