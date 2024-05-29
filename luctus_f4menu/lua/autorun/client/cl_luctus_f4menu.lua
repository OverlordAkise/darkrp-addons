--Luctus F4 Menu
--Made by OverlordAkise

--Should unbuyable entities be hidden or just greyed out?
local shouldHideUnbuyables = false
--Extra buttons to show in the F4 menu
local extraButtons = {
    ["Workshop"] = function() gui.OpenURL("https://steamcommunity.com/sharedfiles/") end,
}

--variables and colors
local tabButtonHeight = 45
local buttonSpacing = 4
local color_window = Color(54, 57, 62)
local color_window_border = Color(32, 34, 37)
local color_closebutton = Color(47, 49, 54)
local color_closebutton_hover = Color(66,70,77)
local color_item_disabled = Color(90,90,90)
local color_category_default = Color(0,107,0,150)
local color_bg = Color(10,10,10,80)
local color_text = Color(255,255,255,255)
local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)
local color_black_light = Color(20,20,20,253)
local color_accent = Color(0,195,165)

--language
local L = {
    ["commands"] = "Commands",
    ["jobs"] = "Jobs",
    ["entities"] = "Entities",
    ["shipments"] = "Shipments",
    ["weapons"] = "Weapons",
    ["ammo"] = "Ammo",
    ["vehicles"] = "Vehicles",
    ["food"] = "Food",
    ["TakeJob"] = "Take Job",
    ["CreateVote"] = "Create Vote",
    ["Purchase"] = "Purchase",
    ["Shipment"] = "Shipment",
    ["Cost"] = "Cost",
    ["CategoryNotAvailable"] = "The contents of this tab are not available for your job.",
}

--CONFIG END

local window = nil
local middlePanel = nil
local nameLabel = nil
local modelPanel = nil
local purchaseButton = nil
local selectedSkin = 1
local selectedItem = nil
local lastTab = nil
local description = nil

surface.CreateFont("LuctusF4big", {
    font = "Verdana",
    size = 24,
})

surface.CreateFont("LuctusF4", {
    font = "Verdana",
    size = 20,
})

surface.CreateFont("LuctusF4small", {
    font = "Verdana",
    size = 16,
})

local buyCommands = {
    ["food"] = function(item) RunConsoleCommand("darkrp", "buyfood", item.name) end,
    ["entities"] = function(item) RunConsoleCommand("darkrp", item.cmd) end,
    ["ammo"] = function(item) RunConsoleCommand("darkrp", "buyammo", item.ammoType) end,
    ["weapons"] = function(item) RunConsoleCommand("darkrp", "buy", item.name) end,
    ["shipments"] = function(item) RunConsoleCommand("darkrp", "buyshipment", item.name) end,
    ["vehicles"] = function(item) RunConsoleCommand("say", "/buyvehicle " .. item.name) end,
    ["jobs"] = function(item)
        if item.vote then
            RunConsoleCommand("darkrp", "vote"..item.command)
        else
            RunConsoleCommand("darkrp", item.command)
        end
        if IsValid(window) then window:Close() end
    end,
}

local function buttonRolloverSound()
    surface.PlaySound("ui/buttonrollover.wav")
end

local function buttonClickSound()
    surface.PlaySound("ui/buttonclick.wav")
end

local function luctusPaintHover(self,w,h,bOutline,col)
    if not bOutline then
        surface.SetDrawColor(color_accent)
        surface.DrawRect(0,0,w,h)
    end
    surface.SetDrawColor(col and col or color_black_light)
    surface.DrawRect(1,1,w-2,h-2)
    if self:IsHovered() then
        self:SetTextColor(color_accent)
    else
        self:SetTextColor(color_text)
    end
end

local function luctusPrettifyScrollbar(el)
    function el:Paint() return end
    function el.btnGrip:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0,1,1,w-2,h-2,color_black_light)
    end
    function el.btnUp:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0,1,1,w-2,h-2,color_black_light)
    end
    function el.btnDown:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0,1,1,w-2,h-2,color_black_light)
    end
end

--A helper function to set dock and margin and font and textcolor in one line
function createF4button(parent,el,dock,l,u,r,d)
    local but = vgui.Create(el,parent)
    but:Dock(dock)
    but:DockMargin(l,u,r,d)
    if but.SetFont then but:SetFont("LuctusF4") end
    if but.SetTextColor then but:SetTextColor(color_text) end
    return but
end


LF4catIterators = LF4catIterators or {}
--The GAMEMODE ammotypes load later, so just do this
hook.Add("InitPostEntity","luctus_f4menu_loadcategories",function()
    LF4catIterators = {
        ["ammo"] = GAMEMODE.AmmoTypes,
        ["weapons"] = CustomShipments,
        ["shipments"] = CustomShipments,
        ["entities"] = DarkRPEntities,
        ["food"] = FoodItems,
        ["vehicles"] = CustomVehicles,
        ["jobs"] = RPExtraTeams,
    }
end)

