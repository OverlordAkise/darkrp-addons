--Luctus Popups
--Made by OverlordAkise

local color_background = Color(64,64,64)
local color_button_bg = Color(90,90,90)
local color_button_bg_hover = Color(50,50,50)
local color_text = Color(255,255,255,255)
local color_header = Color(124,124,124)
local color_accent = Color(0, 195, 165)
local color_black = Color(0,0,0,255)
local color_white = Color(255,255,255,255)

--Keep this to 4 buttons, not more
LUCTUS_POPUPS_BUTTONS = {
    {"Goto",function(ply) RunConsoleCommand("ulx", "goto", "$"..ply:SteamID()) end},
    {"Return",function(ply) RunConsoleCommand("ulx", "return", "^") end},
    {"Bring T",function(ply) RunConsoleCommand("ulx", "bring", "$"..ply:SteamID()) end},
    {"ReturnT",function(ply) RunConsoleCommand("ulx", "return", "$"..ply:SteamID()) end},
}

LUCTUS_POPUPS = LUCTUS_POPUPS or {}

local function drawButton(but,w,h)
    draw.RoundedBox(0, 0, 0, w, h, color_accent)
    if but:IsHovered() then
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_button_bg)
    else
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_button_bg_hover)
    end
end

local w, h = 275, 125
function LuctusPopupCreate(ply, request, admin)
    surface.PlaySound("buttons/button16.wav")

    local notiFrame = vgui.Create("DFrame")
    notiFrame.ply = ply
    notiFrame.sid = ply:SteamID()
    notiFrame.isClaimed = false
    notiFrame:SetSize(w,h)
    notiFrame:SetPos(25, 25)
    notiFrame:ShowCloseButton(false)
    notiFrame:SetDraggable(false)
    function notiFrame:Paint(w, h)
        draw.RoundedBox(4,0,0,w,h,color_background)
        draw.RoundedBox(0,0,0,w,18,color_header)
        draw.RoundedBox(0,0,18,w,1,color_accent)
    end
    notiFrame.lblTitle:SetColor(color_text)
    notiFrame.lblTitle:SetContentAlignment(7)

    notiFrame:SetTitle(ply:Nick())
    if admin and IsValid(admin) then
        notiFrame:SetTitle(ply:Nick().." - Claimed By "..admin:Nick())
        notiFrame.isClaimed = true
    end

    local closeBut = vgui.Create("DButton", notiFrame)
    closeBut:SetText("×")
    closeBut:SetColor(color_text)
    closeBut:SetPos(w-20, 2)
    closeBut:SetSize(15, 15)
    function closeBut:Paint(w,h) end
    function closeBut:DoClick()
        notiFrame:Close()
        surface.PlaySound("UI/buttonclick.wav")
    end

    local pText = vgui.Create("RichText", notiFrame)
    pText:SetPos(15, 30)
    pText:SetSize(w-100, h-35)
    pText:SetContentAlignment(7)
    pText:InsertColorChange(255, 255, 255, 255)
    pText:SetVerticalScrollbarEnabled(false)
    function pText:PerformLayout()
        pText:SetFontInternal("DermaDefault")
    end
    pText:AppendText(request.."\n")
    
    notiFrame.pText = pText
    
    for k,tab in pairs(LUCTUS_POPUPS_BUTTONS) do
        --if k >= 5 then break end
        local but = vgui.Create("DButton", notiFrame)
        but:SetPos(202, 21 * k)
        but:SetSize(70, 18)
        but:SetText(tab[1])
        but.bfunc = tab[2]
        but.frame = notiFrame
        but:SetColor(color_text)
        but:SetContentAlignment(5)
        but:SetTextColor(color_text)
        but.Paint = drawButton
        function but:DoClick()
            if not notiFrame or not IsValid(notiFrame) then return end
            self.bfunc(notiFrame.ply,self)
            surface.PlaySound("UI/buttonclick.wav")
        end
    end

    local caseButton = vgui.Create("DButton", notiFrame)
    caseButton:SetPos(202, 21 * (#LUCTUS_POPUPS_BUTTONS+1))
    caseButton:SetSize(70, 18)
    caseButton:SetText(notiFrame.isClaimed and "Close" or "Claim")
    if admin and IsValid(admin) and admin ~= LocalPlayer() then
        caseButton:SetText("-----")
    end
    caseButton:SetColor(color_text)
    caseButton:SetContentAlignment(5)
    caseButton:SetTextColor(color_text)
    caseButton.Paint = drawButton
    function caseButton:DoClick()
        net.Start(notiFrame.isClaimed and "luctus_popup_close" or "luctus_popup_claim")
            net.WriteEntity(ply)
        net.SendToServer()
        surface.PlaySound("UI/buttonclick.wav")
    end
    notiFrame.cbutton = caseButton

    notiFrame:SetPos( -w - 30, 25 + (130 * table.Count(LUCTUS_POPUPS)) )
    notiFrame:MoveTo( 25, 25 + (130 * table.Count(LUCTUS_POPUPS)), 0.2, 0, 1)

    function notiFrame:OnRemove()
        LUCTUS_POPUPS[self.sid] = nil
        local c = 1
        for steamid,frame in pairs(LUCTUS_POPUPS) do
            frame:MoveTo( 25, 25 + ( 130 * ( c - 1 ) ), 0.1, 0, 1 )
            c = c + 1
        end
    end
    LUCTUS_POPUPS[ply:SteamID()] = notiFrame
end

net.Receive("luctus_popup_open", function(len, ply)
    local rePly = net.ReadEntity()
    local text = net.ReadString()
    local claimAdmin = net.ReadEntity()

    if not LUCTUS_POPUPS[rePly:SteamID()] then
        LuctusPopupCreate(rePly, text, claimAdmin)
    else --Update old
        local steamid = rePly:SteamID()
        local frame = LUCTUS_POPUPS[steamid]
        if not frame or not frame.pText then return end
        frame.pText:AppendText(text.."\n")
    end
end)

net.Receive("luctus_popup_claim",function()
    local rePly = net.ReadEntity()
    local admin = net.ReadEntity()
    local frame = LUCTUS_POPUPS[rePly:SteamID()]
    if not frame then return end
    frame:SetTitle(rePly:Nick().." - Claimed By "..admin:Nick())
    frame.isClaimed = true
    local btn = frame.cbutton
    if not btn then return end
    if admin == LocalPlayer() then
        btn:SetText("Close")
    else
        btn:SetText("-----")
    end
end)

net.Receive("luctus_popup_close",function()
    local steamid = net.ReadString()
    local frame = LUCTUS_POPUPS[steamid]
    if not frame then return end
    frame:Close()
end)

net.Receive("luctus_popup_notify",function()
    surface.PlaySound("buttons/button16.wav")
    local text = net.ReadString()
    chat.AddText(color_accent,"[ticket] ",color_white,text)
end)

print("[luctus_popups] cl loaded")
