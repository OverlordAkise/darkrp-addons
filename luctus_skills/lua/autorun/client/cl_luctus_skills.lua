--Luctus Skills
--Made by OverlordAkise

LUCTUS_SKILLS_LOCAL = {}
LUCTUS_SKILLS_FREEPOINTS = 0

net.Receive("luctus_skills",function()
    LUCTUS_SKILLS_LOCAL = net.ReadTable()
    LuctusSkillsOpenMenu()
    LuctusSkillUpdatePoints()
end)

function LuctusSkillsSend()
    net.Start("luctus_skills")
        net.WriteUInt(table.Count(LUCTUS_SKILLS_LOCAL),8)
        for name,skill in pairs(LUCTUS_SKILLS_LOCAL) do
            net.WriteString(name)
            net.WriteUInt(skill,8)
        end
    net.SendToServer()
end

hook.Add("InitPostEntity","luctus_skills_uen_fix",function()
    if hook.GetTable()["HUDPaint"] and hook.GetTable()["HUDPaint"]["manolis:MVLevels:HUDPaintA"] then
        print("[luctus_skills] Fixing uen getLevel meta missing")
        local meta = FindMetaTable("Player")
        function meta:getLevel()
            return self:getDarkRPVar("level")
        end
    end
    if not LocalPlayer().getLevel then
        ErrorNoHaltWithStack("ERROR, No compatible leveling system installed! Skills not working!")
    end
end)

function LuctusSkillsHasLevel(skill)
    return LocalPlayer():getLevel() > LUCTUS_SKILLS[skill].req
end

local accent_col = Color(0, 195, 165)
local skFrame = nil
local color_red = Color(255,0,0)
local color_white = Color(255,255,255)
local color_black = Color(32, 34, 37)

local function LuctusPrettifyScrollbar(el)
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

