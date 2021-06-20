--Lucid Whitelist
--Made by OverlordAkise

LUCTUS_WHITELIST_CHATCMD = "!whitelist"

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
    if(string.lower(text) == LUCTUS_WHITELIST_CHATCMD) then
      openLucidWhitelistWindow()
    end
  end
end)

function openLucidWhitelistWindow()
  local frame = vgui.Create("DFrame")
  frame:SetSize(600, 400)
  frame:SetTitle("Lucid Whitelist | v2.0 | by OverlordAkise")
  frame:Center()
  frame:MakePopup(true)
  
  local rightPanel = vgui.Create("DPanel", frame)
  rightPanel:Dock(RIGHT)
  rightPanel:SetWide(200)
  rightPanel:SetDrawBackground(false)
  

  local offlinePanel = vgui.Create("DLabel", rightPanel)
  offlinePanel:Dock(BOTTOM)
  offlinePanel:DockMargin(10,10,10,0)
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
  frame:SetTitle("Changing for "..steamid)
  frame:Center()
  frame:MakePopup(true)
  
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
  SaveButton.DoClick = function()
    --print("[lwhitelist] Saving new whitelist")
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

concommand.Add("lwhitelist", openLucidWhitelistWindow)

print("[lwhitelist] Lucid Whitelist client loaded!")