local function drawMiddlePanel(name)
    if not LF4catIterators[name] then return end
    middlePanel:Clear()
    modelPanel:SetModel("")
    nameLabel:SetText("")
    description:SetText("")
    
    local hasFirstItemLoadedOnRightPanel = false
    local atleastOneItem = false
  
    for k, item in ipairs(LF4catIterators[name]) do
        if name == "shipments" and item.noship then continue end
        if name == "weapons" and not item.separate then continue end
        
        if name == "jobs" then
            modelPanel:SetFOV(70)
            purchaseButton:SetText(L["TakeJob"])
        else
            modelPanel:SetFOV(25)
            purchaseButton:SetText(L["Purchase"])
        end
        
        
        local shouldDisplayItem = true
        
        if istable(item.allowed) and not table.HasValue(item.allowed, LocalPlayer():Team()) then
            shouldDisplayItem = false
        end
        if name == "weapons" and GAMEMODE.Config.restrictbuypistol then
            shouldDisplayItem = false
        end

        if item.customCheck and not item.customCheck(LocalPlayer()) then
            shouldDisplayItem = false
        end

        if item.canSee and not item.canSee(LocalPlayer()) then
            shouldDisplayItem = false
        end
        
        --skip this one in the for loop
        if not shouldDisplayItem and name ~= "jobs" and shouldHideUnbuyables then continue end
        
        atleastOneItem = true

        local category = item.category

        -- Add non-existing categories
        if not IsValid(middlePanel[category]) then
            middlePanel[category] = createF4button(middlePanel,"DCollapsibleCategory",TOP,0,0,5,3)
            local categoryPanel = middlePanel[category]
            
            categoryPanel:SetLabel(item.category)
            categoryPanel:GetChildren()[1]:SetTall(35)
            function categoryPanel:Paint() end

            categoryPanel.Header:SetTextColor(color_text)
            categoryPanel.Header:SetFont("LuctusF4")
            categoryPanel.Header.color = item.color or color_category_default
            function categoryPanel.Header:Paint(w,h)
                surface.SetDrawColor(color_black_light)
                surface.DrawOutlinedRect(0,0,w,h)
                surface.SetDrawColor(self.color)
                surface.DrawRect(1,1,w-2,h-2)
            end

            -- Add panel containing the category contents (items)
            categoryPanel.catContentsPanel = vgui.Create("DPanel")
            categoryPanel.catContentsPanel:SizeToContents()
            function categoryPanel.catContentsPanel:Paint() return end
            categoryPanel:SetContents(categoryPanel.catContentsPanel)
        end

        local categoryPanel = middlePanel[category]
        -- Add item to category contents panel
        local categoryRow = createF4button(categoryPanel.catContentsPanel,"DButton",TOP,0,3,0,0)
        categoryRow:SetText("")
        categoryRow:SetSize(0,66)
        categoryRow.shouldBeDisabled = not shouldDisplayItem
        function categoryRow:Paint(w,h)
            luctusPaintHover(self,w,h,true, self.shouldBeDisabled and color_item_disabled or nil)
        end

        function categoryRow:DoClick()
            buttonClickSound()
            selectedSkin = 1
            selectedItem = item
            purchaseButton.id = item
            purchaseButton.type = name
            -- Add stuff to right panel
            nameLabel:SetText(item.name)
            modelPanel:SetModel(istable(item.model) and item.model[1] or item.model)
            
            description:SetText(item.salary and item.description or L["Cost"]..": "..DarkRP.formatMoney(item.price))
            if item.description then
               description:SetText(item.description)
            end
            
            if name == "jobs" then
                if item.vote then
                    purchaseButton:SetText(L["CreateVote"])
                else
                    purchaseButton:SetText(L["TakeJob"])
                end
            end
            
            if not self.lastClicked then self.lastClicked = 0 end
            if CurTime()-self.lastClicked < 0.3 then
                purchaseButton:DoClick()
            end
            self.lastClicked = CurTime()
        end
        
        
        local rowModel = createF4button(categoryRow,"SpawnIcon",LEFT,1,1,1,1) --margin fixes wide avatars
        rowModel:SetSize(64, 0)
        rowModel:SetModel(istable(item.model) and item.model[1] or item.model)
        function rowModel.DoClick()
            categoryRow:DoClick()
        end

        local rowName = createF4button(categoryRow,"DLabel",LEFT,6,0,0,0)
        rowName:SetText(item.name)
        rowName:SizeToContentsX()

        local rowPrice = createF4button(categoryRow,"DPanel",RIGHT,0,0,5,0)
        rowPrice:SizeToContentsX()
        function rowPrice:Paint(w,h) end
        function rowPrice:OnMousePressed()
            categoryRow:DoClick()
        end
        
        local rowMoney = createF4button(rowPrice,"DLabel",LEFT,0,0,0,0)
        rowMoney:SetText("$" .. (item.price or item.salary))
        rowMoney:SetContentAlignment(5) --right
        
        --Levelsystem if exists
        if name == "jobs" and item.level then
            local levellabel = createF4button(categoryRow,"DLabel",RIGHT,6,0,0,0)
            levellabel:SetText("Lv."..item.level)
        end
        
        -- Add initial stuff to right panel
        if not hasFirstItemLoadedOnRightPanel then
            hasFirstItemLoadedOnRightPanel = true
            selectedItem = item
            purchaseButton.id = item
            purchaseButton.type = name
            nameLabel:SetText(item.name)
            modelPanel:SetModel(istable(item.model) and item.model[1] or item.model)
            description:SetText(item.salary and item.description or L["Cost"]..": "..DarkRP.formatMoney(item.price))
        end
    end
    
    if not atleastOneItem then
        local unavailableLabel = createF4button(middlePanel,"DLabel",RIGHT,0,0,0,0)
        unavailableLabel:SetPos(0, 0)
        unavailableLabel:SetText(L["CategoryNotAvailable"])
        unavailableLabel:SizeToContents()
    end
