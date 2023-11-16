--Luctus F4 Menu
--Made by OverlordAkise
 
luctusF4 = luctusF4 or {}
luctusF4.curSkin = 1
luctusF4.curItem = nil


--CONFIG START

local extraButtons = {
    ["Workshop"] = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/") end,
}

local tabButtonHeight = 45
local buttonSpacing = 4

local color_category_default = Color(0, 107, 0, 150)
local color_bg = Color(10, 10, 10, 80)
local white = Color(255, 255, 255, 255)
local black = Color(0, 0, 0)
local lblack = Color(20,20,20,253)
local color_accent = Color(0, 195, 165)

luctusF4.lang = {
    ['commands'] = 'Commands',
    ['jobs'] = 'Jobs',
    ['entities'] = 'Entities',
    ['shipments'] = 'Shipments',
    ['weapons'] = 'Weapons',
    ['ammo'] = 'Ammo',
    ['vehicles'] = 'Vehicles',
    ['food'] = 'Food',
    ['TakeJob'] = 'Take Job',
    ['CreateVote'] = 'Create Vote',
    ['Purchase'] = 'Purchase',
    ['Shipment'] = 'Shipment',
    ['Cost'] = 'Cost',
    ['CatNotAvailable'] = 'The contents of this tab are not available for your job.',
}

--CONFIG END

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

surface.CreateFont('edf_roboto16', {
    font = 'Roboto Regular',
    extended = true,
    size = 16
})

local buyCommands = {
    ["food"] = function(item) RunConsoleCommand('darkrp', 'buyfood', item.name) end,
    ["entities"] = function(item) RunConsoleCommand('darkrp', item.cmd) end,
    ["ammo"] = function(item) RunConsoleCommand('darkrp', 'buyammo', item.ammoType) end,
    ["weapons"] = function(item) RunConsoleCommand('darkrp', 'buy', item.name) end,
    ["shipments"] = function(item) RunConsoleCommand('darkrp', 'buyshipment', item.name) end,
    ["vehicles"] = function(item) RunConsoleCommand('say', '/buyvehicle ' .. item.name) end,
    ["jobs"] = function(item)
        if item.vote then
            RunConsoleCommand('darkrp', 'vote' .. item.command)
        else
            RunConsoleCommand('darkrp', item.command)
        end
        if IsValid(luctusF4.mainFrame) then luctusF4.mainFrame:Close() end
    end,
}

local function buttonRolloverSound()
    surface.PlaySound('ui/buttonrollover.wav')
end

local function buttonClickSound()
    surface.PlaySound('ui/buttonclick.wav')
end

local function luctusPaintHover(self,w,h,bOutline,col)
    if not bOutline then
        surface.SetDrawColor(color_accent)
        surface.DrawRect(0, 0, w, h)
    end
    surface.SetDrawColor(col and col or lblack)
    surface.DrawRect(1, 1, w - 2, h - 2)
    if self:IsHovered() then
        self:SetTextColor(color_accent)
    else
        self:SetTextColor(white)
    end
end

function luctusPrettifyScrollbar(el)
    function el:Paint() return end
    function el.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0, 1, 1, w-2, h-2, lblack)
    end
    function el.btnUp:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0, 1, 1, w-2, h-2, lblack)
    end
    function el.btnDown:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0, 1, 1, w-2, h-2, lblack)
    end
end

