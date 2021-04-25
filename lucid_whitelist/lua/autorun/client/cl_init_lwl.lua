hook.Add("InitPostEntity", "lucid_whitelist", function()
  _G["lwhitelist_wspawn"] = nil
  for k,v in pairs(ents.GetAll()) do
    if(v:GetClass() == "worldspawn")then
      _G["lwhitelist_wspawn"] = v
    end
  end
end)

hook.Add("OnPlayerChat", "lucid_whitelist", function(ply,text,team,dead)
  if(ply == LocalPlayer()) then
    if(string.lower(text) == "!lwhitelist") then
      openLucidWhitelistWindow()
    end
  end
end)

function openLucidWhitelistWindow()
  local frame = vgui.Create("DFrame")
  frame:SetSize(300, 600)
  frame:SetTitle("LucidWhitelist | by OverlordAkise")
  frame:Center()
  frame:MakePopup(true)
  
  local PlayerList = vgui.Create("DListView", frame)
  PlayerList:Dock(FILL)
  PlayerList:SetMultiSelect(false)
  PlayerList:AddColumn("Name")
  PlayerList:AddColumn("SteamID")
  PlayerList:SetSize(200, 0)
  for k,v in pairs(player.GetAll()) do
    PlayerList:AddLine("everyone","everyone")
    PlayerList:AddLine(v:Name(),v:SteamID())
  end
  PlayerList.OnRowSelected = function(lst, index, pnl)
    frame.TargetSteamID:SetText(pnl:GetColumnText(2))
  end
  
  frame.TargetSteamID = vgui.Create("DTextEntry", frame)
  frame.TargetSteamID:Dock(BOTTOM)
  frame.TargetSteamID:SetZPos(100) --higher = infront / before
  frame.TargetSteamID:SetText("SteamID here")
  
  local ChangeButton = vgui.Create("DButton", frame)
  ChangeButton:Dock(BOTTOM)
  ChangeButton:SetText("Change for SteamID")
  ChangeButton.DoClick = function()
    if frame.TargetSteamID:GetText() ~= "SteamID here" then
      net.Start("lucid_whitelist_get")
    net.WriteString(frame.TargetSteamID:GetText())
    net.SendToServer()
    end
  end	
end

net.Receive("lucid_whitelist_get", function()
  local steamid = net.ReadString()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local jsontable = util.JSONToTable(jtext)
  
  local frame = vgui.Create("DFrame")
  frame:SetSize(300, 600)
  frame:SetTitle("Change Access")
  frame:Center()
  frame:MakePopup(true)
  
  local DScrollPanel = vgui.Create( "DScrollPanel", frame )
  DScrollPanel:Dock( FILL )
  
  
  --for i = 0, 10, 1 do
  for job_index,job in pairs(RPExtraTeams) do
    local DermaCheckbox = DScrollPanel:Add( "DCheckBoxLabel" )
    DermaCheckbox:Dock(TOP)
    DermaCheckbox:DockMargin( 4, 0, 0, 0 )
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
  SaveButton.DoClick = function()
    print("[lwhitelist] Saving new whitelist")
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
end)

print("[lwhitelist] Lucid Whitelist client loaded!")