end

local function drawTabsPanel()
    local tabButtonsPanel = window:Add("DScrollPanel")
    tabButtonsPanel:Dock(LEFT)
    tabButtonsPanel:DockMargin(0,0,8,0)
    tabButtonsPanel:SetSize(180,window:GetTall()-50)
    function tabButtonsPanel:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_bg)
    end
    
    local scrollBar = tabButtonsPanel:GetVBar()
    luctusPrettifyScrollbar(scrollBar)
    scrollBar:DockMargin(-5,0,0,0)

    local tabs = {"jobs"} --jobs always on

    if #DarkRPEntities > 0 then
        table.insert(tabs, "entities")
    end

    if #CustomShipments > 0 then
        table.insert(tabs, "shipments")
        table.insert(tabs, "weapons")
    end

    if #GAMEMODE.AmmoTypes > 0 then
        table.insert(tabs, "ammo")
    end

    if #CustomVehicles > 0 then
        table.insert(tabs, "vehicles")
    end

    if not DarkRP.disabledDefaults["modules"]["hungermod"] then
        if LocalPlayer():getJobTable().cook then
            table.insert(tabs, "food")
        end
    end
    
    local bs = buttonSpacing
    for i=1, #tabs do
        local tab = createF4button(tabButtonsPanel,"DButton",TOP,bs+1,bs,bs+1,0)
        tab:SetTall(tabButtonHeight)
        tab:SetFont("LuctusF4big")
        tab.lname = tabs[i]
        tab:SetText(L[tabs[i]])

        function tab:Paint(w, h)
            if self:IsHovered() or lastTab == self.lname then
                tab:SetTextColor(color_accent)
            else
                tab:SetTextColor(color_text)
            end
            surface.SetDrawColor(color_accent)
            surface.DrawOutlinedRect(0,0,w,h)
        end

        function tab:DoClick()
            drawMiddlePanel(tabs[i])
            lastTab = tabs[i]
            buttonClickSound()
        end
    end
    
    for name,func in pairs(extraButtons) do
        local tab = createF4button(tabButtonsPanel,"DButton",TOP,bs+1,bs,bs+1,0)
        tab:SetText(name)
        tab:SetTall(tabButtonHeight)
        tab:SetFont("LuctusF4big")
        tab.DoClick = func
        function tab:Paint(w,h)
            if self:IsHovered() then
                tab:SetTextColor(color_accent)
            else
                tab:SetTextColor(color_text)
            end
            surface.SetDrawColor(color_accent)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end
end

local function createModelArrowButtons(parent,isRight)
    local arrowButton = createF4button(parent,"DButton",isRight and RIGHT or LEFT,0,0,0,0)
    arrowButton:SetWide(25)
    arrowButton:SetText(isRight and ">" or "<")
    function arrowButton:Paint(w, h) luctusPaintHover(self,w,h,true) end
    function arrowButton:DoClick()
        if not selectedItem then return end
        if not selectedItem.model then return end
        if not istable(selectedItem.model) then return end  
        buttonClickSound()
        if not isRight and selectedSkin <= 1 then return end
        if isRight and selectedSkin >= #selectedItem.model then return end
        selectedSkin = isRight and (selectedSkin + 1) or (selectedSkin - 1)
        if not util.IsValidModel(selectedItem.model[selectedSkin]) then
            modelPanel:SetModel("models/error.mdl")
            return
        end
        modelPanel:SetModel(selectedItem.model[selectedSkin])
        DarkRP.setPreferredJobModel(selectedItem.team,selectedItem.model[selectedSkin])
    end
