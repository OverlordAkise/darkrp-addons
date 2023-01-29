--Luctus Gangs
--Made by OverlordAkise

surface.CreateFont( "luctus_gang_font", {
	font = "Arial",
	extended = false,
	size = 26,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local luctus_gang_members = {}
local MemberList = nil
local LUCTUS_GANG_ESP = true
local LUCTUS_PARTY_HUD = true

timer.Create("luctus_gang_members_sync",1,0,function()
  luctus_gang_members = {}
  if LocalPlayer():GetNWInt("gangrank",0) == 0 then return end
  for k,v in pairs(player.GetAll()) do
    if v:GetNWInt("gangrank",0) ~= 0 and v:GetNWString("gang","") == LocalPlayer():GetNWString("gang","") then
      table.insert(luctus_gang_members,v)
    end
  end
end)

hook.Add("HUDPaint","luctus_gangs_party",function()
  if #luctus_gang_members == 0 then return end
  if LUCTUS_PARTY_HUD then
    surface.SetDrawColor(0, 195, 165, 255)
    surface.DrawOutlinedRect(5,ScrH()/2-200+20,210,(#luctus_gang_members*20)+10,2)
    draw.RoundedBox(0,7,ScrH()/2-200+22,206,(#luctus_gang_members*20)+6,Color(0,0,0,180))
    for k,v in pairs(luctus_gang_members) do
      draw.DrawText(v:Nick(),"Trebuchet18",10,ScrH()/2-200+(k*20))
      draw.RoundedBox(0,10,ScrH()/2-200+(k*20)+17,200,5,Color(200,200,200,220))
      draw.RoundedBox(0,10,ScrH()/2-200+(k*20)+17,(v:Health()*200)/v:GetMaxHealth(),5,Color(255,0,0))
    end
  end
end)

hook.Add( "PreDrawHalos", "luctus_gangs_halos", function()
  if LUCTUS_GANG_ESP then
    halo.Add(luctus_gang_members, color_white, 1, 1, 5, true, true )
  end
end)

--get: createtime,creator,name,motd,money,xp,level
net.Receive("luctus_gang_menu",function()
  local gangoverview = net.ReadTable()
  openGangMenu(gangoverview)
end)

local creator_cache = {}
function luctusGetCreator(steamid)
  if creator_cache[steamid] then return creator_cache[steamid] end
  for k,v in pairs(player.GetAll()) do
    if v:SteamID() == steamid then
      creator_cache[steamid] = v:Nick()
      return v:Nick()
    end
  end
end

function luctusNiceButton(button)
  button.Paint = function(self,w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 165))
    button:SetTextColor(color_white)
    draw.RoundedBox(0, 1, 1, w-2, h-2, Color(47, 49, 54))
    if self.Hovered then
      button:SetTextColor(Color(0, 195, 165))
      draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
    end
  end
end

function luctusIsOnline(steamid)
  if player.GetBySteamID(steamid) then
    return "Yes"
  else
    return "No"
  end
end

net.Receive("luctus_gang_members",function()
  if MemberList then
    MemberList:Clear()
    for k,v in pairs(net.ReadTable()) do
      MemberList:AddLine(v.plyname, v.steamid, luctusIsOnline(v.steamid))
    end
  end
end)

net.Receive("luctus_gang_create",function()
  Derma_StringRequest(
    "Luctus Gangs | Create a gang", 
    "Creating a gang costs nothing! Enter a name:",
    "",
    function(text) 
      net.Start("luctus_gangs")
        net.WriteString("create")
        net.WriteString(text)
      net.SendToServer()
    end,
    function(text) end
  )
end)

function openGangMenu(tab)
  if tab == {} then return end
  local Frame = vgui.Create("DFrame")
  Frame:SetPos(5, 5)
  Frame:SetSize(600, 500)
  Frame:Center()
  Frame:SetTitle("LuctusGangs | "..tab.name)
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
  CloseButton:SetPos(600-22,2)
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
  
  
  --MAIN SHEET
  local sheet = vgui.Create( "DColumnSheet", Frame )
  sheet:Dock(FILL)
  
  
  
  --OVERVIEW panel
  local overview = vgui.Create( "DTextEntry", sheet )
  overview:SetMultiline(true)
  overview:SetText("Gangname: "..tab.name..
      "\n\nCreator: "..luctusGetCreator(tab.creator)..
      "\nCreated: "..tab.createtime..
      --"\nLevel:\t"..tab.level..
      --"\nXP:\t\t"..tab.xp..
      "\n\nMOTD:\n"..tab.motd
    ,"luctus_gang_font",10,20,color_white,TEXT_ALIGN_LEFT)
  overview:Dock(FILL)
  overview:DockMargin(0,10,0,0)
  overview:SetTextColor(color_white)
  overview:SetFont("luctus_gang_font")
  overview:SetDrawLanguageID(false)
  overview:SetEditable(false)
  overview:SetPaintBackground(false)
  sheet:AddSheet( "Overview", overview, "icon16/report.png" )
  
  
  
  --MEMBERS panel
  local members = vgui.Create( "DPanel", sheet )
  members.Paint = function(self, w, h) end
  members:Dock(FILL)
  local refreshButton = vgui.Create("DButton", members)
  refreshButton:Dock(TOP)
  refreshButton:SetText("Refresh Members List")
  luctusNiceButton(refreshButton)
  function refreshButton:DoClick()
    net.Start("luctus_gangs")
      net.WriteString("getmembers")
    net.SendToServer()
  end
  MemberList = vgui.Create("DListView", members)
  MemberList:Dock(FILL)
  MemberList:SetMultiSelect(false)
  MemberList:AddColumn("Name")
  MemberList:AddColumn("SteamID")
  MemberList:AddColumn("IsOnline")
  for k,v in pairs(MemberList.Columns) do
    v.Header:SetTextColor(Color(0, 195, 165))
    v.Header.Paint = function(self,w,h)
      draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
      if (self.Hovered) then
        draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
      end
    end
  end
  
  function MemberList:OnRowRightClick(lineID, line)
    local Menu = DermaMenu(false,MemberList)
    local btnWithIcon = Menu:AddOption("Kick")
    btnWithIcon:SetIcon( "icon16/delete.png" )
    function Menu:OptionSelected(selPanel, panelText)
      if panelText == "Kick" then
        local player = line:GetColumnText(1)
        local steamid = line:GetColumnText(2)
        Derma_Query(
          "Are you sure you want to kick player "..player.."?",
          "Luctus Gangs | Kick",
          "Yes",
          function(text)
            net.Start("luctus_gangs")
              net.WriteString("kick")
              net.WriteString(steamid)
            net.SendToServer()
          end,
          "No",
          function()end
        )
      end
    end
    Menu:Open()
  end
  sheet:AddSheet( "Members", members, "icon16/user_female.png" )
  
  
  
  --INVITE panel
  local invite = vgui.Create( "DPanel", sheet )
  invite.Paint = function(self, w, h) end
  invite:Dock(FILL)
  
  local PlayerList = vgui.Create("DListView", invite)
  PlayerList:Dock(FILL)
  PlayerList:SetMultiSelect(false)
  PlayerList:AddColumn("Name")
  PlayerList:AddColumn("SteamID")
  PlayerList:AddColumn("Gang")
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
    PlayerList:AddLine(v:Name(), v:SteamID(), (v:GetNWString("gang","") ~= "" and v:GetNWString("gang","") or "none"))
  end
  function PlayerList:OnRowRightClick(lineID, line)
    local Menu = DermaMenu(false,PlayerList)
    local btnWithIcon = Menu:AddOption("Invite")
    btnWithIcon:SetIcon( "icon16/add.png" )
    function Menu:OptionSelected(selPanel, panelText)
      if panelText == "Invite" then
        local steamid = line:GetColumnText(2)
        net.Start("luctus_gangs")
          net.WriteString("invite")
          net.WriteString(steamid)
        net.SendToServer()
      end
    end
    Menu:Open()
  end
  sheet:AddSheet( "Invite", invite, "icon16/group_add.png" )
  
  
  --MONEY panel
  local money = vgui.Create( "DPanel", sheet )
  money.Paint = function(self, w, h) end
  money:Dock(FILL)
  
  money.Paint = function(self, w, h)
    draw.DrawText("Gang-Money: "..tab.money.."$","luctus_gang_font",10,20,color_white,TEXT_ALIGN_LEFT)
  end
  
  local moneyDepositButton = vgui.Create("DButton",money)
  moneyDepositButton:SetSize(100,50)
  moneyDepositButton:SetPos(10,70)
  luctusNiceButton(moneyDepositButton)
  moneyDepositButton:SetText("Deposit Money")
  function moneyDepositButton:DoClick()
    Derma_StringRequest("Luctus Gang | Deposit Money", "How much money do you want to deposit?", "", function(text)
      net.Start("luctus_gangs")
        net.WriteString("getmoney")
        net.WriteString(text)
      net.SendToServer()
      Frame:Close()
    end, function() end)
  end
  
  local moneyRetrieveButton = vgui.Create("DButton",money)
  moneyRetrieveButton:SetSize(100,50)
  moneyRetrieveButton:SetPos(120,70)
  luctusNiceButton(moneyRetrieveButton)
  moneyRetrieveButton:SetText("Deposit Money")
  function moneyRetrieveButton:DoClick()
    Derma_StringRequest("Luctus Gang | Retrieve Money", "How much money do you want to retrieve?", "", function(text)
      net.Start("luctus_gangs")
        net.WriteString("sendmoney")
        net.WriteString(text)
      net.SendToServer()
      Frame:Close()
    end, function() end)
  end
  
  sheet:AddSheet( "Money", money, "icon16/money.png" )
  
  --SETTINGS panel
  local settings = vgui.Create( "DPanel", sheet )
  settings.Paint = function(self, w, h) end
  settings:Dock(FILL)
  
  local espButton = vgui.Create("DButton",settings)
  espButton:SetSize(100,50)
  espButton:SetPos(10,10)
  luctusNiceButton(espButton)
  espButton:SetText("Turn "..(LUCTUS_GANG_ESP and "off" or "on").." gang ESP")
  function espButton:DoClick()
    LUCTUS_GANG_ESP = not LUCTUS_GANG_ESP
    self:SetText("Turn "..(LUCTUS_GANG_ESP and "off" or "on").." gang ESP")
  end
  
  local partyButton = vgui.Create("DButton",settings)
  partyButton:SetSize(100,50)
  partyButton:SetPos(120,10)
  luctusNiceButton(partyButton)
  partyButton:SetText("Turn "..(LUCTUS_PARTY_HUD and "off" or "on").." party HUD")
  function partyButton:DoClick()
    LUCTUS_PARTY_HUD = not LUCTUS_PARTY_HUD
    self:SetText("Turn "..(LUCTUS_PARTY_HUD and "off" or "on").." party HUD")
  end
  
  local motdButton = vgui.Create("DButton",settings)
  motdButton:SetSize(100,50)
  motdButton:SetPos(230,10)
  luctusNiceButton(motdButton)
  motdButton:SetText("Change MOTD")
  function motdButton:DoClick()
    Derma_StringRequest("Luctus Gang | MOTD Change", "MOTD can be max 300 characters!", "", function(text)
      net.Start("luctus_gang_motd")
        net.WriteString(text)
      net.SendToServer()
    end, function() end)
  end
  
  local leaveButton = vgui.Create("DButton",settings)
  leaveButton:SetSize(100,50)
  leaveButton:SetPos(340,10)
  luctusNiceButton(leaveButton)
  leaveButton:SetText("Leave Gang")
  function leaveButton:DoClick()
    Derma_Query("Do you really want to leave your gang?", "Luctus Gang | Leave", "Yes", function()
      net.Start("luctus_gangs")
        net.WriteString("leave")
      net.SendToServer()
      Frame:Close()
    end, "No", function() end)
  end
  
  sheet:AddSheet( "Settings", settings, "icon16/cog.png" )
  
  
  
  --Redraw sheet buttons!
  for k,v in pairs(sheet:GetChildren()[1]:GetChildren()[1]:GetChildren()) do
    v:SetHeight(44)
    v.Paint = function(self,w,h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 195, 165))
      v:SetTextColor(color_white)
      draw.RoundedBox(0, 1, 1, w-2, h-2, Color(47, 49, 54))
      if (self.Hovered) or self == sheet:GetActiveButton() then
        v:SetTextColor(Color(0, 195, 165))
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
      end
    end
  end
end

print("[luctus_gangs] Loaded CL file!")