function LuctusSkillsOpenMenu()
    if IsValid(skFrame) then return end
    
    local firstSkill = ""
    for k,v in pairs(LUCTUS_SKILLS) do
        if LocalPlayer():getLevel() >= v.req then
            firstSkill = k
            break
        end
    end
    
    skFrame = vgui.Create("DFrame")
    skFrame:SetSize(500, 300)
    skFrame:Center()
    skFrame:SetTitle("Luctus | Skills")
    skFrame:SetDraggable(true)
    skFrame:ShowCloseButton(false)
    skFrame:MakePopup()
    function skFrame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    local parent_x, parent_y = skFrame:GetSize()
    local CloseButton = vgui.Create( "DButton", skFrame )
    CloseButton:SetPos( parent_x-26, 1 )
    CloseButton:SetSize( 25, 25 )
    CloseButton:SetText("X")
    CloseButton:SetTextColor(color_red)
    CloseButton.DoClick = function()
        skFrame:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local leftPanel = vgui.Create("DPanel", skFrame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(150)
    leftPanel:DockMargin(5,5,5,5)
    leftPanel:SetPaintBackground(false)
    
    
    local pointsLeft = vgui.Create("DPanel", leftPanel)
    pointsLeft:Dock(TOP)
    pointsLeft:SetText("")
    pointsLeft.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
        draw.SimpleText("Points left: "..LUCTUS_SKILLS_FREEPOINTS,"Trebuchet18",w/2,h/2,accent_col,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    
    local categoryButtons = vgui.Create("DScrollPanel", leftPanel)
    categoryButtons:Dock(FILL)
    LuctusPrettifyScrollbar(categoryButtons:GetVBar())
    
    local mainPanel = vgui.Create("DPanel", skFrame)
    mainPanel:Dock(FILL)
    mainPanel:SetPaintBackground(false)
    mainPanel.skill = firstSkill
    mainPanel.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
        draw.SimpleText(self.skill,"DermaLarge",10,10,accent_col,TEXT_ALIGN_LEFT)
    end
    
    local spacePanel = vgui.Create("DTextEntry", mainPanel)
    spacePanel:Dock(TOP)
    spacePanel:SetHeight(50)
    spacePanel:SetPaintBackground(false)
    
    local descPanel = vgui.Create("DTextEntry", mainPanel)
    descPanel:Dock(TOP)
    descPanel:DockMargin(10,10,10,10)
    descPanel:SetHeight(100)
    descPanel:SetPaintBackground(false)
    descPanel:SetMultiline(true)
    descPanel:SetFont("Trebuchet18")
    descPanel:SetEditable(false)
    descPanel:SetTextColor(color_white)
    descPanel:SetText(LUCTUS_SKILLS[firstSkill].desc)
    
    local progBar = vgui.Create("DPanel", mainPanel)
    progBar:Dock(TOP)
    progBar:DockMargin(10,10,10,10)
    progBar:SetHeight(20)
    progBar:SetPaintBackground(false)
    function progBar:Paint(w,h)
        local width = (LUCTUS_SKILLS_LOCAL[mainPanel.skill]*w)/LUCTUS_SKILLS[mainPanel.skill].max
        draw.RoundedBox(0,0,0,w,h,color_black)
        draw.RoundedBox(0,0,0,width,h,accent_col)
        draw.SimpleText(LUCTUS_SKILLS_LOCAL[mainPanel.skill].."/"..LUCTUS_SKILLS[mainPanel.skill].max,"Trebuchet18",w/2,h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
    
    local lowerPanel = vgui.Create("DPanel", mainPanel)
    lowerPanel:Dock(FILL)
    lowerPanel:DockMargin(10,0,10,5)
    lowerPanel:SetPaintBackground(false)
    
    local levelLower = vgui.Create("DButton", lowerPanel)
    levelLower:Dock(LEFT)
    levelLower:SetText("level down ↓")
    levelLower:SetWide(150)
    levelLower:SetTextColor(accent_col)
    function levelLower:DoClick()
        LuctusSkillsChange(mainPanel.skill,false)
    end
    function levelLower:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
        DrawHighlightBorder(self,w,h)
    end
    
    local levelHigher = vgui.Create("DButton", lowerPanel)
    levelHigher:Dock(RIGHT)
    levelHigher:SetWide(150)
    levelHigher:SetText("level up ↑")
    levelHigher:SetTextColor(accent_col)
    function levelHigher:DoClick()
        LuctusSkillsChange(mainPanel.skill,true)
    end
    function levelHigher:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
        DrawHighlightBorder(self,w,h)
    end
    
    local saveButton = vgui.Create("DButton", mainPanel)
    saveButton:Dock(BOTTOM)
    saveButton:DockMargin(10,0,10,5)
    saveButton:SetText("◄ save your skills ►")
    saveButton:SetTextColor(accent_col)
    function saveButton:DoClick()
        LuctusSkillsSend()
        skFrame:Close()
    end
    function saveButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
        DrawHighlightBorder(self,w,h)
    end
    
    
    for skill,v in pairs(LUCTUS_SKILLS) do
        local skillBut = vgui.Create("DButton",categoryButtons)
        skillBut.skill = skill
        skillBut:Dock(TOP)
        skillBut:SetSize(CategoryWidth, 30)
        skillBut:SetCursor("hand")
        skillBut:SetText("")
        skillBut.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
            if mainPanel.skill == self.skill then
                DrawHighlightBorder(self,w,h)
            end
            draw.DrawText(self.skill, "Trebuchet18", 10, 7, color_white)
            if not LuctusSkillsHasLevel(self.skill) then
                draw.RoundedBox(0, 0, 0, w, h, Color(24, 27, 32,200))
                draw.SimpleText("Req. Lv"..LUCTUS_SKILLS[self.skill].req,"Trebuchet18",w-10, 7,color_red,TEXT_ALIGN_RIGHT)
            end
        end
        skillBut.DoClick = function(self)
            if not LuctusSkillsHasLevel(self.skill) then
                surface.PlaySound("player/suit_denydevice.wav")
                return
            end
            mainPanel.skill = self.skill
            descPanel:SetText(LUCTUS_SKILLS[self.skill].desc)
        end
    end
end

function LuctusSkillsChange(name,shouldUp)
    local skill = LUCTUS_SKILLS[name]
    local ltSkill = LUCTUS_SKILLS_LOCAL[name]
    if shouldUp then
        if skill.cost > LUCTUS_SKILLS_FREEPOINTS then
            surface.PlaySound("player/suit_denydevice.wav")
            return
        end
        LUCTUS_SKILLS_LOCAL[name] = math.min(ltSkill+1,skill.max)
    else
        LUCTUS_SKILLS_LOCAL[name] = math.max(ltSkill-1,0)
    end
    LuctusSkillUpdatePoints()
end

function LuctusSkillUpdatePoints()
    local totalSpent = 0
    for name,skill in pairs(LUCTUS_SKILLS) do
        totalSpent = totalSpent + (LUCTUS_SKILLS_LOCAL[name]*skill.cost)
    end
    LUCTUS_SKILLS_FREEPOINTS = LocalPlayer():getLevel()-totalSpent
end

function DrawHighlightBorder(el,w,h)
    surface.SetDrawColor(accent_col)
    surface.DrawLine(0,0,w,0)
    surface.DrawLine(w-1,0,w-1,h-1)
    surface.DrawLine(w-1,h-1,0,h-1)
    surface.DrawLine(0,h-1,0,0)
end

print("[luctus_skills] cl loaded")
