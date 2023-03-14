--Luctus Serverstatus
--Made by OverlordAkise

LucStatFrame = nil
LucStatList = nil
LuctusServerStatus = "N/A"
LuctusServerStatusColor = white

local white = Color(255,255,255)
local red = Color(255,0,0)
local green = Color(0,255,0)

function LuctusOpenServerStatus()
    if LucStatFrame and IsValid(LucStatFrame) then return end
    net.Start("luctus_serverstatus")
    net.SendToServer()
    --Main Window
    LucStatFrame = vgui.Create("DFrame")
    LucStatFrame:SetSize(700,600)
    LucStatFrame:SetTitle("Luctus Serverstatus")
    LucStatFrame:Center()
    LucStatFrame:MakePopup()
    LucStatFrame:ShowCloseButton(false)
    LucStatFrame.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    local frameX, frameY = LucStatFrame:GetSize()
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", LucStatFrame)
    CloseButton:SetText("X")
    CloseButton:SetPos(frameX-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(0, 195, 165))
    CloseButton.DoClick = function()
        LucStatFrame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local topPanel = vgui.Create("DPanel", LucStatFrame)
    topPanel:Dock(TOP)
    topPanel:SetHeight(160)
    function topPanel:Paint() end
    
    local banner = vgui.Create("DImage", topPanel)
    banner:Dock(LEFT)
    banner:SetWide(320)
    banner:DockMargin(3,0,0,0)
    banner:SetMaterial(luctus_banner)
    
    local statText = vgui.Create("DPanel", topPanel)
    statText:Dock(RIGHT)
    statText:SetWide(frameX-330)
    statText:SetText("")
    statText:SetPaintBackground(false)
    function statText:Paint(w,h)
        draw.DrawText(GetHostName(),"DermaLarge",10,10,white,TEXT_ALIGN_LEFT)
        draw.DrawText("Players: "..#player.GetAll(),"DermaLarge",10,50,white,TEXT_ALIGN_LEFT)
        draw.DrawText("Status: "..LuctusServerStatus,"DermaLarge",10,90,LuctusServerStatusColor,TEXT_ALIGN_LEFT)
    end
    
    LucStatList = vgui.Create("DListView", LucStatFrame)
    LucStatList:Dock(FILL)
    LucStatList:DockMargin(2,5,2,2)
    LucStatList:AddColumn("Name")
    LucStatList:AddColumn("Status")
    LucStatList:AddColumn("Value")
end

net.Receive("luctus_serverstatus",function()
    local lenge = net.ReadInt(18)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    --PrintTable(tab)
    
    LuctusServerStatus = "OK"
    LuctusServerStatusColor = green
    LucStatList:Clear()
    for k,v in pairs(tab) do
        if not v[1] then
            LuctusServerStatus = "WARNING"
            LuctusServerStatusColor = red
        end
        if LucStatList and IsValid(LucStatList) then
            
            LucStatList:AddLine(k,v[1] and "OK" or "WARNING",v[2])
        end
    end
end)

--Chatcommands
hook.Add("OnPlayerChat","luctus_serverstatus_open",function(ply,text,team,dead)
    if(ply == LocalPlayer() and text == "!serverstatus")then
        LuctusOpenServerStatus()
    end
end)
concommand.Add("luctus_serverstatus",LuctusOpenServerStatus)

--Banner Download
luctus_banner = luctus_banner or nil
hook.Add("InitPostEntity","luctus_mat_download",function()
    if file.Exists("istina_banner.png","DATA") then
        print("[luctus_status] Banner already exists")
        luctus_banner = Material("../data/istina_banner.png")
        return
    end
    http.Fetch("https://luctus.at/images/istina_banner.png",function(body,size,headers,code)
        if code != 200 then
            ErrorNoHaltWithStack(body)
            return
        end
        file.Write("istina_banner.png",body)
        print("[luctus_status] Banner saved successfully!")
        luctus_banner = Material("../data/istina_banner.png")
    end,
    function(err)
        ErrorNoHaltWithStack(err)
    end)
end)


--Statistics
LucStatCurFPS = -1
timer.Create("luctus_serverstatus_fps",1,0,function()
    if system.HasFocus() then
        if (1/RealFrameTime()) > 0 then
            LucStatCurFPS = 1 / RealFrameTime()
        end
    end
end)
timer.Create("luctus_serverstatus_send",60,0,function()
    net.Start("luctus_serverstatus_fpssync")
        net.WriteInt(LucStatCurFPS,16)
    net.SendToServer()
end)

--Player connect times
hook.Add("InitPostEntity", "luctus_serverstatus_connecttime", function()
	net.Start("luctus_serverstatus_connecttime")
	net.SendToServer()
end)


print("[luctus_serverstatus] cl loaded")
