--Luctus Quests
--Made by OverlordAkise

net.Receive("luctus_quests",function()
    LuctusQuestsOpenMenu(net.ReadTable(),net.ReadString())
end)

local accent_col = Color(0, 195, 165)
local qFrame = nil
local mainPanel = nil
local descPanel = nil
local color_red = Color(255,0,0)
local color_green = Color(0,255,0)
local color_white = Color(255,255,255)
local color_black = Color(32, 34, 37)
local currentCategory = nil
local currentQuest = nil

local function drawHighlightBorder(el,w,h)
    surface.SetDrawColor(accent_col)
    surface.DrawLine(0,0,w,0)
    surface.DrawLine(w-1,0,w-1,h-1)
    surface.DrawLine(w-1,h-1,0,h-1)
    surface.DrawLine(0,h-1,0,0)
end

local function luctusPrettifyScrollbar(el)
    function el:Paint() return end
    function el.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
    end
    function el.btnUp:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
    end
    function el.btnDown:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
    end
end

function LuctusQuestsOpenMenu(tab,curQuest)
    if IsValid(qFrame) then return end
    
    qFrame = vgui.Create("DFrame")
    qFrame:SetSize(700, 400)
    qFrame:Center()
    qFrame:SetTitle("Luctus Quests | Menu")
    qFrame:SetDraggable(true)
    qFrame:ShowCloseButton(false)
    qFrame:MakePopup()
    function qFrame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    local parent_x, parent_y = qFrame:GetSize()
    local CloseButton = vgui.Create("DButton", qFrame)
    CloseButton:SetPos(parent_x-26, 1)
    CloseButton:SetSize(25, 25)
    CloseButton:SetText("X")
    CloseButton:SetTextColor(color_red)
    function CloseButton:DoClick()
        qFrame:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    if curQuest ~= "" then
        local curQuestPanel = vgui.Create("DLabel", qFrame)
        curQuestPanel:SetPos(parent_x/2-110,1)
        curQuestPanel:SetSize(200,25)
        curQuestPanel:SetText("Active Quest: "..curQuest)
        curQuestPanel:SetTextColor(accent_col)
        curQuestPanel:SetContentAlignment(6) --middle-right
        --curQuestPanel:SetPaintBackground(false)
        local cancelButton = vgui.Create("DButton", qFrame)
        cancelButton:SetPos(parent_x/2+100,1)
        cancelButton:SetSize(100,25)
        cancelButton:SetText("Cancel Quest")
        cancelButton:SetTextColor(color_red)
        function cancelButton:Paint(w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
        function cancelButton:DoClick()
            Derma_Query(
                "Do you really want to cancel your active quest?",
                "Luctus Quests | Cancel Confirmation",
                "Yes",
                function()
                    net.Start("luctus_quests")
                        net.WriteBool(false)
                    net.SendToServer()
                    qFrame:Close()
                end,
                "No",
                function()end
            )
            
        end
        
    end
    
    local catPanel = vgui.Create("DPanel", qFrame)
    catPanel:Dock(LEFT)
    catPanel:SetWide(150)
    catPanel:DockMargin(5,5,5,5)
    catPanel:SetPaintBackground(false)
    local questsPanel = vgui.Create("DPanel", qFrame)
    questsPanel:Dock(LEFT)
    questsPanel:SetWide(200)
    questsPanel:DockMargin(5,5,5,5)
    questsPanel:SetPaintBackground(false)
    
    local categoryButtons = vgui.Create("DScrollPanel", catPanel)
    categoryButtons:Dock(FILL)
    luctusPrettifyScrollbar(categoryButtons:GetVBar())
    local questButtons = vgui.Create("DScrollPanel", questsPanel)
    questButtons:Dock(FILL)
    luctusPrettifyScrollbar(questButtons:GetVBar())
    
    mainPanel = vgui.Create("DPanel", qFrame)
    mainPanel:Dock(FILL)
    mainPanel:SetPaintBackground(false)
    mainPanel.skillname = ""
    function mainPanel:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
        draw.SimpleText(self.skillname,"DermaLarge",10,10,accent_col,TEXT_ALIGN_LEFT)
    end
    
    local spacerPanel = vgui.Create("DTextEntry", mainPanel)
    spacerPanel:Dock(TOP)
    spacerPanel:SetHeight(50)
    spacerPanel:SetPaintBackground(false)
    
    descPanel = vgui.Create("DTextEntry", mainPanel)
    descPanel:Dock(TOP)
    descPanel:DockMargin(10,10,10,10)
    descPanel:SetHeight(100)
    descPanel:SetPaintBackground(false)
    descPanel:SetMultiline(true)
    descPanel:SetFont("Trebuchet18")
    descPanel:SetEditable(false)
    descPanel:SetTextColor(color_white)
    descPanel:SetText("")

    local lowerPanel = vgui.Create("DPanel", mainPanel)
    lowerPanel:Dock(FILL)
    lowerPanel:DockMargin(10,0,10,5)
    lowerPanel:SetPaintBackground(false)
    
    local startButton = vgui.Create("DButton", lowerPanel)
    startButton:Dock(BOTTOM)
    startButton:SetText("")
    startButton.text = "Start this quest"
    startButton:SetTextColor(accent_col)
    function startButton:DoClick()
        net.Start("luctus_quests")
            net.WriteBool(true)
            net.WriteString(mainPanel.skillname)
        net.SendToServer()
        qFrame:Close()
    end
    function startButton:Paint(w,h)
        if mainPanel.skillname == "" then return end
        draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
        drawHighlightBorder(self,w,h)
        draw.SimpleText(self.text,"Trebuchet18",w/2,h/2,accent_col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    --tab[cat],{name,quest.description,quest.repeatDelay,quest.unlockfunc}
    for cat,miniQuest in pairs(luctusQuestsGetQuestsByCategory()) do
        local catButton = vgui.Create("DButton",categoryButtons)
        catButton.name = cat
        catButton.quests = miniQuest
        catButton:Dock(TOP)
        catButton:SetSize(150, 30)
        catButton:SetCursor("hand")
        catButton:SetText("")
        function catButton:Paint(w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
            if currentCategory == self then
                drawHighlightBorder(self,w,h)
            end
            draw.DrawText(self.name, "Trebuchet18", 10, 7, color_white)
        end
        function catButton:DoClick()
            currentCategory = self
            questButtons:Clear()
            luctusQuestsCreateQuestButtons(questButtons,self.quests,tab)
        end
    end
end

function luctusQuestsCreateQuestButtons(motherPanel,list,tab)
    --{name,quest.description,quest.repeatDelay,quest.unlockfunc}
    for k,mquest in ipairs(list) do
        local questButton = vgui.Create("DButton",motherPanel)
        questButton.name = mquest[1]
        questButton.desc = mquest[2]
        questButton:Dock(TOP)
        questButton:SetSize(150, 30)
        questButton:SetCursor("hand")
        questButton:SetText("")
        function questButton:Paint(w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
            if currentQuest == self then
                drawHighlightBorder(self,w,h)
            end
            draw.DrawText(self.name, "Trebuchet18", 10, 7, color_white)
            if tab[self.name] then
                if tab[self.name] == 0 then
                    draw.RoundedBox(0, 0, 0, w, h, Color(24, 27, 32,160))
                    draw.SimpleText("completed","Trebuchet18",w-10, 7,color_green,TEXT_ALIGN_RIGHT)
                elseif tab[self.name] > os.time() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(24, 27, 32,160))
                    draw.SimpleText("rep. in "..string.NiceTime(tab[self.name]-os.time()),"Trebuchet18",w-10, 7,color_green,TEXT_ALIGN_RIGHT)
                end
                return
            end
            if mquest[4] and not mquest[4](LocalPlayer()) then
                draw.RoundedBox(0, 0, 0, w, h, Color(24, 27, 32,200))
                draw.SimpleText("req. not met","Trebuchet18",w-10, 7,color_red,TEXT_ALIGN_RIGHT)
            end
        end
        function questButton:DoClick()
            currentQuest = self
            mainPanel.skillname = self.name
            descPanel:SetText(self.desc)
        end
    end
end

function luctusQuestsGetQuestsByCategory()
    local tab = {}
    for name,quest in pairs(LUCTUS_QUESTS_LIST) do
        local cat = quest.category
        if not tab[cat] then tab[cat] = {} end
        table.insert(tab[cat],{name,quest.description,quest.repeatDelay,quest.unlockfunc})
    end
    return tab
end

print("[luctus_quests] cl loaded")
