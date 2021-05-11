
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

local function openAmmo()
	if IsValid(essentialDarkRPF4Menu.ammoPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.ammoPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.ammoPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.ammoPanel:Dock(FILL)
	essentialDarkRPF4Menu.ammoPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.ammoPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.ammoPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.ammoPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	-- Right panel ammo name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)
	nameLabel:SetText('')

	local function addAmmoName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedAmmo.name)
	end

	-- Right panel model panel
	local modelPanel = rightPanel:Add('DModelPanel')
	modelPanel:SetSize(0, 150)
	modelPanel:Dock(TOP)
	modelPanel:DockMargin(5, 4, 5, 4)
	modelPanel:SetSize(200, 200)
	modelPanel:SetFOV(25)
	modelPanel:SetCamPos(Vector(100, 90, 65))
	modelPanel:SetLookAt(Vector(9, 9, 13))

	local function addAmmoModel()
		modelPanel:SetModel(essentialDarkRPF4Menu.selectedAmmo.model)
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

	local function addAmmoPrice()
		descriptionPrice:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Cost'] .. ': ' .. DarkRP.formatMoney(essentialDarkRPF4Menu.selectedAmmo.price))
	end

	-- Purchase ammo button
	local purchaseAmmoButton = rightPanel:Add('DButton')
	purchaseAmmoButton:SetTall(45)
	purchaseAmmoButton:Dock(BOTTOM)
	purchaseAmmoButton:DockMargin(5, 4, 5, 5)
	purchaseAmmoButton:SetFont('edf_roboto20')
	purchaseAmmoButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Purchase'])
	purchaseAmmoButton:SetTextColor(white)

	function purchaseAmmoButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if purchaseAmmoButton:IsHovered() then
			purchaseAmmoButton:SetTextColor(Color(255, 128, 0))
		else
			purchaseAmmoButton:SetTextColor(white)
		end
	end

	-- Forget selected ammo on creation
	essentialDarkRPF4Menu.selectedAmmo = nil

	function purchaseAmmoButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():RequestFocus()

		RunConsoleCommand('darkrp', 'buyammo', essentialDarkRPF4Menu.selectedAmmo.ammoType)
	end

	-- Ammo list panel
	local ammoListPanel = essentialDarkRPF4Menu.ammoPanel:Add('DScrollPanel')
	ammoListPanel:SetSize(essentialDarkRPF4Menu.ammoPanel:GetWide(), essentialDarkRPF4Menu.ammoPanel:GetTall())
	ammoListPanel:Dock(TOP)
	ammoListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = ammoListPanel:GetVBar()
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

	for _, ammo in ipairs(GAMEMODE.AmmoTypes) do
		essentialDarkRPF4Menu.displayItem = true

		-- Hide job and group restricted ammo
		-- if essentialDarkRPF4Menu.hideRestrictedAmmo then
			if istable(ammo.allowed) and not table.HasValue(ammo.allowed, LocalPlayer():Team()) then
				essentialDarkRPF4Menu.displayItem = false
			end

			if ammo.customCheck and not ammo.customCheck(LocalPlayer()) then
				essentialDarkRPF4Menu.displayItem = false
			end

			if ammo.canSee and not ammo.canSee(LocalPlayer()) then
				essentialDarkRPF4Menu.displayItem = false
			end
		-- end

		if essentialDarkRPF4Menu.displayItem then
			table.insert(validItems, ammo)

			essentialDarkRPF4Menu.selectedAmmo = ammo

			local ammoCat = ammo.category

			-- Add non-existing categories
			if not IsValid(ammoListPanel[ammoCat]) then
				ammoListPanel[ammoCat] = ammoListPanel:Add('DCollapsibleCategory')

				local ammoCatPanel = ammoListPanel[ammoCat]

				ammoCatPanel:Dock(TOP)
				ammoCatPanel:DockMargin(0, 0, 5, 3)
				ammoCatPanel:SetLabel(ammo.category)
				ammoCatPanel:SetAnimTime(0.1)
				ammoCatPanel:GetChildren()[1]:SetTall(35)

				function ammoCatPanel:Paint() return end

				ammoCatPanel.Header:SetTextColor(white)
				ammoCatPanel.Header:SetFont('edf_roboto20')

				function ammoCatPanel.Header:Paint(w, h)
					local categoryColor = self.color or essentialDarkRPF4Menu.defaultCategoryColor

					surface.SetDrawColor(defaultBlurOutline)
					surface.DrawOutlinedRect(0, 0, w, h)

					surface.SetDrawColor(categoryColor)
					surface.DrawRect(1, 1, w - 2, h - 2)
				end

				-- Add panel containing the ammo contents to category
				ammoCatPanel.catContentsPanel = vgui.Create('DPanel')
				ammoCatPanel.catContentsPanel:SizeToContents()

				function ammoCatPanel.catContentsPanel:Paint() return end

				ammoCatPanel:SetContents(ammoCatPanel.catContentsPanel)
			end

			local ammoCatPanel = ammoListPanel[ammoCat]

			local ammoCategories = DarkRP.getCategories().ammo

			for _, category in ipairs(ammoCategories) do
				if ammoCat == category.name then
					ammoCatPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
				end
			end

			-- Add ammo to category contents panel
			local ammoButton = ammoCatPanel.catContentsPanel:Add('DButton')
			ammoButton:SetText('')
			ammoButton:SetSize(0, 66)
			ammoButton:Dock(TOP)
			ammoButton:DockMargin(0, 3, 0, 0)

			function ammoButton:Paint()
				drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
			end

			function ammoButton.DoClick()
				essentialDarkRPF4Menu.selectedAmmo = ammo

				-- Add stuff to right panel
				addAmmoName()
				addAmmoModel()
				addAmmoPrice()

				buttonClickSound()
			end

			function ammoButton.DoDoubleClick()
				if IsValid(purchaseAmmoButton) then
					purchaseAmmoButton:DoClick()
				end
			end

			local ammoModel = ammoButton:Add('SpawnIcon')
			ammoModel:SetSize(64, 0)
			ammoModel:Dock(LEFT)
			ammoModel:DockMargin(1, 1, 1, 1)
			ammoModel:SetModel(ammo.model)

			function ammoModel.DoClick()
				ammoButton:DoClick()
			end

			local ammoName = ammoButton:Add('DLabel')
			ammoName:Dock(LEFT)
			ammoName:DockMargin(6, 0, 0, 0)
			ammoName:SetText(ammo.name)
			ammoName:SetFont('edf_roboto20')
			ammoName:SetTextColor(white)
			ammoName:SizeToContentsX()

			local pricePanel = ammoButton:Add('DPanel')
			pricePanel:Dock(RIGHT)
			pricePanel:DockMargin(0, 0, 5, 0)
			pricePanel:SizeToContentsX()

			function pricePanel.Paint(w, h)
				draw.RoundedBox(28.49, 5, 5, pricePanel:GetTall() - 8, pricePanel:GetWide() - 8, Color(10, 10, 10, 120))
			end

			function pricePanel:OnMousePressed()
				ammoButton:DoClick()
			end

			-- Ammo price
			local ammoPrice = pricePanel:Add('DLabel')
			ammoPrice:Dock(FILL)
			ammoPrice:DockMargin(0, 0, 0, 0)
			ammoPrice:SetText('$' .. ammo.price)

			if ammo.price < 1000 then
				ammoPrice:SetFont('edf_roboto20')
			elseif ammo.price < 100000 then
				ammoPrice:SetFont('edf_roboto18')
			else
				ammoPrice:SetFont('edf_roboto16')
			end

			ammoPrice:SetContentAlignment(5)
			ammoPrice:SetTextColor(white)

			-- Add initial stuff to right panel
			addAmmoName()
			addAmmoModel()
			addAmmoPrice()
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.ammoPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openAmmoTab()
	openAmmo()
end
