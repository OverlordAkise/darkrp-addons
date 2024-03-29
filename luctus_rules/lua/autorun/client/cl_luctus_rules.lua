--Luctus Rules
--Made by OverlordAkise

local frame = nil
--Close Button Top Right
local function AddCloseButton(frame)
    local frameX, frameY = frame:GetSize()
    
    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(frameX-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(0, 195, 165))
    CloseButton.DoClick = function()
        frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
end
function LuctusRulesOpen(delayTillClose,targetURL)
    if IsValid(frame) then return end
    
    if not targetURL then
        targetURL = LUCTUS_RULES_RULES_URL
    end
    
    --Main Window
    frame = vgui.Create("DFrame")
    frame:SetSize(800,600)
    frame:SetTitle(LUCTUS_RULES_WINDOW_TITLE)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    --[[
    --For Text:
    local MainPanel = vgui.Create("DTextEntry",frame)
    MainPanel:Dock(FILL)
    MainPanel:SetVerticalScrollbarEnabled(true)
    MainPanel:SetMultiline(true)
    MainPanel:SetTextColor(Color(255,255,255))
    MainPanel:SetText(text_rules)
    MainPanel:SetPaintBackground(false)
    MainPanel:SetDrawLanguageID(false)
    --]]

    --For HTML:
    local MainPanel = vgui.Create("DHTML",frame)
    MainPanel:Dock(FILL)
    MainPanel:OpenURL(targetURL)
    --MainPanel:SetHTML(html_rules)
    --[[
    local ctrls = vgui.Create( "DHTMLControls", frame )
    ctrls:Dock(TOP)
    ctrls:SetHTML( MainPanel )
    ctrls.AddressBar:SetText(targetURL)
    --]]
    
    if not delayTillClose or delayTillClose <= 0 then
        AddCloseButton(frame)
    else
        timer.Create("luctus_rules",delayTillClose,1,function()
            if IsValid(frame) then
                AddCloseButton(frame)
                surface.PlaySound("buttons/button6.wav")
                chat.AddText("[rules] You may close the rules page now.")
            end
        end)
    end
end

hook.Add("OnPlayerChat","luctus_openrules",function(ply,text,team,dead)
    if ply ~= LocalPlayer() then return end
    if text == LUCTUS_RULES_CHATCOMMAND then
        LuctusRulesOpen()
    end
    if text == LUCTUS_RULES_JOBCOMMAND then
        LuctusRulesOpenJob(ply:Team())
    end
end)

hook.Add("InitPostEntity","luctus_openrulesonjoin",function()
    if not LUCTUS_RULES_OPEN_ON_JOIN then return end
    timer.Simple(5,function()
        LuctusRulesOpen()
    end)
end)
concommand.Add("luctus_rules",LuctusRulesOpen)

net.Receive("luctus_rules",function()
    local delay = net.ReadInt(16)
    if delay and delay == -1 then
        if IsValid(frame) then
            frame:Close()
            timer.Remove("luctus_rules")
        end
        return
    end
    LuctusRulesOpen(delay)
end)

--Job-additions

function LuctusRulesOpenJob(plyteam)
    local jobname = team.GetName(plyteam)
    if LUCTUS_RULES_USE_ANCHORS then
        LuctusRulesOpen(0,LUCTUS_RULES_RULES_URL.."#"..jobname)
        return
    end
    if LUCTUS_RULES_JOB_URLS[jobname] then
        LuctusRulesOpen(0,LUCTUS_RULES_JOB_URLS[jobname])
    end
end

hook.Add("OnPlayerChangedTeam","luctus_rules_jobs",function(ply,before,after)
    if not LUCTUS_RULES_JOB_ENABLED then return end
    LuctusRulesOpenJob(after)
end)


print("[luctus_rules] cl loaded")