local function drawTabsPanel()
    local tabsPanel = luctusF4.mainFrame:Add('DPanel')
    tabsPanel:Dock(LEFT)
    tabsPanel:DockMargin(0, 0, 8, 0)
    tabsPanel:SetSize(180, luctusF4.mainFrame:GetTall())
    function tabsPanel:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_bg)
    end

    local tabsHeader = tabsPanel:Add('DLabel')
    tabsHeader:Dock(TOP)
    tabsHeader:SetTall(tabButtonHeight)
    tabsHeader:SizeToContentsX()
    tabsHeader:SetFont('edf_roboto24')
    tabsHeader:SetTextColor(white)
    tabsHeader:SetContentAlignment(5)
    function tabsHeader:Paint()
        tabsHeader:SetText(os.date('%a, %H:%M:%S %p'))
    end

    -- Tab buttons scroll panel
    local tabsHeaderPosX, tabsHeaderPosY = tabsHeader:GetPos()
    local tabsHeaderHeight = tabsHeader:GetTall()

    local tabButtonsPanel = vgui.Create('DScrollPanel', tabsPanel)
    tabButtonsPanel:Dock(FILL)
    tabButtonsPanel:DockMargin(0, buttonSpacing, 0, buttonSpacing)
    tabButtonsPanel:SetPos(tabsHeaderPosX, tabsHeaderPosY + tabsHeaderHeight)
    tabButtonsPanel:SetTall(luctusF4.mainFrame:GetTall() - (tabsHeaderHeight + tabsHeaderHeight))

    local scrollBar = tabButtonsPanel:GetVBar()
    luctusPrettifyScrollbar(scrollBar)
    scrollBar:DockMargin(-5, 0, 0, 0)

    local tabs = {"jobs"} --jobs always on

    if #DarkRPEntities > 0 then
        table.insert(tabs, 'entities')
    end

    if #CustomShipments > 0 then
        table.insert(tabs, 'shipments')
        table.insert(tabs, 'weapons')
    end

    if #GAMEMODE.AmmoTypes > 0 then
        table.insert(tabs, 'ammo')
    end

    if #CustomVehicles > 0 then
        table.insert(tabs, 'vehicles')
    end

    if not DarkRP.disabledDefaults['modules']['hungermod'] then
        if LocalPlayer():getJobTable().cook then
            table.insert(tabs, 'food')
        end
    end
  
    for i = 1, #tabs do
        local tab = vgui.Create("DButton", tabButtonsPanel)
        tab:Dock(TOP)
        tab:DockMargin(buttonSpacing + 1, 0, buttonSpacing + 1, buttonSpacing)
        tab:SetTall(tabButtonHeight)
        tab:SetFont('edf_roboto24')
        tab:SetTextColor(white)
        tab.id = i
        tab:SetText(luctusF4.lang[tabs[i]])

        function tab:Paint(w, h)
            if self:IsHovered() or luctusF4.rememberedTabId == self.id then
                tab:SetTextColor(color_accent)
            else
                tab:SetTextColor(white)
            end
            surface.SetDrawColor(color_accent)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        function tab:DoClick()
            luctusF4.openTab(tabs[i])
            luctusF4.rememberedTab = tabs[i]
            luctusF4.rememberedTabId = i
            buttonClickSound()
        end
    end
    
    for name,func in pairs(extraButtons) do
        local tab = vgui.Create("DButton", tabButtonsPanel)
        tab:Dock(TOP)
        tab:DockMargin(buttonSpacing + 1, 0, buttonSpacing + 1, buttonSpacing)
        tab:SetText(name)
        tab:SetTall(tabButtonHeight)
        tab:SetFont('edf_roboto24')
        tab:SetTextColor(white)
        function tab:Paint(w, h)
            if self:IsHovered() then
                tab:SetTextColor(color_accent)
            else
                tab:SetTextColor(white)
            end
            surface.SetDrawColor(color_accent)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        tab.DoClick = func
    end
  
    function luctusF4.returnTabsPanel()
        return tabsPanel
    end
end

local function drawMainFrameHeader()
    local tabsPanel = luctusF4.returnTabsPanel()

    local mainFrameHeader = luctusF4.mainFrame:Add('DPanel')
    mainFrameHeader:Dock(TOP)
    mainFrameHeader:DockMargin(0, 5, 0, 5)
    mainFrameHeader:SetTall(55)
    function mainFrameHeader:Paint()
        surface.SetDrawColor(Color(0,0,0,255))
        surface.DrawRect(0, 0, 55, 55)
    end

    function luctusF4.returnMainFrameHeader()
        return mainFrameHeader
    end

    -- Player info
    local playerAvatar = vgui.Create('AvatarImage', mainFrameHeader)
    playerAvatar:SetPos(1, 1)
    playerAvatar:SetSize(54, 54)
    playerAvatar:SetPlayer(LocalPlayer(), 128)

    local job = LocalPlayer():getDarkRPVar('job') or ''

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
        local money = DarkRP.formatMoney(LocalPlayer():getDarkRPVar('money'), '') or ''

        moneyLabel:SetText(money)
        moneyLabel:SizeToContents()
    end

    updateHeaderMoney()

    function moneyLabel:Paint()
        updateHeaderMoney()
    end
end

