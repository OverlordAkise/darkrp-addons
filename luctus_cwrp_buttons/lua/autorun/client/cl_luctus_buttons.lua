--Luctus Buttons
--Made by OverlordAkise

luctus_btn_frame = nil
luctus_btn_bgblur = nil

local function createCloseButton(el)
    local CloseButton = vgui.Create("DButton", el)
    CloseButton:SetText("X")
    CloseButton:SetPos(el:GetWide()-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(0,195,165))
    CloseButton.DoClick = function()
        gui.EnableScreenClicker( false )
        el:SetMouseInputEnabled( false )
        el:SetKeyboardInputEnabled( false )
        el:MoveTo(-1*ScrW(), el:GetY(),0.5,0)
        timer.Simple(0.5,function()
            el:Close()
        end)
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
end

local function beautifyButton(el)
    el.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(247, 249, 254))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(0,195,165))
            draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
        end
    end
end

local function LuctusSetStateText(panel,name,stateTable)
    if stateTable[name] then
        panel:SetText(string.format(LUCTUS_BUTTONS_STATE_ON, name))
    else
        panel:SetText(string.format(LUCTUS_BUTTONS_STATE_OFF, name))
    end
end

function LuctusOpenButtonMenu(state)
    if IsValid(luctus_btn_frame) then return end
    luctus_btn_frame = vgui.Create("DFrame")
    luctus_btn_frame:SetTitle(LUCTUS_BUTTONS_WINDOW_TITLE)
    luctus_btn_frame:SetSize(500, 300)
    luctus_btn_frame:Center()
    luctus_btn_frame:SetX(ScrW()+300)
    luctus_btn_frame:MakePopup()
    luctus_btn_frame:ShowCloseButton(false)
    luctus_btn_frame:MoveTo(ScrW()/2-luctus_btn_frame:GetWide()/2, luctus_btn_frame:GetY(),0.5,0)
    function luctus_btn_frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0,195,165))--32,34,37
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    createCloseButton(luctus_btn_frame)
    local plist = vgui.Create("DIconLayout", luctus_btn_frame)
    plist:Dock(FILL)
    plist:SetSpaceY(10)
    plist:SetSpaceX(10)
    plist:DockMargin(10,10,0,0)
    for k,v in pairs(LUCTUS_BUTTONS_BUTTONS) do
        local item = plist:Add("DButton")
        item:SetSize(230,50)
        item:SetText(string.format(LUCTUS_BUTTONS_BUTTONTEXT,k))
        item.k = k
        function item:DoClick()
            net.Start("luctus_buttons")
                net.WriteString(self.k)
            net.SendToServer()
        end
        beautifyButton(item)
    end
    for k,v in pairs(LUCTUS_BUTTONS_TOGGLEBUTTONS) do
        local item = plist:Add("DButton")
        item:SetSize(230,50)
        LuctusSetStateText(item,k,state)
        item.k = k
        function item:DoClick()
            if state[k] then state[k] = false else state[k] = true end
            LuctusSetStateText(item,k,state)
            net.Start("luctus_buttons")
                net.WriteString(self.k)
            net.SendToServer()
        end
        beautifyButton(item)
    end
end

net.Receive("luctus_buttons",function()
    local tab = net.ReadTable()
    print("[DEBUG]","table:",tab)
    PrintTable(tab)
    LuctusOpenButtonMenu(tab)
end)

net.Receive("luctus_buttons_notif",function()
    notification.AddLegacy(net.ReadString(),0,5)
end)

print("[luctus_buttons] cl loaded")
