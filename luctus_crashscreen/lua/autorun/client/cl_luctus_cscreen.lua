--Luctus Crashscreen
--Made by OverlordAkise

--Delay in seconds before auto-reconnecting, set to 0 to disable
LUCTUS_CRASH_AUTORECONNECT = 180


local CrashScreen = nil
local showingScreen = false
local fadeStart = 0
local isReconnecting = false
local timeSinceLastPacket = 0

local thinkDelay = 0
hook.Add("Think","luctus_check_connection", function()
    if thinkDelay > CurTime() then return end
    thinkDelay = CurTime()+1
    local isTimingOut, lastReceived = GetTimeoutInfo()
    timeSinceLastPacket = lastReceived
    if isTimingOut and not showingScreen then
        LuctusCrashShow()
    end
    if not isTimingOut and showingScreen then
        LuctusCrashHide()
    end
    if lastReceived > LUCTUS_CRASH_AUTORECONNECT and not isReconnecting then
        isReconnecting = true
        RunConsoleCommand("retry")
    end
end)

local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)
local color_accent = Color(0, 195, 165)
local color_accent_dark = Color(0, 145, 115)
local color_button_dark = Color(20,20,20,200)
local color_button_light = Color(40,40,40,200)

function LuctusCrashShow()
    showingScreen = true
    fadeStart = CurTime()
    hook.Run("LuctusCrashShow")
    surface.PlaySound("vo/npc/male01/ohno.wav")
    if IsValid(CrashScreen) then
        CrashScreen:Remove()
    end
    CrashScreen = vgui.Create("DPanel")
    CrashScreen:SetSize(ScrW(),ScrH())
    CrashScreen:SetPos(0,0)
    CrashScreen:SetAlpha(0)
    CrashScreen:AlphaTo(255,2)
    function CrashScreen:Paint(w, h)
        surface.SetDrawColor(Color(0,0,0,200))
        surface.DrawRect(0,0,w,h)
        draw.SimpleTextOutlined("connection to the server has been lost","DermaLarge",w/2,h/2-100,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,color_black)
        if LUCTUS_CRASH_AUTORECONNECT > 0 then
            draw.SimpleTextOutlined("You will automatically reconnect in "..math.floor(LUCTUS_CRASH_AUTORECONNECT-timeSinceLastPacket).."seconds","Trebuchet24",w/2, h/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,color_black)
        end
    end

    local reconnectBtn = vgui.Create("DButton",CrashScreen)
    reconnectBtn:SetSize(100,50)
    reconnectBtn:SetPos(ScrW()/2-150,ScrH()/2+100)
    reconnectBtn:SetTextColor(color_white)
    reconnectBtn:SetFont("Trebuchet24")
    reconnectBtn:SetText("Reconnect")
    reconnectBtn.Paint = paintFunction
    reconnectBtn.DoClick = function()
        RunConsoleCommand("retry")
    end
    function reconnectBtn:Paint(w,h)
        surface.SetDrawColor(self:IsHovered() and color_button_light or color_button_dark)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_accent_dark)
        surface.DrawOutlinedRect(0,0,w,h)
    end

    local leaveBtn = vgui.Create("DButton",CrashScreen)
    leaveBtn:SetSize(100,50)
    leaveBtn:SetPos(ScrW()/2+50,ScrH()/2+100)
    leaveBtn:SetTextColor(color_white)
    leaveBtn:SetFont("Trebuchet24")
    leaveBtn:SetText("Disconnect")
    leaveBtn.Paint = paintFunction
    leaveBtn.DoClick = function(  )
        RunConsoleCommand("disconnect")
    end
    function leaveBtn:Paint(w,h)
        surface.SetDrawColor(self:IsHovered() and color_button_light or color_button_dark)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_accent_dark)
        surface.DrawOutlinedRect(0,0,w,h)
    end
    
    gui.EnableScreenClicker(true)
end

function LuctusCrashHide()
    showingScreen = false
    hook.Run("LuctusCrashHide")
    CrashScreen:AlphaTo(0,0.5)
    timer.Simple(0.5,function()
        if IsValid(CrashScreen) then CrashScreen:Remove() end
    end)
    surface.PlaySound("vo/npc/male01/yeah02.wav")
    gui.EnableScreenClicker(false)
end
  
print("[luctus_crashscreen] cl loaded")
