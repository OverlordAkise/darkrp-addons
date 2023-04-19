--Luctus Mining System
--Made by OverlordAkise

local accent_col = Color(0, 195, 165)
local accent_col_dark = Color(0, 125, 95)
local lightDark = Color(40,40,40)
local dark = Color(10,10,10)
local buttonTextColor = Color(200,200,200)

function luctusMineHUD()
    surface.SetDrawColor(Color(0,0,0,200))
    surface.DrawRect(5, ScrH()/2, 145, (#luctus.mine.ores+1) * 24)
    
    surface.SetFont("Trebuchet24")
    surface.SetTextPos(10,ScrH()/2)
    surface.SetDrawColor(Color(255,255,255,255))
    surface.DrawText("-Ore Inventory:")
    
    for k,v in pairs(luctus.mine.ores) do
        surface.SetTextColor(v["Color"])
        surface.SetTextPos(10,ScrH()/2+k*24)
        surface.DrawText(v.Name..": "..LocalPlayer():GetNWInt("ore_"..v.Name,0))
    end
end

function LuctusMinerGetName(ent)
    if not ent or ent == "" then return "<ERR>" end
    local swep = weapons.Get(ent)
    if swep and swep.PrintName then return swep.PrintName end
    local sent = scripted_ents.Get(ent)
    if sent and sent.PrintName then return sent.PrintName end
    return ent
end


hook.Add("OnContextMenuOpen","luctus_mine_hud_on",function()
    hook.Add("HUDPaint","luctus_mine_hud",luctusMineHUD)
end)

hook.Add("OnContextMenuClose","luctus_mine_hud_off",function()
    hook.Remove("HUDPaint","luctus_mine_hud")
end)
  
net.Receive("luctus_mine_npc",function()
    luctusNPCMenu()
end)

local function CreateCloseButton(parent)
    local parent_x, parent_y = parent:GetSize()
    local CloseButton = vgui.Create( "DButton", parent )
    CloseButton:SetPos( parent_x-31, 1 )
    CloseButton:SetSize( 30, 30 )
    CloseButton:SetText("X")
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        parent:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, dark)
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
end

local function BeautifyButton(but)
    if not but or not IsValid(but) then return end
    function but:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0,1,1,w-2,h-2,lightDark)
        if self.Hovered then
            self:SetColor(accent_col)
        else
            self:SetColor(buttonTextColor)
        end
    end
end

local function CreateFrame(name)
    local frame = vgui.Create("DFrame")
    frame:SetSize(700, 400)
    frame:Center()
    frame:SetTitle(name)
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, dark)
    end
    CreateCloseButton(frame)
    return frame
end

net.Receive("luctus_mine_craft",function()
    if IsValid(MineCraftPanel) then return end
    MineCraftPanel = CreateFrame("Luctus Miner | Crafting Table")

    local DScrollPanel = vgui.Create( "DScrollPanel", MineCraftPanel )
    DScrollPanel:Dock(FILL)

    for k,v in pairs(luctus.mine.craftables) do
        local row = DScrollPanel:Add("DPanel")
        row:Dock(TOP)
        row:SetPaintBackground(false)
        row:DockMargin(0,10,0,0)
        function row:Paint(w,h)
            draw.RoundedBox(0,0,h-1,w,h,accent_col)
        end

        local label = vgui.Create("DLabel",row)
        label:Dock(LEFT)
        label:SetSize(200,25)
        label:DockMargin(20,0,0,0)
        label:SetText(LuctusMinerGetName(v["Entity"]))

        local rLabel = vgui.Create("DLabel",row)
        rLabel:Dock(LEFT)
        rLabel:SetSize(200,25)
        local rText = ""
        for kk,vv in pairs(v) do
            if kk ~= "Entity" then
                rText = rText .. " " .. kk .. " " .. vv .. " ,"
            end
        end
        rText = string.sub(rText,1,#rText-1)
        rLabel:SetText(rText)

        local button = vgui.Create("DButton",row)
        button:Dock(RIGHT)
        button:SetText("Craft")
        button:SetColor(buttonTextColor)
        button:DockMargin(10,0,20,0)
        button.DoClick = function()
            net.Start("luctus_mine_craft")
                net.WriteString(v["Entity"])
            net.SendToServer()
        end
        BeautifyButton(button)
    end
end)


function luctusNPCMenu()
    if IsValid(MineNPCPanel) then return end
    local npc = net.ReadEntity()
    MineNPCPanel = CreateFrame("Luctus Miner | NPC to sell ore")

    local DScrollPanel = vgui.Create( "DScrollPanel", MineNPCPanel )
    DScrollPanel:Dock(FILL)

    for k,v in pairs(luctus.mine.ores) do
        local row = DScrollPanel:Add("DPanel")
        row:SetPos(0,(k-1)*25)
        row:SetSize(700,25)
        row:SetPaintBackground(false)

        local oreName = vgui.Create("DLabel",row)
        oreName:SetPos(20,3)
        oreName:SetColor(v["Color"])
        oreName:SetText(v["Name"])

        local oreSlider = vgui.Create("DNumSlider",row)
        oreSlider:SetPos(120,0)
        oreSlider:SetSize(400,25)	
        oreSlider:SetText(v["Name"])
        oreSlider:SetMin(0)
        oreSlider:SetMax(LocalPlayer():GetNWInt("ore_"..v["Name"],0))
        oreSlider:SetDecimals()
        oreSlider:SetDark(false)
        oreSlider:GetTextArea():SetDrawLanguageID(false)
        oreSlider:GetChildren()[3]:SetSize(0,0)
        oreSlider:GetChildren()[3]:Dock(NODOCK) -- Remove stupid label on the left

        local sellValueLabel = vgui.Create("DLabel",row)
        sellValueLabel:SetPos(530,3)
        sellValueLabel:SetText("x "..npc:GetNWInt("sOre_"..v["Name"],0).."$")  

        local sellButton = vgui.Create("DButton",row)
        sellButton:SetPos(600,2)
        sellButton:SetText("Sell")
        sellButton:SetColor(buttonTextColor)
        sellButton.textfield = numTextField
        sellButton.DoClick = function()
            local text = oreSlider:GetValue()
            local num = 0
            if text == "" then
                num = LocalPlayer():GetNWInt("ore_"..v["Name"],0)
            else
                num = tonumber(text)
            end
            net.Start("luctus_mine_npc")
                net.WriteInt(num,16)
                net.WriteString(v["Name"])
                net.WriteEntity(npc)
            net.SendToServer()
        end
        BeautifyButton(sellButton)
    end
    local pickaxeButton = vgui.Create("DButton",MineNPCPanel)
    pickaxeButton:Dock(BOTTOM)
    pickaxeButton:SetText("Give me a pickaxe!")
    pickaxeButton.DoClick = function()
        net.Start("luctus_get_pickaxe")
        net.SendToServer()
        MineNPCPanel:Close()
    end
    BeautifyButton(pickaxeButton)
end

print("[luctus_mine] CL file loaded!")
