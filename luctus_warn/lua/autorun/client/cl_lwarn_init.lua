--Luctus Warn
--Made by OverlordAkise

function LuctusWarnOpenMenu()
    local Frame = vgui.Create("DFrame")
    Frame:SetPos(5, 5)
    Frame:SetSize(ScrW()/1.5, ScrH()/1.5)
    Frame:Center()
    Frame:SetTitle("Luctus Warn")
    Frame:SetVisible(true)
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(false)
    Frame:MakePopup()
    function Frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", Frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(ScrW()/1.5-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        Frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
        
    DetailPanel = vgui.Create("DLabel", Frame)
    DetailPanel:Dock(TOP)
    DetailPanel:SetText("")
    
    WarningList = vgui.Create("DListView", Frame)
    WarningList:Dock(FILL)
    WarningList:AddColumn("ID"):SetFixedWidth(25)
    WarningList:AddColumn("Time"):SetFixedWidth(125)
    WarningList:AddColumn("Active"):SetFixedWidth(30)
    WarningList:AddColumn("WarneeID"):SetFixedWidth(125)
    WarningList:AddColumn("PlayerID"):SetFixedWidth(125)
    WarningList:AddColumn("Reason")
    for k,v in pairs(WarningList.Columns) do
        v.Header:SetTextColor(Color(0, 195, 165))
        v.Header.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
            if (self.Hovered) then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
    end
    function WarningList:OnRowRightClick(lineID, line)
        local Menu = DermaMenu()
        local activeB = Menu:AddOption("Set Warn Active")
        activeB:SetIcon( "icon16/add.png" )
        local inactiveB = Menu:AddOption("Set Warn Inactive")
        inactiveB:SetIcon( "icon16/cancel.png" )
        if LocalPlayer():IsAdmin() then
            local deleteB = Menu:AddOption("Delete Warn")
            deleteB:SetIcon( "icon16/delete.png" )
        end
        function Menu:OptionSelected(selPanel, panelText)
            if panelText == "Delete Warn" then 
                if not LocalPlayer():IsAdmin() then return end
                net.Start("lw_deletewarn")
                net.WriteString(line:GetColumnText(1))
                net.WriteString(line:GetColumnText(4))
                net.SendToServer()
                Frame:Close()
                return 
            end
            net.Start("lw_updatewarn")
            net.WriteString(line:GetColumnText(1))
            net.WriteString(line:GetColumnText(4))
            if panelText == "Set Warn Inactive" then
                net.WriteBool(true)
            else
                net.WriteBool(false)
            end
            net.SendToServer()
            Frame:Close()
        end
        Menu:Open()
    end


    local RightFrame = vgui.Create("DPanel", Frame)
    RightFrame:Dock(LEFT)
    RightFrame:SetSize(200, 0)
    RightFrame.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end
    
    local PlayerList = vgui.Create("DListView", RightFrame)
    PlayerList:Dock(FILL)
    PlayerList:SetMultiSelect(false)
    PlayerList:AddColumn("Name")
    PlayerList:AddColumn("SteamID")
    PlayerList:SetSize(200, 0)
    for k,v in pairs(PlayerList.Columns) do
        v.Header:SetTextColor(Color(0, 195, 165))
        v.Header.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
            if (self.Hovered) then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
    end
    for k,v in pairs(player.GetAll()) do
        PlayerList:AddLine(v:Name(), v:SteamID())
    end
    function PlayerList:DoDoubleClick( lineID, line )
        WarningList:Clear()
        net.Start("lw_requestwarns")
            net.WriteString(line:GetColumnText(2))
        net.SendToServer()
    end
    function PlayerList:OnRowRightClick(lineID, line)
        local Menu = DermaMenu()
        local btnWithIcon = Menu:AddOption("Warn")
        btnWithIcon:SetIcon( "icon16/add.png" )
        function Menu:OptionSelected(selPanel, panelText)
            if panelText == "Warn" then
                local name = line:GetColumnText(1)
                local steamid = line:GetColumnText(2)
                Derma_StringRequest(
                "Luctus Warn | Reason",
                "Please enter a reason to warn "..name.." ("..steamid..")",
                "RDM",
                function(text)
                    net.Start("lw_warnplayer")
                    net.WriteString(steamid)
                    net.WriteString(text)
                    net.SendToServer()
                    Frame:Close()
                end,function()end)
            end
        end
        Menu:Open()
    end

    --Offline Warning Code below
    TargetSteamID = vgui.Create("DTextEntry", RightFrame)
    TargetSteamID:Dock(BOTTOM)
    TargetSteamID:SetText("Offline SteamID here")
    
    local GetWarnsButton = vgui.Create("DButton", RightFrame)
    GetWarnsButton:Dock(BOTTOM)
    GetWarnsButton:SetText("Get Offline Warns")
    GetWarnsButton:SetTextColor(Color(0, 195, 165))
    GetWarnsButton.DoClick = function()
        if TargetSteamID:GetText() ~= "Offline SteamID here" then
            net.Start("lw_requestwarns")
                net.WriteString(TargetSteamID:GetText())
            net.SendToServer()
        end
    end
    function GetWarnsButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 0+1, 0+1, w-2, h-2, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0+1, 0+1, w-2, h-2, Color(66, 70, 77))
        end
    end
    
    local WarnButton = vgui.Create("DButton", RightFrame)
    WarnButton:Dock(BOTTOM)
    WarnButton:SetText("Give Offline Warning")
    WarnButton:SetTextColor(Color(0, 195, 165))
    WarnButton.DoClick = function()
        if TargetSteamID:GetValue() != "" then
            Derma_StringRequest(
            "Luctus Warn | Reason", 
            "Please enter a reason to warn "..TargetSteamID:GetValue(),
            "RDM",
            function(text)
                local steamid = TargetSteamID:GetText()
                if steamid == "Offline SteamID here" then
                    Derma_Message("Please enter a steamid first!", "Luctus Warn | Notification", "Close")
                    return
                end
                net.Start("lw_warnplayer")
                    net.WriteString(TargetSteamID:GetText())
                    net.WriteString(text)
                net.SendToServer()
                Frame:Close()
            end,
            function(text) end
            )
        end
    end
    function WarnButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 0+1, 0+1, w-2, h-2, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0+1, 0+1, w-2, h-2, Color(66, 70, 77))
        end
    end
