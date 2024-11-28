--Luctus Technician
--Made by OverlordAkise

--Small cl config, hardcoded for now

--which color should the UI have as its main color
local color_accent = Color(0,195,165)
--How many buttons to match left&right
local fixCount = 4
--The buttons, amount per nameconfig must match the above fixCount
local fixNames = {
    {
        {"Red+Green","Yellow"},
        {"Blue+Green","Cyan"},
        {"Blue+Red","Purple"},
        {"Red+Blue+Green","White"},
    },
    {
        {"12*1.5","18"},
        {"39/3","13"},
        {"3*4","12"},
        {"(5*4)/2","10"},
    },
}

local function randOrderTable(amount)
    local order = {}
    for i=1,amount do
        table.insert(order,i)
    end
    table.Shuffle(order)
    return order
end


local function paintButton(self,w,h)
    if self.connected then
        draw.RoundedBox(100, 0, 0, w, h, color_accent)
    end
    draw.RoundedBox(100, 1, 1, w-2, h-2, Color(47, 49, 54))
    if self.Hovered then
        draw.RoundedBox(100, 1, 1, w-2, h-2, Color(66, 70, 77))
    end
end

local frame
net.Receive("luctus_technician_repair",function()
    if IsValid(frame) then return end
    local ent = net.ReadEntity()
    local frameW = 600
    local frameH = 600
    local curPanel = nil
    local connected_panels = {}
    local successfullyRepaired = false
    frame = vgui.Create("DFrame")
    frame:SetSize(frameW,frameH)
    frame:SetTitle("Repair | Technician")
    frame:Center()
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    frame:ShowCloseButton(false)
    local animTargetY = frame:GetY()
    frame:SetY(ScrH()*2)--for animation
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
        draw.SimpleTextOutlined("Connect the left one to the correct right one!","Trebuchet24",w/2,60,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,color_black)
        surface.SetDrawColor(255,255,255,255)
        if curPanel then
            local x,y,w,h = curPanel:GetBounds()
            local mx,my = input.GetCursorPos()
            mx,my = self:ScreenToLocal(mx,my)
            surface.DrawLine(x+w,y+h/2,mx,my)
        end
        for k,pnls in ipairs(connected_panels) do
            local a,b = pnls[1],pnls[2]
            local ax,ay,aw,ah = a:GetBounds()
            local bx,by,bw,bh = b:GetBounds()
            surface.DrawLine(ax+aw,ay+ah/2,bx,by+bh/2)
        end
    end
    
    local function CloseFrame()
        frame:SetMouseInputEnabled(false)
        frame:MoveTo(frame:GetX(), ScrH()*2,0.5,0)
        timer.Simple(0.5,function()
            if not frame or not IsValid(frame) then return end
            frame:Close()
        end)
    end
    
    local function ConnectPoints(pnl)
        if not curPanel or not IsValid(curPanel) then return end
        if not pnl or not IsValid(pnl) then return end
        if curPanel.repairId ~= pnl.repairId then
            curPanel = nil
            surface.PlaySound("buttons/combine_button3.wav")
            return
        end
        curPanel.connected = true
        pnl.connected = true
        table.insert(connected_panels,{curPanel,pnl})
        curPanel = nil
        if #connected_panels >= fixCount then
            surface.PlaySound("buttons/button5.wav")
            --Create panel that makes buttons unclickable
            local endFrame = vgui.Create("DPanel", frame)
            endFrame:SetPos(0,24)
            endFrame:SetSize(frameW,frameH-24)
            function endFrame:Paint(w,h)
                draw.RoundedBox(0,0,0,w,h,Color(20,20,20,240))
                draw.SimpleTextOutlined("Repair successful!","DermaLarge",w/2,h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,color_black)
            end
            net.Start("luctus_technician_repair")
                net.WriteEntity(ent)
            net.SendToServer()
        else
            surface.PlaySound("buttons/button4.wav")
        end
    end
    
    local nameTab = fixNames[math.random(#fixNames)]
    
    local order = randOrderTable(fixCount)
    for k,id in ipairs(order) do
        local button = vgui.Create("DButton", frame)
        button:SetText(nameTab[id][1])
        button:SetFont("Trebuchet24")
        button:SetTextColor(color_white)
        button:SetSize(150,60)
        button:SetPos(50,60+k*60)
        button.repairId = id
        button.Paint = paintButton
        function button:DoClick()
            if self.connected then return end
            curPanel = self
        end
    end
    
    local order = randOrderTable(fixCount)
    for k,id in ipairs(order) do
        local button = vgui.Create("DButton", frame)
        button:SetText(nameTab[id][2])
        button:SetFont("Trebuchet24")
        button:SetTextColor(color_white)
        button:SetSize(150,60)
        button:SetPos(frameW-200,60+k*60)
        button.repairId = id
        button.Paint = paintButton
        function button:DoClick()
            ConnectPoints(self)
        end
    end
    
    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(frame:GetWide()-26,2)
    CloseButton:SetSize(24,24)
    CloseButton:SetTextColor(color_accent)
    function CloseButton:DoClick()
        CloseFrame()
    end
    function CloseButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    --animation to open
    frame:MoveTo(frame:GetX(), animTargetY,0.5,0)
end)


surface.CreateFont("TechnicianText", {
    font = "Arial",
    extended = false,
    size = 150,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
})

net.Receive("luctus_technician_togglehud", function()
    local shouldBeActive = net.ReadBool()
    if shouldBeActive then
        hook.Add("HUDPaint", "luctus_technician_hud",luctusTechnicianHUD)
    else
        hook.Remove("HUDPaint", "luctus_technician_hud")
    end
end)

local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)
function luctusTechnicianHUD()
    --Show broken entities on the screen
    if not LUCTUS_TECHNICIAN_SEE_BROKEN_THROUGH_WALL then return end
    for _, ent in ipairs(ents.FindByClass("luctus_tec*")) do
        if not ent:GetBroken() then continue end
        local point = ent:GetPos() + ent:OBBCenter()
        local data2D = point:ToScreen()
        if not data2D.visible then continue end
        draw.SimpleTextOutlined("r", "Marlett", data2D.x, data2D.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,1,color_black)
        draw.SimpleTextOutlined(math.Round(LocalPlayer():GetPos():Distance(ent:GetPos())), "DermaDefault", data2D.x, data2D.y+20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,1,color_black)
    end
end

print("[luctus_technician] cl loaded")
