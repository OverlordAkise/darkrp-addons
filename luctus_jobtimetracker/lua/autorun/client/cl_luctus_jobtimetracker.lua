--Luctus JobTimeTracker
--Made by OverlordAkise

LUCTUS_JTT_FRAME = LUCTUS_JTT_FRAME or nil

local function getActiveJobNames()
    local t = {}
    for k,v in ipairs(RPExtraTeams) do
        t[v.name] = true
    end
    return t
end

net.Receive("luctus_jtt",function()
    local targetName = net.ReadString()
    local jsonTable = net.ReadString()
    local tab = util.JSONToTable(jsonTable)
    
    LUCTUS_JTT_FRAME = vgui.Create("DFrame")
    LUCTUS_JTT_FRAME:SetTitle(targetName .. " | JobTimeTracker")
    LUCTUS_JTT_FRAME:SetSize( 460, 600 )
    LUCTUS_JTT_FRAME:Center()
    LUCTUS_JTT_FRAME:MakePopup()
    LUCTUS_JTT_FRAME:ShowCloseButton(false)
    function LUCTUS_JTT_FRAME:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", LUCTUS_JTT_FRAME)
    CloseButton:SetText("X")
    CloseButton:SetPos(LUCTUS_JTT_FRAME:GetWide()-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        LUCTUS_JTT_FRAME:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local liste = vgui.Create("DListView",LUCTUS_JTT_FRAME)
    liste:Dock(FILL)
    liste:SetMultiSelect(false)
    liste:AddColumn("Job"):SetWidth(200)
    liste:AddColumn("#Joins"):SetWidth(60)
    liste:AddColumn("ptime"):SetWidth(100)
    liste:AddColumn("rtime"):SetWidth(100)
    
    local jobs = getActiveJobNames()
    
    for k,v in ipairs(tab) do
        if not jobs[v.job] then continue end
        liste:AddLine(v.job, tonumber(v.changedToAmount), string.NiceTime(tonumber(v.time)), tonumber(v.time))
    end
end)

print("[luctus_jobtimetracker] cl loaded!")
