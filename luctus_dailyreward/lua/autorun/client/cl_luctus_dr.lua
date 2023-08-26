--Luctus Daily Rewards
--Made by OverlordAkise

local accent_col = Color(0, 195, 165)
local accent_col_dark = Color(0, 125, 95)
local col_red = Color(200,0,0)
local col_green = Color(0,200,0)

hook.Add("InitPostEntity", "luctus_dayward_sync", function()
    net.Start("luctus_dayward_sync")
    net.SendToServer()
end)

LUCTUS_DAYWARD_LAST = 0
LUCTUS_DAYWARD_STREAK = 1
net.Receive("luctus_dayward_sync",function()
    LUCTUS_DAYWARD_LAST = net.ReadInt(32)
    LUCTUS_DAYWARD_STREAK = net.ReadInt(32)
    if not LuctusMotdOpen then
        LuctusDaywardOpenMenu()
    else
        hook.Add("LuctusMotdClosed","luctus_dailyreward",function()
            LuctusDaywardOpenMenu()
        end)
    end
    
end)

net.Receive("luctus_dayward",function()
    LUCTUS_DAYWARD_LAST = os.time()
    LUCTUS_DAYWARD_STREAK = LUCTUS_DAYWARD_STREAK + 1
end)

hook.Add("OnPlayerChat", "luctus_dayward_open", function(ply,text) 
    if ply ~= LocalPlayer() then return end
    if text == "!daily" then
        LuctusDaywardOpenMenu()
    end
end)

local function LuctusPrettifyScrollbar(el)
  function el:Paint() return end
	function el.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
		draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))

	end
	function el.btnUp:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,accent_col)
		draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
	end
	function el.btnDown:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,accent_col)
		draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
	end
end

function DrawHighlightBorder(el,w,h,col)
    surface.SetDrawColor(col)
    surface.DrawLine(0,0,w,0)
    surface.DrawLine(w-1,0,w-1,h-1)
    surface.DrawLine(w-1,h-1,0,h-1)
    surface.DrawLine(0,h-1,0,0)
end

local frame = nil

function LuctusDaywardOpenMenu()
    local IsButtonAfterToday = false
    frame = vgui.Create("DFrame")
    frame:SetSize(300, 500)
    frame:Center()
    frame:SetTitle("Luctus | Daily Reward")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    local parent_x, parent_y = frame:GetSize()
    local CloseButton = vgui.Create( "DButton", frame )
    CloseButton:SetPos( parent_x-30, 0 )
    CloseButton:SetSize( 30, 30 )
    CloseButton:SetText("X")
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        frame:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local explanation = vgui.Create("DLabel", frame)
    explanation:SetText("Put "..LUCTUS_DAYWARD_NAME_TAG.." infront of your name to get "..LUCTUS_DAYWARD_NAME_MULTIPLIER.."x rewards!")
    --explanation:SetDark(1)
    explanation:SetTextInset(10,0)
    explanation:Dock(TOP)
    function explanation:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
    end
    local statusPanel = vgui.Create("DLabel", frame)
    statusPanel.HasBetterRewards = string.StartWith(LocalPlayer():SteamName(),LUCTUS_DAYWARD_NAME_TAG)
    statusPanel:SetText(statusPanel.HasBetterRewards and "Status: Tag found!" or "Status: No Tag in your name found!")
    --statusPanel:SetColor(statusPanel.HasBetterRewards and Color(0,255,0) or Color(255,0,0))
    if statusPanel.HasBetterRewards then statusPanel:SetDark(1) end
    statusPanel:SetTextInset(10,0)
    statusPanel:Dock(TOP)
    function statusPanel:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, statusPanel.HasBetterRewards and col_green or col_red)
    end
    
    local liste = vgui.Create("DScrollPanel", frame)
    --liste:DockMargin(5,5,5,5)
    liste:DockPadding(5,5,5,5)
    liste:Dock(FILL)
    LuctusPrettifyScrollbar(liste:GetVBar())
    for k,v in ipairs(LUCTUS_DAYWARD_AMOUNT) do
        local panel = liste:Add("DPanel")
        --panel:SetSize(510,120)
        panel:Dock(TOP)
        panel.text = ""
        for k,amount in pairs(v) do
            if panel.text ~= "" then panel.text = panel.text.."," end
            if LUCTUS_DAYWARD_TYPES[k] then
                panel.text = panel.text .. " " .. amount .. LUCTUS_DAYWARD_TYPES[k][1]
            end
        end
        function panel:Paint(w,h)
            draw.SimpleTextOutlined(self.text, "Trebuchet18", 10, 5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,255) )
            DrawHighlightBorder(self,w,h,accent_col)
        end
        
        
        
        local bg = vgui.Create("DButton",panel)
        bg:SetSize(70, 21)
        bg:SetPos(200,2)
        bg:SetText("claim")
        bg:SetTextColor(accent_col)
        --print("[DEBUG]","last date:",os.date("%Y%m%d",LUCTUS_DAYWARD_LAST))
        --print("[DEBUG]","cur date:",os.date("%Y%m%d"))
        --print("[DEBUG]","streak:",LUCTUS_DAYWARD_STREAK)
        --print("[DEBUG]","last:",LUCTUS_DAYWARD_LAST)
        
        if os.date("%Y%m%d",LUCTUS_DAYWARD_LAST) == os.date("%Y%m%d") and k == LUCTUS_DAYWARD_STREAK then
            bg:SetEnabled(false)
            bg:SetText("-later-")
        end
        if k < LUCTUS_DAYWARD_STREAK then
            bg:SetEnabled(false)
            bg:SetText("-claimed-")
        end
        if k > LUCTUS_DAYWARD_STREAK then
            bg:SetEnabled(false)
            bg:SetText("-later-")
        end
        bg.Paint = function(self,w,h)
            DrawHighlightBorder(self,w,h,self:IsEnabled() and accent_col or accent_col_dark)
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
        bg.DoClick = function(self)
            net.Start("luctus_dayward")
            net.SendToServer()
            self:SetEnabled(false)
            self:SetText("-claimed-")
            LUCTUS_DAYWARD_LAST = os.time()
            LUCTUS_DAYWARD_STREAK = LUCTUS_DAYWARD_STREAK + 1
        end
    end
end

print("[luctus_dailyrewards] cl loaded")
