
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

local function openWeapons()
	if IsValid(essentialDarkRPF4Menu.weaponsPanel) then return end

	local midPanel = essentialDarkRPF4Menu.returnMidPanel()

	-- Panel to parent all tab content to
	essentialDarkRPF4Menu.weaponsPanel = midPanel:Add('DPanel')
	essentialDarkRPF4Menu.weaponsPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
	essentialDarkRPF4Menu.weaponsPanel:Dock(FILL)
	essentialDarkRPF4Menu.weaponsPanel:DockMargin(0, 0, 0, 0)

	function essentialDarkRPF4Menu.weaponsPanel:Paint() return end

	-- Right panel
	local rightPanel = essentialDarkRPF4Menu.weaponsPanel:Add('DPanel')
	rightPanel:SetSize(270, essentialDarkRPF4Menu.weaponsPanel:GetTall())
	rightPanel:Dock(RIGHT)
	rightPanel:DockMargin(0, 0, 0, 0)

	function rightPanel:Paint(w, h)
		surface.SetDrawColor(defaultBlurOutline)
		surface.DrawOutlinedRect(0, 0, w, h)

		surface.SetDrawColor(essentialDarkRPF4Menu.bgColor1)
		surface.DrawRect(1, 1, w - 2, h - 2)
	end

	-- Right panel weapon name
	local nameLabel = rightPanel:Add('DLabel')
	nameLabel:SetTall(30)
	nameLabel:Dock(TOP)
	nameLabel:DockMargin(5, 4, 5, 0)
	nameLabel:SetFont('edf_roboto20')
	nameLabel:SetTextColor(white)
	nameLabel:SetContentAlignment(5)
	nameLabel:SetText('')

	local function addWeaponName()
		nameLabel:SetText(essentialDarkRPF4Menu.selectedWeapon.name)
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

	local function addWeaponModel()
		modelPanel:SetModel(essentialDarkRPF4Menu.selectedWeapon.model)
	end

	-- Right panel weapon type panel
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
	descriptionType:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Separate'])
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

	local function addWeaponPrice()
		descriptionPrice:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Cost'] .. ': ' .. DarkRP.formatMoney(essentialDarkRPF4Menu.selectedWeapon.pricesep))
	end

	-- Purchase weapon button
	local purchaseWeaponButton = rightPanel:Add('DButton')
	purchaseWeaponButton:SetTall(45)
	purchaseWeaponButton:Dock(BOTTOM)
	purchaseWeaponButton:DockMargin(5, 4, 5, 5)
	purchaseWeaponButton:SetFont('edf_roboto20')
	purchaseWeaponButton:SetTextColor(white)
	purchaseWeaponButton:SetText(essentialDarkRPF4Menu.settings.languages[essentialDarkRPF4Menu.settings.displayLanguage]['Purchase'])

	function purchaseWeaponButton:Paint(w, h)
		drawRectOutlined(0, 0, w, h, defaultBlur)

		if purchaseWeaponButton:IsHovered() then
			purchaseWeaponButton:SetTextColor(Color(255, 128, 0))
		else
			purchaseWeaponButton:SetTextColor(white)
		end
	end

	-- Forget selected weapon on creation
	essentialDarkRPF4Menu.selectedWeapon = nil

	function purchaseWeaponButton.DoClick()
		essentialDarkRPF4Menu.returnMainFrame():RequestFocus()

		RunConsoleCommand('darkrp', 'buy', essentialDarkRPF4Menu.selectedWeapon.name)
	end

	-- Weapons list panel
	local weaponsListPanel = essentialDarkRPF4Menu.weaponsPanel:Add('DScrollPanel')
	weaponsListPanel:SetSize(essentialDarkRPF4Menu.weaponsPanel:GetWide(), essentialDarkRPF4Menu.weaponsPanel:GetTall())
	weaponsListPanel:Dock(TOP)
	weaponsListPanel:DockMargin(0, 0, 5, 0)

	local scrollBar = weaponsListPanel:GetVBar()
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
	for _, weapon in ipairs(CustomShipments) do
		if weapon.separate then
			essentialDarkRPF4Menu.displayItem = true

			-- Hide job and group restricted weapons
			-- if essentialDarkRPF4Menu.hideRestrictedWeapons then
				if (istable(weapon.allowed) and not table.HasValue(weapon.allowed, localplayer_team)) or (weapon.customCheck and not weapon.customCheck(localplayer)) or (weapon.canSee and not weapon.canSee(localplayer)) then
					essentialDarkRPF4Menu.displayItem = false
				end
			-- end

			if essentialDarkRPF4Menu.displayItem then
				table.insert(validItems, weapon)

				essentialDarkRPF4Menu.selectedWeapon = weapon

				local weaponCat = weapon.category

				-- Add non-existing categories
				if not IsValid(weaponsListPanel[weaponCat]) then
					weaponsListPanel[weaponCat] = weaponsListPanel:Add('DCollapsibleCategory')

					local weaponCatPanel = weaponsListPanel[weaponCat]

					weaponCatPanel:Dock(TOP)
					weaponCatPanel:DockMargin(0, 0, 5, 3)
					weaponCatPanel:SetLabel(weapon.category)
					weaponCatPanel:SetAnimTime(0.1)
					weaponCatPanel:GetChildren()[1]:SetTall(35)

					function weaponCatPanel:Paint() return end

					weaponCatPanel.Header:SetTextColor(white)
					weaponCatPanel.Header:SetFont('edf_roboto20')

					function weaponCatPanel.Header:Paint(w, h)
						local categoryColor = self.color or essentialDarkRPF4Menu.defaultCategoryColor

						surface.SetDrawColor(defaultBlurOutline)
						surface.DrawOutlinedRect(0, 0, w, h)

						surface.SetDrawColor(categoryColor)
						surface.DrawRect(1, 1, w - 2, h - 2)
					end

					-- Add panel containing the weapon contents to category
					weaponCatPanel.catContentsPanel = vgui.Create('DPanel')
					weaponCatPanel.catContentsPanel:SizeToContents()

					function weaponCatPanel.catContentsPanel:Paint() return end

					weaponCatPanel:SetContents(weaponCatPanel.catContentsPanel)
				end

				local weaponCatPanel = weaponsListPanel[weaponCat]

				local weaponCategories = DarkRP.getCategories().weapons

				for _, category in ipairs(weaponCategories) do
					if weaponCat == category.name then
						weaponCatPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
					end
				end

				-- Add weapons to category contents panel
				local weaponButton = weaponCatPanel.catContentsPanel:Add('DButton')
				weaponButton:SetText('')
				weaponButton:SetSize(0, 66)
				weaponButton:Dock(TOP)
				weaponButton:DockMargin(0, 3, 0, 0)

				function weaponButton:Paint()
					drawRectOutlined(0, 0, self:GetWide(), self:GetTall(), defaultBlur)
				end

				function weaponButton.DoClick()
					essentialDarkRPF4Menu.selectedWeapon = weapon

					-- Add stuff to right panel
					addWeaponName()
					addWeaponModel()
					addWeaponPrice()

					buttonClickSound()
				end

				function weaponButton.DoDoubleClick()
					if IsValid(purchaseWeaponButton) then
						purchaseWeaponButton:DoClick()
					end
				end

				local weaponModel = weaponButton:Add('SpawnIcon')
				weaponModel:SetSize(64, 0)
				weaponModel:Dock(LEFT)
				weaponModel:DockMargin(1, 1, 1, 1)
				weaponModel:SetModel(weapon.model)

				function weaponModel.DoClick()
					weaponButton:DoClick()
				end

				local weaponName = weaponButton:Add('DLabel')
				weaponName:Dock(LEFT)
				weaponName:DockMargin(6, 0, 0, 0)
				weaponName:SetText(weapon.name)
				weaponName:SetFont('edf_roboto20')
				weaponName:SetTextColor(white)
				weaponName:SizeToContentsX()

				local pricePanel = weaponButton:Add('DPanel')
				pricePanel:Dock(RIGHT)
				pricePanel:DockMargin(0, 0, 5, 0)
				pricePanel:SizeToContentsX()

				function pricePanel.Paint(w, h)
					draw.RoundedBox(28.49, 5, 5, pricePanel:GetTall() - 8, pricePanel:GetWide() - 8, Color(10, 10, 10, 120))
				end

				function pricePanel:OnMousePressed()
					weaponButton:DoClick()
				end

				-- Weapon price
				local weaponPrice = pricePanel:Add('DLabel')
				weaponPrice:Dock(FILL)
				weaponPrice:DockMargin(0, 0, 0, 0)

				weaponPrice:DockMargin(0, 0, 0, 0)
				weaponPrice:SetText('$' .. weapon.pricesep)

				if weapon.pricesep < 1000 then
					weaponPrice:SetFont('edf_roboto20')
				elseif weapon.pricesep < 100000 then
					weaponPrice:SetFont('edf_roboto18')
				else
					weaponPrice:SetFont('edf_roboto16')
				end

				weaponPrice:SetContentAlignment(5)
				weaponPrice:SetTextColor(white)

				-- Add initial stuff to right panel
				addWeaponName()
				addWeaponModel()
				addWeaponPrice()
			end
		end
	end

	if #validItems < 1 then
		rightPanel:SetVisible(false)

		local unavailableLabel = essentialDarkRPF4Menu.weaponsPanel:Add('DLabel')
		unavailableLabel:SetPos(0, 0)
		unavailableLabel:SetFont('edf_roboto20')
		unavailableLabel:SetTextColor(white)
		unavailableLabel:SetText('The contents of this tab are not available for your job.')
		unavailableLabel:SizeToContents()
	end
end

function essentialDarkRPF4Menu.openWeaponsTab()
	openWeapons()
end
