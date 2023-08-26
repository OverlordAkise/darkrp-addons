--Luctus MOTD
--Made by OverlordAkise

LUCTUS_MOTD_COMMAND = "!motd"
LUCTUS_MOTD_STARTURL = "https://luctus.at"
LUCTUS_MOTD_TOP_MESSAGE = "Welcome to MyServer!"

--This can be URL strings or functions
LUCTUS_MOTD_BUTTONS = {
    ["Steam Group"] = "https://eternitycommunity.mistforums.com/",
    ["Forum"] = "https://eternitycommunity.mistforums.com/",
    ["Rules"] = "https://eternitycommunity.mistforums.com/thread/rules--080121-663088",
    ["Donate"] = "https://eternitycommunity.mistforums.com/donate",
}

local color_accent = Color(0, 195, 165)
local color_button = Color(46,46,46)
local color_button_hover = Color(88, 93, 98)
local color_background = Color(32, 34, 37, 240)

-- CONFIG END

local color_white = Color(255,255,255)

surface.CreateFont("luctus_motd_font", {
    font = "Tahoma",
    size = 28,
    weight = 5,
    blursize = 0,
    scanlines = 0,
    antialias = true,
})

luctus_motd_frame = luctus_motd_frame or nil
local firstTimeClosing = true
function LuctusMotdOpen()
    if IsValid(luctus_motd_frame) then return end
    gui.EnableScreenClicker(true)
    luctus_motd_frame = vgui.Create("DFrame")
    luctus_motd_frame:SetSize(ScrW()-250, ScrH()-200)
    luctus_motd_frame:Center()
    luctus_motd_frame:SetTitle("")
    luctus_motd_frame:SetDraggable(false)
    luctus_motd_frame:ShowCloseButton(false)
    luctus_motd_frame:MakePopup()
    luctus_motd_frame.startTime = SysTime()
    function luctus_motd_frame:Paint(w, h)
        Derma_DrawBackgroundBlur(self, self.startTime)
        draw.RoundedBox(0, 0, 24, w, h, color_background)
    end
    luctus_motd_frame.OnClose = function(self)
        gui.EnableScreenClicker(false)
    end

    local leftPanel = vgui.Create("DPanel", luctus_motd_frame)
    leftPanel:SetSize(350, ScrH()-50)
    leftPanel:Dock(LEFT)
    leftPanel:DockMargin(10,10,10,10)
    function leftPanel:Paint(w, h) end


    local topLeft = vgui.Create("DPanel", leftPanel)
    topLeft:SetSize(300, 64)
    topLeft:Dock(TOP)
    function topLeft:Paint(w, h) end

    local avatar = vgui.Create("AvatarImage", topLeft)
    avatar:SetPlayer(LocalPlayer(), 64)
    avatar:SetSize(64,64)
    avatar:Dock(LEFT)

    local name = vgui.Create("DLabel", topLeft)
    name:SetText(LocalPlayer():GetName())
    name:SetFont("DermaLarge")
    name:SetSize(300,100)
    name:Dock(LEFT)
    name:DockMargin(10,0,0,0)

    local mapText = vgui.Create("DLabel", leftPanel)
    mapText:SetSize(250,30)
    mapText:Dock(TOP)
    mapText:SetText("Map: "..game.GetMap())
    mapText:SetFont("luctus_motd_font")

    local playercount = vgui.Create("DLabel", leftPanel)
    playercount:SetSize(250,30)
    playercount:Dock(TOP)
    playercount:SetText("Players: "..#player.GetAll().."/"..game.MaxPlayers())
    playercount:SetFont("luctus_motd_font")

    local leftScrollPanel = vgui.Create("DScrollPanel", leftPanel)
    leftScrollPanel:Dock(FILL)
    function leftScrollPanel:Paint(w, h) end
    
    local htmlPanel = vgui.Create("DHTML", luctus_motd_frame)
    htmlPanel:Dock(FILL)
    htmlPanel:OpenURL(LUCTUS_MOTD_STARTURL)


    LUCTUS_MOTD_BUTTONS["Close"] = function()
        if firstTimeClosing then
            hook.Run("LuctusMotdClosed")
            firstTimeClosing = false
        end
        luctus_motd_frame:Close()
    end
    
    for k, v in SortedPairs(LUCTUS_MOTD_BUTTONS,true) do
        local button = vgui.Create("DButton", leftScrollPanel)
        button:SetSize(250, 50)
        button:Dock(TOP)
        button:DockMargin(0,0,0,5)
        button:SetText("   "..k) --lazy
        button:SetContentAlignment(4)
        button:SetColor(color_white)
        button.bcolor = color_button
        button.accentWidth = 2
        button.accentTarget = 2
        button.accentSwitch = 0
        button:SetFont("luctus_motd_font")
        function button:Paint(w, h)
            self.accentWidth = Lerp(SysTime()-self.accentSwitch,self.accentWidth,self.accentTarget)
            draw.RoundedBox(0, 0, 0, w, h, color_accent)
            draw.RoundedBox(0, self.accentWidth, 0, w, h, self.bcolor)
        end
        function button:OnCursorEntered()
            self.bcolor = color_button_hover
            surface.PlaySound("UI/buttonrollover.wav")
            self.accentSwitch = SysTime()
            self.accentTarget = 10
        end
        function button:OnCursorExited()
            self.bcolor = color_button
            self.accentSwitch = SysTime()
            self.accentTarget = 2
        end
        function button:DoClick()
            surface.PlaySound("UI/buttonclick.wav")
            if type(v) == "string" then
                htmlPanel:OpenURL(v)
            else
                v()
            end
        end
    end


    local topMessage = vgui.Create("DPanel", luctus_motd_frame)
    topMessage:Dock(TOP)
    topMessage:SetSize(ScrW()-50, 40)
    function topMessage:Paint(w, h)
        draw.DrawText(LUCTUS_MOTD_TOP_MESSAGE,"DermaLarge",0,5,color_white,TEXT_ALIGN_LEFT)
    end
end

hook.Add("InitPostEntity", "luctus_motd_show", function()
    LuctusMotdOpen()
end)

hook.Add("OnPlayerChat", "luctus_motd", function(ply, text)
    if ply == LocalPlayer() and text == LUCTUS_MOTD_COMMAND then
        LuctusMotdOpen()
    end
end)

concommand.Add("luctus_motd", function()
    LuctusMotdOpen()
end)

print("[luctus_motd] cl loaded")
