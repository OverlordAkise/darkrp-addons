--Luctus Statistics
--Made by OverlordAkise

LUCTUS_STATS_FRAME = nil

local function getActiveJobNames()
    local t = {}
    for k,v in ipairs(RPExtraTeams) do
        t[v.name] = true
    end
    return t
end

net.Receive("luctus_statistics",function()
    local jsonTable = net.ReadString()
    local tab = util.JSONToTable(jsonTable)
    
    LUCTUS_STATS_FRAME = vgui.Create("DFrame")
    LUCTUS_STATS_FRAME:SetTitle("Luctus' Statistics v1 | by OverlordAkise")
    LUCTUS_STATS_FRAME:SetSize( 300, 500 )
    LUCTUS_STATS_FRAME:Center()
    LUCTUS_STATS_FRAME:MakePopup()
    LUCTUS_STATS_FRAME:ShowCloseButton(false)
    function LUCTUS_STATS_FRAME:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    --LUCTUS_STATS_FRAME:MoveTo(ScrW()/2-450,LUCTUS_STATS_FRAME:GetY(), 1, 0, -1)

    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", LUCTUS_STATS_FRAME)
    CloseButton:SetText("X")
    CloseButton:SetPos(LUCTUS_STATS_FRAME:GetWide()-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        LUCTUS_STATS_FRAME:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local liste = vgui.Create("DListView",LUCTUS_STATS_FRAME)
    liste:Dock(FILL)
    liste:SetMultiSelect(false)
    liste:AddColumn("Job"):SetWidth(200)
    liste:AddColumn("#Joins"):SetWidth(50)
    liste:AddColumn("hours"):SetWidth(50)
    
    local jobs = getActiveJobNames()
    
    for k,v in ipairs(tab) do
        if not jobs[v.jobname] then continue end
        liste:AddLine(v.jobname, tonumber(v.changedToAmount), math.Round(v.playtime/60/60))
    end
end)

print("[luctus_statistics] cl loaded!")