local function drawMainPanel()
    local tabsPanel = luctusF4.returnTabsPanel()
    local mainFrameHeader = luctusF4.returnMainFrameHeader()

    local mainFrameHeaderHeight = mainFrameHeader:GetTall()

    local midPanel = luctusF4.mainFrame:Add('DPanel')
    midPanel:SetSize(luctusF4.mainFrame:GetWide(), luctusF4.mainFrame:GetTall() - (mainFrameHeaderHeight + 50))
    midPanel:Dock(TOP)
    midPanel:DockMargin(0, 0, 0, 0)

    function midPanel:Paint() return end

    function luctusF4.returnMidPanel()
        return midPanel
    end

    -- Panel to parent all tab content to
    luctusF4.MainPanel = vgui.Create("DPanel",midPanel)
    luctusF4.MainPanel:SetSize(midPanel:GetWide(), midPanel:GetTall())
    luctusF4.MainPanel:Dock(FILL)
    luctusF4.MainPanel:DockMargin(0, 0, 0, 0)
    function luctusF4.MainPanel:Paint() return end
  
    -- Right panel
    local rightPanel = luctusF4.MainPanel:Add('DPanel')
    rightPanel:SetSize(270, luctusF4.MainPanel:GetTall())
    rightPanel:Dock(RIGHT)
    rightPanel:DockMargin(0, 0, 0, 0)

    function rightPanel:Paint(w, h)
        surface.SetDrawColor(black)
        surface.DrawOutlinedRect(0, 0, w, h)

        surface.SetDrawColor(color_bg)
        surface.DrawRect(1, 1, w - 2, h - 2)
    end
  
    -- Right panel name
    luctusF4.nameLabel = rightPanel:Add('DLabel')
    luctusF4.nameLabel:SetTall(30)
    luctusF4.nameLabel:Dock(TOP)
    luctusF4.nameLabel:DockMargin(5, 4, 5, 0)
    luctusF4.nameLabel:SetFont('edf_roboto20')
    luctusF4.nameLabel:SetTextColor(white)
    luctusF4.nameLabel:SetContentAlignment(5)
    luctusF4.nameLabel:SetText('')
    -- Right panel model
    luctusF4.modelPanel = rightPanel:Add('DModelPanel')
    luctusF4.modelPanel:SetSize(0, 150)
    luctusF4.modelPanel:Dock(TOP)
    luctusF4.modelPanel:DockMargin(5, 4, 5, 4)
    luctusF4.modelPanel:SetSize(200, 200)
    luctusF4.modelPanel:SetFOV(25)
    luctusF4.modelPanel:SetCamPos(Vector(100, 90, 65))
    luctusF4.modelPanel:SetLookAt(Vector(9, 9, 13))
    -- Right panel price
    local descriptionPanel = rightPanel:Add('DScrollPanel')
    descriptionPanel:SetSize(0, rightPanel:GetTall())
    descriptionPanel:Dock(FILL)
    descriptionPanel:DockMargin(5, 10, 5, 10)
    local descriptionScrollBar = descriptionPanel:GetVBar()
    descriptionScrollBar:DockMargin(0, 0, 0, 0)
    luctusPrettifyScrollbar(descriptionScrollBar)
  
    luctusF4.description = vgui.Create("DLabel",descriptionPanel)
    luctusF4.description:Dock(TOP)
    luctusF4.description:DockMargin(5,5,5,5)
    luctusF4.description:SetFont('edf_roboto16')
    luctusF4.description:SetTextColor(Color(200, 200, 200))
    luctusF4.description:SetSize(250, descriptionPanel:GetTall())
    luctusF4.description:SetWrap(true)
    luctusF4.description:SetAutoStretchVertical(true)
    -- Purchase button
    luctusF4.purchaseButton = rightPanel:Add('DButton')
    luctusF4.purchaseButton:SetTall(45)
    luctusF4.purchaseButton:Dock(BOTTOM)
    luctusF4.purchaseButton:DockMargin(5, 4, 5, 5)
    luctusF4.purchaseButton:SetFont('edf_roboto20')
    luctusF4.purchaseButton:SetText(luctusF4.lang['Purchase'])
    luctusF4.purchaseButton:SetTextColor(white)
    function luctusF4.purchaseButton:Paint(w, h) luctusPaintHover(self,w,h) end
  
    function luctusF4.purchaseButton:DoClick()
        if not buyCommands[self.type] then return end
    buyCommands[self.type](self.id)
    end
  
    luctusF4.listPanel = luctusF4.MainPanel:Add('DScrollPanel')
    luctusF4.listPanel:SetSize(luctusF4.MainPanel:GetWide(), luctusF4.MainPanel:GetTall())
    luctusF4.listPanel:Dock(TOP)
    luctusF4.listPanel:DockMargin(0, 0, 5, 0)
    local scrollBar = luctusF4.listPanel:GetVBar()
    scrollBar:DockMargin(0, 0, 0, 0)
    luctusPrettifyScrollbar(scrollBar)
  
    --stupid model picker code from here on
    local modelPickerPanel = rightPanel:Add('DPanel')
    modelPickerPanel:Dock(BOTTOM)
    modelPickerPanel:DockMargin(5, 0, 5, 0)
    function modelPickerPanel:Paint() return end
  
    luctusF4.leftButton = modelPickerPanel:Add('DButton')
    luctusF4.leftButton:SetWide(25)
    luctusF4.leftButton:Dock(LEFT)
    luctusF4.leftButton:DockMargin(0, 0, 0, 0)
    luctusF4.leftButton:SetTextColor(white)
    luctusF4.leftButton:SetText('<')
    function luctusF4.leftButton:Paint(w, h) luctusPaintHover(self,w,h,true) end
    --luctusPaintHover(luctusF4.leftbutton,true)
  
    function luctusF4.leftButton.DoClick()
        if not luctusF4.curItem then return end
        if not luctusF4.curItem.model then return end
        if not istable(luctusF4.curItem.model) then return end  
        if luctusF4.curSkin > 1 then
            luctusF4.curSkin = luctusF4.curSkin - 1
            if util.IsValidModel(luctusF4.curItem.model[luctusF4.curSkin]) then
                luctusF4.modelPanel:SetModel(luctusF4.curItem.model[luctusF4.curSkin])
                DarkRP.setPreferredJobModel(luctusF4.curItem.team,luctusF4.curItem.model[luctusF4.curSkin])
            else
                luctusF4.modelPanel:SetModel('models/error.mdl')
            end
        end
        buttonClickSound()
    end
    -- Model counter
    luctusF4.modelCounter = modelPickerPanel:Add('DLabel')
    luctusF4.modelCounter:SetFont('edf_roboto20')
    luctusF4.modelCounter:SetTextColor(white)
    luctusF4.modelCounter:SetText(1)
    luctusF4.modelCounter:SizeToContentsX()
    luctusF4.modelCounter:Dock(FILL)
    luctusF4.modelCounter:SetContentAlignment(5)
    function luctusF4.modelCounter:Paint()
        luctusF4.modelCounter:SetText(luctusF4.curSkin)
    end
    -- Right button
    luctusF4.rightButton = modelPickerPanel:Add('DButton')
    luctusF4.rightButton:SetWide(25)
    luctusF4.rightButton:Dock(RIGHT)
    luctusF4.rightButton:DockMargin(0, 0, 0, 0)
    luctusF4.rightButton:SetTextColor(white)
    luctusF4.rightButton:SetText('>')
    function luctusF4.rightButton:Paint(w, h) luctusPaintHover(self,w,h,true) end
  
    function luctusF4.rightButton.DoClick()
        if not luctusF4.curItem then return end
        if not luctusF4.curItem.model then return end
        if not istable(luctusF4.curItem.model) then return end
        if luctusF4.curSkin < #luctusF4.curItem.model then
            luctusF4.curSkin = luctusF4.curSkin + 1
            if util.IsValidModel(luctusF4.curItem.model[luctusF4.curSkin]) then
                luctusF4.modelPanel:SetModel(luctusF4.curItem.model[luctusF4.curSkin])
                DarkRP.setPreferredJobModel(luctusF4.curItem.team,luctusF4.curItem.model[luctusF4.curSkin])
            else
                luctusF4.modelPanel:SetModel('models/error.mdl')
            end
        end
        buttonClickSound()
    end