end

local function drawRightPanel()
    -- Right panel
    local rightPanel = createF4button(window,"DPanel",RIGHT,0,0,0,0)
    rightPanel:SetWide(270)

    function rightPanel:Paint(w, h)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0,0,w,h)

        surface.SetDrawColor(color_bg)
        surface.DrawRect(1,1,w-2,h-2)
    end
  
    -- Right panel name
    nameLabel = createF4button(rightPanel,"DLabel",TOP,5,5,5,0)
    nameLabel:SetTall(30)
    nameLabel:SetContentAlignment(5)
    nameLabel:SetText("")
    -- Right panel model
    modelPanel = createF4button(rightPanel,"DModelPanel",TOP,5,5,5,5)
    modelPanel:SetSize(0, 150)
    modelPanel:SetSize(200, 200)
    modelPanel:SetFOV(25)
    modelPanel:SetCamPos(Vector(100, 90, 65))
    modelPanel:SetLookAt(Vector(9, 9, 13))
    -- Right panel price
    local descriptionPanel = createF4button(rightPanel,"DScrollPanel",FILL,5,10,5,10)
    descriptionPanel:SetSize(0, rightPanel:GetTall())
    local descriptionScrollBar = descriptionPanel:GetVBar()
    descriptionScrollBar:DockMargin(0, 0, 0, 0)
    luctusPrettifyScrollbar(descriptionScrollBar)
    
    description = createF4button(descriptionPanel,"DLabel",TOP,5,5,5,5)
    description:SetFont("LuctusF4small")
    description:SetSize(250, descriptionPanel:GetTall())
    description:SetWrap(true)
    description:SetAutoStretchVertical(true)
    -- Purchase button
    purchaseButton = createF4button(rightPanel,"DButton",BOTTOM,5,5,5,5)
    purchaseButton:SetTall(45)
    purchaseButton:SetText(L["Purchase"])
    function purchaseButton:Paint(w, h) luctusPaintHover(self,w,h) end
  
    function purchaseButton:DoClick()
        if not buyCommands[self.type] then return end
    buyCommands[self.type](self.id)
    end
    
    -- Panel to parent all tab content to
    middlePanel = createF4button(window,"DScrollPanel",FILL,0,0,0,0)
    middlePanel:SetHeight(window:GetTall()-50)
    function middlePanel:Paint() return end
    
    local scrollBar = middlePanel:GetVBar()
    scrollBar:DockMargin(0,0,0,0)
    luctusPrettifyScrollbar(scrollBar)
  
    --stupid model picker code from here on
    local modelPickerPanel = createF4button(rightPanel,"DPanel",BOTTOM,5,0,5,0)
    function modelPickerPanel:Paint() return end
    
    -- < Left button
    createModelArrowButtons(modelPickerPanel,false)
    
    -- Model counter
    local currentModelCounter = modelPickerPanel:Add("DLabel")
    currentModelCounter:SetFont("LuctusF4")
    currentModelCounter:SetTextColor(color_text)
    currentModelCounter:SetText(1)
    currentModelCounter:SizeToContentsX()
    currentModelCounter:Dock(FILL)
    currentModelCounter:SetContentAlignment(5)
    function currentModelCounter:Paint()
        currentModelCounter:SetText(selectedSkin)
    end
    -- > Right button
    createModelArrowButtons(modelPickerPanel,true)
end

local function createF4Menu()
    window = vgui.Create("DFrame")
    window:SetTitle("F4 Menu")
    window:SetSize(1100, 650)
    window:ShowCloseButton(false)
    window:Center()
    function window:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_window_border)
        draw.RoundedBox(0,1,1,w-2,h-2,color_window)
    end
    function window:OnRemove()
        gui.EnableScreenClicker(false)
    end
  
    local closeButton = vgui.Create("DButton",window)
    closeButton:SetPos(1100-32,2)
    closeButton:SetSize(30,20)
    closeButton:SetText("X")
    closeButton:SetTextColor(color_accent)
    function closeButton:DoClick()
        window:Close()
    end
    function closeButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,self.Hovered and color_closebutton_hover or color_closebutton)
    end

    drawTabsPanel()
    drawRightPanel()
    drawMiddlePanel(lastTab or "jobs")
end

hook.Add("ShowSpare2", "luctus_f4menu_open", function()
    buttonRolloverSound()
    if IsValid(window) then
        window:Remove()
    else
        createF4Menu()
        gui.EnableScreenClicker(true)
    end
    --the following hinders darkrp f4 from opening:
    return false
end)

print("[luctus_f4menu] cl loaded")
