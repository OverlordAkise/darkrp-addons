--Luctus Mining System
--Made by OverlordAkise

local accent_col = Color(0, 195, 165)
local accent_col_dark = Color(0, 125, 95)
local lightDark = Color(40,40,40)
local dark = Color(10,10,10)
local buttonTextColor = Color(200,200,200)

LUCTUS_MINER_MY_ORES = LUCTUS_MINER_MY_ORES or {}

hook.Add("InitPostEntity","luctus_miner_get",function()
    net.Start("luctus_miner_sync_all")
    net.SendToServer()
end)

net.Receive("luctus_miner_sync_all",function()
    LUCTUS_MINER_MY_ORES = net.ReadTable()
    print("[luctus_miner] Synced ore!")
end)

net.Receive("luctus_miner_sync",function()
    local name = net.ReadString()
    local newValue = net.ReadUInt(16)
    notification.AddLegacy(Format("+%d %s",(newValue-LUCTUS_MINER_MY_ORES[name]),name), NOTIFY_GENERIC, 3)
    surface.PlaySound("buttons/lightswitch2.wav")
    LUCTUS_MINER_MY_ORES[name] = newValue
end)

if LUCTUS_MINER_HUD_ALWAYSON then
    hook.Add("HUDPaint","luctus_miner_hud",LuctusMinerHUD)
else
    hook.Add("OnContextMenuOpen","luctus_miner_hud_on",function()
        hook.Add("HUDPaint","luctus_miner_hud",LuctusMinerHUD)
    end)

    hook.Add("OnContextMenuClose","luctus_miner_hud_off",function()
        hook.Remove("HUDPaint","luctus_miner_hud")
    end)
end


function LuctusMinerHUD()
    if LUCTUS_MINER_JOBWHITELIST and not LUCTUS_MINER_JOBNAMES[team.GetName(LocalPlayer():Team())] then return end
    local scrh2 = ScrH()/2
    surface.SetDrawColor(0,0,0,200)
    surface.DrawRect(5, scrh2, 145, (#LUCTUS_MINER_ORES+1) * 24)
    
    surface.SetFont("Trebuchet24")
    surface.SetTextPos(10,scrh2)
    surface.SetDrawColor(255,255,255,255)
    surface.SetTextColor(255,255,255,255)
    surface.DrawText("-Ore Inventory-")
    
    for k,v in ipairs(LUCTUS_MINER_ORES) do
        surface.SetTextColor(v.Color)
        surface.SetTextPos(10,scrh2+k*24)
        surface.DrawText(v.Name..": "..LUCTUS_MINER_MY_ORES[v.Name])
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


local function CreateCloseButton(parent)
    local parent_x, parent_y = parent:GetSize()
    local CloseButton = vgui.Create("DButton", parent)
    CloseButton:SetPos(parent_x-31, 1)
    CloseButton:SetSize(30, 30)
    CloseButton:SetText("X")
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        parent:Close()
    end
    function CloseButton:Paint(w, h)
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

net.Receive("luctus_miner_craft",function()
    if IsValid(MineCraftPanel) then return end
    local npc = net.ReadEntity()
    MineCraftPanel = CreateFrame("Miner | Crafting Table")

    local DScrollPanel = vgui.Create( "DScrollPanel", MineCraftPanel )
    DScrollPanel:Dock(FILL)

    for entName,oreNeeded in pairs(LUCTUS_MINER_CRAFTABLES) do
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
        label:SetText(LuctusMinerGetName(entName))

        local rLabel = vgui.Create("DLabel",row)
        rLabel:Dock(LEFT)
        rLabel:SetSize(200,25)
        local rText = ""
        for oreName,amount in pairs(oreNeeded) do
            rText = rText .. " " .. oreName .. " " .. amount .. " ,"
        end
        rText = string.sub(rText,1,#rText-1)
        rLabel:SetText(rText)

        local button = vgui.Create("DButton",row)
        button:Dock(RIGHT)
        button:SetText("Craft")
        button:SetColor(buttonTextColor)
        button:DockMargin(10,0,20,0)
        button.DoClick = function()
            net.Start("luctus_miner_craft")
                net.WriteString(entName)
                net.WriteEntity(npc)
            net.SendToServer()
        end
        BeautifyButton(button)
    end
end)


net.Receive("luctus_miner_npc",function()
    if IsValid(MineNPCPanel) then return end
    local npc = net.ReadEntity()
    local sellTable = net.ReadTable()
    MineNPCPanel = CreateFrame("Miner | Ore-Seller")

    local DScrollPanel = vgui.Create("DScrollPanel", MineNPCPanel)
    DScrollPanel:Dock(FILL)

    for k,v in ipairs(LUCTUS_MINER_ORES) do
        local row = DScrollPanel:Add("DPanel")
        row:SetPos(0,(k-1)*25)
        row:SetSize(700,25)
        row:SetPaintBackground(false)

        local oreName = vgui.Create("DLabel",row)
        oreName:SetPos(20,3)
        oreName:SetColor(v.Color)
        oreName:SetText(v.Name)

        local oreSlider = vgui.Create("DNumSlider",row)
        oreSlider:SetPos(120,0)
        oreSlider:SetSize(400,25)
        oreSlider:SetText(v.Name)
        oreSlider:SetMin(0)
        oreSlider:SetMax(LUCTUS_MINER_MY_ORES[v.Name] or 0)
        oreSlider:SetDecimals()
        oreSlider:SetDark(false)
        oreSlider:GetTextArea():SetDrawLanguageID(false)
        oreSlider:GetChildren()[3]:SetSize(0,0)
        oreSlider:GetChildren()[3]:Dock(NODOCK) -- Remove stupid label on the left

        local sellValueLabel = vgui.Create("DLabel",row)
        sellValueLabel:SetPos(530,3)
        sellValueLabel:SetText("x "..(sellTable[v.Name] or "<ERR>").."$")  

        local sellButton = vgui.Create("DButton",row)
        sellButton:SetPos(600,2)
        sellButton:SetText("Sell")
        sellButton:SetColor(buttonTextColor)
        sellButton.textfield = numTextField
        sellButton.DoClick = function()
            local text = oreSlider:GetValue()
            local num = 0
            if text == "" then
                num = LUCTUS_MINER_MY_ORES[v.Name]
            else
                num = math.Round(tonumber(text))
            end
            net.Start("luctus_miner_npc")
                net.WriteUInt(num,16)
                net.WriteString(v.Name)
                net.WriteEntity(npc)
            net.SendToServer()
        end
        BeautifyButton(sellButton)
    end
    local pickaxeButton = vgui.Create("DButton",MineNPCPanel)
    pickaxeButton:Dock(BOTTOM)
    pickaxeButton:SetText("Give me a pickaxe!")
    pickaxeButton.DoClick = function()
        net.Start("luctus_miner_get_pickaxe")
            net.WriteEntity(npc)
        net.SendToServer()
        MineNPCPanel:Close()
    end
    BeautifyButton(pickaxeButton)
end)

print("[luctus_miner] cl loaded")