end

local function createF4Menu()
    --Draw Main Window
    luctusF4.mainFrame = vgui.Create("DFrame")
    luctusF4.mainFrame:SetTitle("F4")
    luctusF4.mainFrame:SetSize(1100, 650)
    luctusF4.mainFrame:ShowCloseButton(false)
    luctusF4.mainFrame:Center()
    function luctusF4.mainFrame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    function luctusF4.mainFrame:OnRemove()
        gui.EnableScreenClicker(false)
    end
  
    local closeButton = vgui.Create("DButton",luctusF4.mainFrame)
    closeButton:SetPos(1100-32,2)
    closeButton:SetSize(30,20)
    closeButton:SetText("X")
    closeButton:SetTextColor( Color(0, 195, 165) )
    closeButton.DoClick = function(s)
        luctusF4.mainFrame:Close()
    end
    function closeButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
  
    drawTabsPanel()
    drawMainFrameHeader()
    drawMainPanel()
end


luctusF4.rememberedTab = nil

local function openF4MenuToggle()
    if IsValid(luctusF4.mainFrame) then
        luctusF4.mainFrame:Remove()
        buttonRolloverSound()
    else
        createF4Menu()
        if luctusF4.rememberedTab == nil then
            luctusF4.openTab("jobs")
        else
            luctusF4.openTab(luctusF4.rememberedTab)
        end
        gui.EnableScreenClicker(true)
        buttonRolloverSound()
    end
