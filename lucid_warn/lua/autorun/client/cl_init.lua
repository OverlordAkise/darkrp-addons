--LucidWarn
--by OverlordAkise

function openWarnMenu()
		local Frame = vgui.Create("DFrame")
		Frame:SetPos(5, 5)
		Frame:SetSize(ScrW()/1.5, ScrH()/1.5)
		Frame:Center()
		Frame:SetTitle("LucidWarn v0.1 | by OverlordAkise")
		Frame:SetVisible(true)
		Frame:SetDraggable(true)
		Frame:ShowCloseButton(true)
		Frame:MakePopup()
		
    DetailPanel = vgui.Create("DLabel", Frame)
    DetailPanel:Dock(TOP)
    DetailPanel:SetText("")
    --DetailPanel:SetSize(
    
    WarningList = vgui.Create("DListView", Frame)
		WarningList:Dock(FILL)
		WarningList:AddColumn("ID"):SetFixedWidth(25)
    WarningList:AddColumn("Active"):SetFixedWidth(30)
    WarningList:AddColumn("WarneeID"):SetFixedWidth(125)
		WarningList:AddColumn("Reason")



		local RightFrame = vgui.Create("DPanel", Frame)
		RightFrame:Dock(RIGHT)
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
		for k,v in pairs(player.GetAll()) do
			PlayerList:AddLine(v:Name(), v:SteamID())
		end
		PlayerList.OnRowSelected = function(lst, index, pnl)
			WarningList:Clear()
      TargetSteamID:SetText(pnl:GetColumnText(2))
		end
		
    TargetSteamID = vgui.Create("DTextEntry", RightFrame)
		TargetSteamID:Dock(BOTTOM)
		TargetSteamID:SetText("SteamID here")
    
    local GetWarnsButton = vgui.Create("DButton", RightFrame)
		GetWarnsButton:Dock(BOTTOM)
		GetWarnsButton:SetText("Get Warns")
		GetWarnsButton.DoClick = function()
			if TargetSteamID:GetText() ~= "SteamID here" then
				net.Start("lw_requestwarns")
        net.WriteString(TargetSteamID:GetText())
        net.SendToServer()
			end
		end	
      

		local RemoveWarnButton = vgui.Create("DButton", RightFrame)
		RemoveWarnButton:Dock(BOTTOM)
		RemoveWarnButton:SetText("Remove Warning")
		RemoveWarnButton.DoClick = function()
			if WarningList:GetSelectedLine() ~= nil then
				net.Start("lw_removewarn")
				net.WriteString(WarningList:GetLine(WarningList:GetSelectedLine()):GetColumnText(1))
        net.WriteString(TargetSteamID:GetText())
				net.SendToServer()
				Frame:Close()
			end
		end	
		local WarnButton = vgui.Create("DButton", RightFrame)
		WarnButton:Dock(BOTTOM)
		WarnButton:SetText("Give Warning")
		WarnButton.DoClick = function()
			if TargetSteamID:GetValue() != "" then
        Derma_StringRequest(
          "LucidWarn | Reason", 
          "Please enter the reason for your warn",
          "RDM",
          function(text)
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
end

net.Receive("lw_requestwarns",function()
  WarningList:Clear()
  local lenge = net.ReadInt(17)
  if(lenge==0)then return end
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local tab = util.JSONToTable(jtext)
  
  local activeWarns = 0
  local allWarns = 0
  for k,v in pairs(tab) do
    WarningList:AddLine(v["rowid"],v["active"],v["warneeid"],v["warntext"])
    if(v["active"] == 1)then
      activeWarns = activeWarns + 1
    end
    allWarns = allWarns + 1
  end
  DetailPanel:SetText("Unknown User")
  if(allWarns > 0)then
    DetailPanel:SetText("User: "..tab[1]["targetid"].." | Active Warns: "..activeWarns.." | All Warns: "..allWarns)
  end
end)

-- Chat and Console Command for opening
concommand.Add("lwarn", function(ply, cmd, args)
	if lwconfig.allowedGroups[LocalPlayer():GetUserGroup()] ~= true then 
    chat.AddText("[lwarn] You aren't allowed to access LucidWarn.")
    return
  end
  openWarnMenu()
end)

hook.Add("OnPlayerChat", "lw_opencommand", function(ply, text, team, isdead) 
  if (ply != LocalPlayer()) then return end
	if (string.lower(text) == lwconfig.chatCommand) then
		if lwconfig.allowedGroups[LocalPlayer():GetUserGroup()] ~= true then 
      chat.AddText("[lwarn] You aren't allowed to access LucidWarn.")
      return 
    end
    openWarnMenu()
	end
end)
