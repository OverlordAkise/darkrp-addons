--Lucid Whitelist
--Made by OverlordAkise

hook.Add("OnPlayerChat", "lucid_whitelist", function(ply,text,team,dead)
    if ply == LocalPlayer() then
        if string.lower(text) == LUCTUS_WHITELIST_CHATCMD then
            openLucidWhitelistWindow()
        end
    end
end)

function openLucidWhitelistWindow()
    if not LUCTUS_WHITELIST_ALLOWED_RANKS[LocalPlayer():GetUserGroup()] then
        notification.AddLegacy("You aren't allowed to open the whitelist!",1,5)
        return
    end
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:ShowCloseButton(false)
    frame:SetTitle("Luctus Whitelist")
    frame:Center()
    frame:MakePopup(true)
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(600-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
  
    local rightPanel = vgui.Create("DPanel", frame)
    rightPanel:Dock(RIGHT)
    rightPanel:SetWide(200)
    rightPanel:SetDrawBackground(false)
  

    local offlinePanel = vgui.Create("DLabel", rightPanel)
    offlinePanel:Dock(BOTTOM)
    offlinePanel:DockMargin(10,10,10,0)
    offlinePanel:SetTextColor(Color(0, 195, 165))
    offlinePanel:SetZPos(101) -- = above changebutton
    offlinePanel:SetText("Change for offline players:")

    local TargetSteamID = vgui.Create("DTextEntry", rightPanel)
    TargetSteamID:Dock(BOTTOM)
    TargetSteamID:DockMargin(10,10,10,10)
    TargetSteamID:SetZPos(100) -- = above changebutton
    TargetSteamID:SetDrawLanguageID(false)
    TargetSteamID:SetText("SteamID here")

    local ChangeButton = vgui.Create("DButton", rightPanel)
    ChangeButton:Dock(BOTTOM)
    ChangeButton:DockMargin(10,0,10,160)
    ChangeButton:SetText("Change for SteamID")
    ChangeButton.DoClick = function()
        if TargetSteamID:GetText() ~= "SteamID here" then
            net.Start("lucid_whitelist_get")
                net.WriteString(TargetSteamID:GetText())
            net.SendToServer()
        end
    end
    function ChangeButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
        ChangeButton:SetTextColor(color_white)
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            ChangeButton:SetTextColor(Color(0, 195, 165))
        end
    end
  
    local PlayerList = vgui.Create("DListView", frame)
    PlayerList:Dock(FILL)
    PlayerList:SetMultiSelect(false)
    PlayerList:AddColumn("Name")
    PlayerList:AddColumn("SteamID")
    PlayerList:SetSize(200, 0)
    PlayerList:AddLine("everyone","everyone")
    for k,v in pairs(player.GetAll()) do
        PlayerList:AddLine(v:Name(),v:SteamID())
    end
    function PlayerList:DoDoubleClick( lineID, line )
        net.Start("lucid_whitelist_get")
            net.WriteString(line:GetColumnText(2))
        net.SendToServer()
    end
end

net.Receive("lucid_whitelist_get", function()
    local steamid = net.ReadString()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local jsontable = util.JSONToTable(jtext)

    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 450)
    frame:ShowCloseButton(false)
    frame:SetTitle("Changing for "..steamid)
    frame:Center()
    frame:MakePopup(true)
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", frame)
    CloseButton:SetText("X")
    CloseButton:SetPos(400-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        frame:Close()
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
  
    local namePanel = vgui.Create("DLabel", frame)
    namePanel:Dock(TOP)
    namePanel:DockMargin( 35,10,10,0 )
    namePanel:SetText("Jobs ("..steamid..")")
    namePanel:SetFont("Trebuchet18")

    local DScrollPanel = vgui.Create( "DScrollPanel", frame )
    DScrollPanel:Dock( FILL )
    DScrollPanel:DockMargin( 10,10,10,10 )
  
  
    --for i = 0, 10, 1 do
    for job_index,job in pairs(RPExtraTeams) do
        local DermaCheckbox = DScrollPanel:Add( "DCheckBoxLabel" )
        DermaCheckbox:Dock(TOP)
        DermaCheckbox:DockMargin( 5, 5, 0, 0 )
        DermaCheckbox:SetText(job.name)
        if(jsontable[job.name])then
            DermaCheckbox:SetChecked(true)
        else
            DermaCheckbox:SetChecked(false)
        end
    end
    --end
  
    local SaveButton = vgui.Create("DButton", frame)
    SaveButton:Dock(BOTTOM)
    SaveButton:SetText("SAVE")
    SaveButton:DockMargin(10,10,10,10)
    SaveButton:SetTextColor(color_white)
    SaveButton.DoClick = function()
        local newtab = {}
        for k,v in pairs(DScrollPanel:GetChildren()[1]:GetChildren())do
            if(v:GetChecked())then
                newtab[v:GetText()] = true
            end
        end
        net.Start("lucid_whitelist_set")
        net.WriteString(steamid)
        local t = util.TableToJSON(newtab)
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
        net.SendToServer()
        frame:Close()
    end
    function SaveButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
        SaveButton:SetTextColor(color_white)
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            SaveButton:SetTextColor(Color(0, 195, 165))
        end
    end
end)

concommand.Add("lwhitelist", openLucidWhitelistWindow)

hook.Add("LuctusLogAddCategory","luctus_whitelist",function()
    LuctusLogAddCategory("Whitelist")
end)

print("[luctus_whitelist] Lucid Whitelist client loaded!")