end

net.Receive("lw_requestwarns",function()
    WarningList:Clear()
    DetailPanel:SetText("Unknown User")
    local lenge = net.ReadInt(17)
    if lenge==0 then 
        Derma_Message("This user doesn't have any warns!", "Luctus Warn | Notification", "Close")
        return 
    end
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    --PrintTable(tab)
    local activeWarns = 0
    local allWarns = 0
    for k,v in pairs(tab) do
        WarningList:AddLine(v["rowid"],v["time"],v["active"],v["warneeid"],v["targetid"],v["warntext"])
        if v["active"] == 1 then
            activeWarns = activeWarns + 1
        end
        allWarns = allWarns + 1
    end
    if allWarns > 0 then
        DetailPanel:SetText("User: "..tab[1]["targetid"].." | Active Warns: "..activeWarns.." | All Warns: "..allWarns)
    end
end)

net.Receive("lw_requestwarns_user",function()
    local lenge = net.ReadInt(17)
    if lenge==0 then 
        Derma_Message("You don't have any warns!", "Luctus Warn | Notification", "Close")
        return 
    end
  
    local Frame = vgui.Create("DFrame")
    Frame:SetPos(5, 5)
    Frame:SetSize(500, 600)
    Frame:Center()
    Frame:SetTitle("Luctus Warn")
    Frame:SetVisible(true)
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(false)
    Frame:MakePopup()
    function Frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", Frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(500-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        Frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    DetailPanel = vgui.Create("DLabel", Frame)
    DetailPanel:Dock(TOP)
    DetailPanel:SetText(LocalPlayer():Nick())

    WarningList = vgui.Create("DListView", Frame)
    WarningList:Dock(FILL)
    WarningList:AddColumn("ID"):SetFixedWidth(25)
    WarningList:AddColumn("Time"):SetFixedWidth(125)
    WarningList:AddColumn("Active"):SetFixedWidth(30)
    WarningList:AddColumn("WarneeID"):SetFixedWidth(125)
    WarningList:AddColumn("PlayerID"):SetFixedWidth(125)
    WarningList:AddColumn("Reason")
    for k,v in pairs(WarningList.Columns) do
        v.Header:SetTextColor(Color(0, 195, 165))
        v.Header.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
            if (self.Hovered) then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
    end
  
    function WarningList:DoDoubleClick( lineID, line )
        Derma_Message("Reason for your warn: \n" .. line:GetValue(5), "Luctus Warn | Warn Reason", "Close")
    end

    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    local activeWarns = 0
    local allWarns = 0
    for k,v in pairs(tab) do
        WarningList:AddLine(v["rowid"],v["time"],v["active"],v["warneeid"],v["targetid"],v["warntext"])
        if(v["active"] == 1)then
            activeWarns = activeWarns + 1
        end
        allWarns = allWarns + 1
    end
    if allWarns > 0 then
        DetailPanel:SetText("User: "..LocalPlayer():Nick().." | Active Warns: "..activeWarns.." | All Warns: "..allWarns)
    end
end)

-- Chat and Console Command for opening
-- If not allowed to manage warns opens the user-view instead
concommand.Add("warnmenu", function(ply, cmd, args)
    if LUCTUS_WARN_ADMINGROUPS[LocalPlayer():GetUserGroup()] ~= true then 
        net.Start("lw_requestwarns_user")
        net.SendToServer()
        return
    end
    LuctusWarnOpenMenu()
    net.Start("lw_requestwarns")
    net.SendToServer()
end)

hook.Add("OnPlayerChat", "lw_opencommand", function(ply, text, team, isdead) 
    if (ply == LocalPlayer() and string.lower(text) == LUCTUS_WARN_CHAT_COMMAND) then
        if LUCTUS_WARN_ADMINGROUPS[LocalPlayer():GetUserGroup()] ~= true then 
            net.Start("lw_requestwarns_user")
            net.SendToServer()
            return
        end
        LuctusWarnOpenMenu()
        net.Start("lw_requestwarns")
        net.SendToServer()
    end
end)

hook.Add("LuctusLogAddCategory","luctus_warn",function()
    LuctusLogAddCategory("Warn")
end)

print("[luctus_warn] cl loaded!")
