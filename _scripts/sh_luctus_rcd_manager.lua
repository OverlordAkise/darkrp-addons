--Luctus Realistic Cardealer Manager
--Made by OverlordAkise

-- This needs the realistic_cardealer addon to work
-- Use !rcdmanage to open a panel where you can give or take cars from players

local allowedGroups = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
}

if SERVER then
    util.AddNetworkString("luctus_rcd_manager_getveh")
    util.AddNetworkString("luctus_rcd_manager_give")
    util.AddNetworkString("luctus_rcd_manager_take")
    net.Receive("luctus_rcd_manager_give",function(len,ply)
        if not allowedGroups[ply:GetUserGroup()] then return end
        local steamid = net.ReadString()
        local vehicleId = net.ReadString()
        RCD.GiveVehicle(steamid,vehicleId)
        DarkRP.notify(ply,0,5,"[rcd_manager] Sucess giving car")
    end)
    net.Receive("luctus_rcd_manager_take",function(len,ply)
        if not allowedGroups[ply:GetUserGroup()] then return end
        local steamid = net.ReadString()
        local vehicleId = net.ReadString()
        RCD.RemoveVehicle(steamid,vehicleId)
        DarkRP.notify(ply,0,5,"[rcd_manager] Sucess taking car away")
    end)
    net.Receive("luctus_rcd_manager_getveh",function(len,ply)
        if not allowedGroups[ply:GetUserGroup()] then return end
        net.Start("luctus_rcd_manager_getveh")
            net.WriteTable(sql.Query("SELECT id,name,class FROM rcd_vehicles") or {})
        net.Send(ply)
    end)
else --if CLIENT then
    hook.Add("OnPlayerChat","luctus_rcd_manager",function(ply,text)
        if ply != LocalPlayer() then return end
        if not allowedGroups[ply:GetUserGroup()] then return end
        if text == "!rcdmanage" then
            LuctusRCDManagerOpen()
        end
    end)
    
    function LuctusRCDManagerOpen()
        local frame = vgui.Create("DFrame")
        frame:SetSize(600, 400)
        frame:ShowCloseButton(false)
        frame:SetTitle("Luctus Realistic Cardealer Manager")
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
        
        local hint = vgui.Create("DLabel", frame)
        hint:Dock(TOP)
        hint:SetText("click twice on a row to give/take a car to/from someone")
        
        local PlayerList = vgui.Create("DListView", frame)
        PlayerList:Dock(FILL)
        PlayerList:SetMultiSelect(false)
        PlayerList:AddColumn("ID")
        PlayerList:AddColumn("Name")
        PlayerList:AddColumn("Class")
        net.Receive("luctus_rcd_manager_getveh",function()
            local veh = net.ReadTable()
            for k,v in pairs(veh) do
                PlayerList:AddLine(v.id,v.name,v.class)
            end
        end)
        net.Start("luctus_rcd_manager_getveh") net.SendToServer()
        function PlayerList:DoDoubleClick(lineID, line)
            local menu = DermaMenu()
            local addMenu, parentMenuOption = menu:AddSubMenu("Give car")
            parentMenuOption:SetIcon("icon16/add.png")
            local delMenu, parentMenuOption = menu:AddSubMenu("Take car")
            parentMenuOption:SetIcon("icon16/delete.png")
            
            for k,v in ipairs(player.GetAll()) do
                addMenu:AddOption(v:Name(), function()
                    net.Start("luctus_rcd_manager_give")
                        net.WriteString(v:SteamID64())
                        net.WriteString(line:GetColumnText(1))
                    net.SendToServer()
                end)
                delMenu:AddOption(v:Name(), function()
                    net.Start("luctus_rcd_manager_take")
                        net.WriteString(v:SteamID64())
                        net.WriteString(line:GetColumnText(1))
                    net.SendToServer()
                end)
            end
            addMenu:AddSpacer()
            addMenu:AddOption("Offline SteamID64", function()
                Derma_StringRequest("Give car to SteamID64", "Car: "..line:GetColumnText(2), "", function(textIn)
                    net.Start("luctus_rcd_manager_give")
                        net.WriteString(textIn)
                        net.WriteString(line:GetColumnText(1))
                    net.SendToServer()
                end)
            end)
            delMenu:AddSpacer()
            delMenu:AddOption("Offline SteamID64", function()
                Derma_StringRequest("Take car from SteamID64", "Car: "..line:GetColumnText(2), "", function(textIn)
                    net.Start("luctus_rcd_manager_take")
                        net.WriteString(textIn)
                        net.WriteString(line:GetColumnText(1))
                    net.SendToServer()
                end)
            end)
            menu:Open()
        end
        function PlayerList:OnRowRightClick(lineID, line) self:DoDoubleClick(lineID,line) end
    end
end

print("[luctus_rcd_manager] sh loaded")