end

hook.Add('ShowSpare2', 'luctus_f4_open', function()
    openF4MenuToggle()
    return false
end)

hook.Add('OnPlayerChat', 'luctus_f4_chat', function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == '!f4' then
        openF4MenuToggle()
    end
end)


function luctusF4.openTab(name)
    luctusF4.listPanel:Clear()
    luctusF4.modelPanel:SetModel("")
    luctusF4.nameLabel:SetText("")
    luctusF4.description:SetText("")
  
    local initRight = false
    local catIterators = {
        ["ammo"] = GAMEMODE.AmmoTypes,
        ["weapons"] = CustomShipments,
        ["shipments"] = CustomShipments,
        ["entities"] = DarkRPEntities,
        ["food"] = FoodItems,
        ["vehicles"] = CustomVehicles,
        ["jobs"] = RPExtraTeams,
    }
  
    local atleastOneItem = false
    if not catIterators[name] then return end
  
    for _, item in ipairs(catIterators[name]) do
        if name == "shipments" and item.noship then continue end
        if name == "weapons" and not item.separate then continue end
        
        if name == "jobs" then
            luctusF4.modelPanel:SetFOV(70)
            luctusF4.purchaseButton:SetText(luctusF4.lang['TakeJob'])
        else
            luctusF4.modelPanel:SetFOV(25)
            luctusF4.purchaseButton:SetText(luctusF4.lang['Purchase'])
        end
        
        
        local shouldDisplayItem = true
        
        if istable(item.allowed) and not table.HasValue(item.allowed, LocalPlayer():Team()) then
            shouldDisplayItem = false
        end

        if item.customCheck and not item.customCheck(LocalPlayer()) then
            shouldDisplayItem = false
        end

        if item.canSee and not item.canSee(LocalPlayer()) then
            shouldDisplayItem = false
        end
        
        --skip this one in the for loop
        if not shouldDisplayItem and name ~= "jobs" then continue end
        
        atleastOneItem = true

        local category = item.category

        -- Add non-existing categories
        if not IsValid(luctusF4.listPanel[category]) then
            luctusF4.listPanel[category] = luctusF4.listPanel:Add('DCollapsibleCategory')

            local categoryPanel = luctusF4.listPanel[category]

            categoryPanel:Dock(TOP)
            categoryPanel:DockMargin(0, 0, 5, 3)
            categoryPanel:SetLabel(item.category)
            categoryPanel:GetChildren()[1]:SetTall(35)

            function categoryPanel:Paint() return end

            categoryPanel.Header:SetTextColor(white)
            categoryPanel.Header:SetFont('edf_roboto20')
            categoryPanel.Header.color = item.color

            function categoryPanel.Header:Paint(w, h)
                local categoryColor = self.color or color_category_default

                surface.SetDrawColor(lblack)
                surface.DrawOutlinedRect(0, 0, w, h)

                surface.SetDrawColor(categoryColor)
                surface.DrawRect(1, 1, w - 2, h - 2)
            end

            -- Add panel containing the item contents to category
            categoryPanel.catContentsPanel = vgui.Create('DPanel')
            categoryPanel.catContentsPanel:SizeToContents()

            function categoryPanel.catContentsPanel:Paint() return end

            categoryPanel:SetContents(categoryPanel.catContentsPanel)
        end

        local categoryPanel = luctusF4.listPanel[category]

        local categoryegories = DarkRP.getCategories()[name]

        for _, category in ipairs(categoryegories) do
            if category == category.name then
                categoryPanel.Header.color = Color(category.color['r'], category.color['g'], category.color['b'], 150)
                break
            end
        end

        -- Add item to category contents panel
        local categoryRow = categoryPanel.catContentsPanel:Add('DButton')
        categoryRow:SetText('')
        categoryRow:SetSize(0, 66)
        categoryRow:Dock(TOP)
        categoryRow:DockMargin(0, 3, 0, 0)
        categoryRow.shouldBeDisabled = not shouldDisplayItem and name == "jobs"
        function categoryRow:Paint(w, h)
            luctusPaintHover(self,self:GetWide(),self:GetTall(),true, self.shouldBeDisabled and Color(90,90,90,255) or nil)
        end

        function categoryRow:DoClick()
            luctusF4.curSkin = 1
            luctusF4.curItem = item
            luctusF4.purchaseButton.id = item
            luctusF4.purchaseButton.type = name
            -- Add stuff to right panel
            luctusF4.nameLabel:SetText(item.name)
            if istable(item.model) then
                luctusF4.modelPanel:SetModel(item.model[1])
            else
                luctusF4.modelPanel:SetModel(item.model)
            end
            if item.salary then
                luctusF4.description:SetText(item.description)
            else
                luctusF4.description:SetText(luctusF4.lang['Cost'] .. ': ' .. DarkRP.formatMoney(item.price))
            end
          
            if item.description then
                luctusF4.description:SetText(item.description)
            end
            if name == "jobs" then
                if item.vote then
                    luctusF4.purchaseButton:SetText(luctusF4.lang['CreateVote'])
                else
                    luctusF4.purchaseButton:SetText(luctusF4.lang['TakeJob'])
                end
            end
            buttonClickSound()
            if not self.lastClicked then self.lastClicked = 0 end
            if CurTime()-self.lastClicked < 0.3 then
                luctusF4.purchaseButton:DoClick()
            end
            self.lastClicked = CurTime()
        end
        
        
        local rowModel = categoryRow:Add('SpawnIcon')
        rowModel:SetSize(64, 0)
        rowModel:Dock(LEFT)
        rowModel:DockMargin(1, 1, 1, 1)
        if istable(item.model) then
            rowModel:SetModel(item.model[1])
        else
            rowModel:SetModel(item.model)
        end
        function rowModel.DoClick()
            categoryRow:DoClick()
        end

        local rowName = categoryRow:Add('DLabel')
        rowName:Dock(LEFT)
        rowName:DockMargin(6, 0, 0, 0)
        rowName:SetText(item.name)
        rowName:SetFont('edf_roboto20')
        rowName:SetTextColor(white)
        rowName:SizeToContentsX()

        -- item price, job salary
        local rowPrice = categoryRow:Add('DPanel')
        rowPrice:Dock(RIGHT)
        rowPrice:DockMargin(0, 0, 5, 0)
        rowPrice:SizeToContentsX()

        function rowPrice.Paint(w, h)
            --draw.RoundedBox(0, 0, 0, rowPrice:GetTall(), rowPrice:GetWide(), Color(255, 255, 255, 120))
        end

        function rowPrice:OnMousePressed()
          categoryRow:DoClick()
        end
        local rowMoney = rowPrice:Add('DLabel')
        rowMoney:Dock(FILL)
        rowMoney:DockMargin(0, 0, 0, 0)
        rowMoney:SetText('$' .. (item.price and item.price or item.salary))
        rowMoney:SetFont('edf_roboto20')
        rowMoney:SetContentAlignment(5)
        rowMoney:SetTextColor(white)
        
        --Levelsystem if exists
        if name == "jobs" and item.level then
            local levellabel = categoryRow:Add('DLabel')
            levellabel:Dock(RIGHT)
            levellabel:DockMargin(6, 0, 0, 0)
            levellabel:SetText("Lv."..item.level)
            --levellabel:SetText("Lv.10")
            levellabel:SetFont('edf_roboto20')
            levellabel:SetTextColor(white)
            --levellabel:SizeToContentsX()
        end

        -- Add initial stuff to right panel
        if not initRight then
            initRight = true
            luctusF4.curItem = item
            luctusF4.purchaseButton.id = item
            luctusF4.purchaseButton.type = name
            luctusF4.nameLabel:SetText(item.name)
            if istable(item.model) then
                luctusF4.modelPanel:SetModel(item.model[1])
            else
                luctusF4.modelPanel:SetModel(item.model)
            end
            if item.salary then
                luctusF4.description:SetText(item.description)
            else
                luctusF4.description:SetText(luctusF4.lang['Cost'] .. ': ' .. DarkRP.formatMoney(item.price))
            end
        end
    end

    if not atleastOneItem then
        local unavailableLabel = luctusF4.listPanel:Add('DLabel')
        unavailableLabel:SetPos(0, 0)
        unavailableLabel:SetFont('edf_roboto20')
        unavailableLabel:SetTextColor(white)
        unavailableLabel:SetText(luctusF4.lang["CatNotAvailable"])
        unavailableLabel:SizeToContents()
    end

end

print("[luctus_f4menu] cl loaded")
