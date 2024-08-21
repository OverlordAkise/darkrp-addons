--Luctus Gangs
--Made by OverlordAkise

surface.CreateFont("luctus_gang_font",{
    font = "Arial",
    size = 26,
    weight = 500,
})

local color_accent = Color(0, 195, 165)
local color_bg = Color(0,0,0,180)

local luctus_gang_members = {}
local MemberList = nil
local MoneyHistory = nil
LUCTUS_GANGS_ESP = true
LUCTUS_GANGS_PARTY_HUD = true

timer.Create("luctus_gang_members_sync",1,0,function()
    local lp = LocalPlayer()
    if not IsValid(lp) then return end
    luctus_gang_members = {}
    if lp:GetNW2Int("gangrank",0) == 0 then return end
    for k,v in ipairs(player.GetAll()) do
        if v ~= lp and v:GetNW2Int("gangrank",0) ~= 0 and v:GetNW2String("gang","x") == lp:GetNW2String("gang","y") then
            table.insert(luctus_gang_members,v)
        end
    end
end)


local color_hud_hp_bg = Color(200,200,200,220)
local color_red = Color(255,0,0)
hook.Add("HUDPaint","luctus_gangs_party",function()
    if #luctus_gang_members == 0 then return end
    if LUCTUS_GANGS_PARTY_HUD then
        local scrh = ScrH()
        surface.SetDrawColor(0, 195, 165, 255)
        surface.DrawOutlinedRect(5,scrh/2-200+20,210,(#luctus_gang_members*20)+10,2)
        draw.RoundedBox(0,7,scrh/2-200+22,206,(#luctus_gang_members*20)+6,color_bg)
        for k,ply in ipairs(luctus_gang_members) do
            draw.DrawText(ply:Nick(),"Trebuchet18",10,scrh/2-200+(k*20))
            draw.RoundedBox(0,10,scrh/2-200+(k*20)+17,200,5,color_hud_hp_bg)
            draw.RoundedBox(0,10,scrh/2-200+(k*20)+17,(ply:Health()*200)/ply:GetMaxHealth(),5,color_red)
        end
    end
end)

hook.Add("PreDrawHalos", "luctus_gangs", function()
    if LUCTUS_GANGS_ESP then
        halo.Add(luctus_gang_members, color_white, 1, 1, 1, true, true )
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
    local getply = player.GetBySteamID(steamid)
    if not IsValid(getply) then return end 
    creator_cache[steamid] = getply:Nick()
    return creator_cache[steamid]
end

local function luctusNiceButton(button)
    button.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_accent)
        button:SetTextColor(color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(47, 49, 54))
        if self.Hovered then
            button:SetTextColor(color_accent)
            draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
        end
    end
end

local function luctusNiceColumns(list)
    for k,v in pairs(list.Columns) do
        v.Header:SetTextColor(color_accent)
        v.Header.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
    end
end

net.Receive("luctus_gang_members",function()
    if not MemberList then return end
    MemberList:Clear()
    for k,v in ipairs(net.ReadTable()) do
        MemberList:AddLine(v.plyname, v.steamid, player.GetBySteamID(v.steamid) and "Yes" or "No")
    end
end)

net.Receive("luctus_gang_mhistory",function()
    if not MoneyHistory then return end
    MoneyHistory:Clear()
    for k,v in ipairs(net.ReadTable()) do
        MoneyHistory:AddLine(v.ts,v.name,v.steamid,v.amount)
    end
end)

hook.Add("OnPlayerChat","luctus_gang_create",function(ply,text,isteam,isdead)
    if ply ~= LocalPlayer() then return end
    if text ~= "!creategang" then return end
    Derma_StringRequest(
        "Luctus Gangs | Create a gang", 
        "Creating a gang costs "..LUCTUS_GANGS_CREATE_COST.."$! Enter a name:",
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
    Frame:SetTitle("Luctus Gangs | "..tab.name)
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
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end

    --MAIN SHEET
    local sheet = vgui.Create( "DColumnSheet", Frame )
    sheet:Dock(FILL)

    --OVERVIEW panel
    local overview = vgui.Create( "DPanel", sheet )
    overview.Paint = function(self, w, h) end
    overview:Dock(FILL)
    local name = vgui.Create("DLabel",overview)
    name:Dock(TOP)
    name:SetFont("luctus_gang_font")
    name:SetText(tab.name)
    name:DockMargin(3,5,0,0)
    local motd = vgui.Create( "DTextEntry", overview )
    motd:Dock(FILL)
    motd:DockMargin(0,30,0,0)
    motd:SetMultiline(true)
    motd:SetText("MOTD:\n"..tab.motd,"Trebuchet24",10,20,color_white,TEXT_ALIGN_LEFT)
    print("GANG MOTD:") print(tab.motd)
    motd:DockMargin(0,10,0,0)
    motd:SetTextColor(color_white)
    motd:SetFont("luctus_gang_font")
    motd:SetDrawLanguageID(false)
    motd:SetEditable(false)
    motd:SetPaintBackground(false)
    sheet:AddSheet( "Overview", overview, "icon16/report.png" )


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
    luctusNiceColumns(MemberList)

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
    luctusNiceColumns(PlayerList)

    for k,v in ipairs(player.GetAll()) do
        PlayerList:AddLine(v:Name(), v:SteamID(), (v:GetNW2String("gang","") ~= "" and v:GetNW2String("gang","") or "none"))
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


    local money = vgui.Create( "DPanel", sheet )
    money:Dock(FILL)
    function money:Paint()end
    
    local textP = vgui.Create("DLabel",money)
    textP:Dock(TOP)
    textP:DockMargin(3,10,0,0)
    textP:SetFont("luctus_gang_font")
    textP:SetText("Gang-Money: "..DarkRP.formatMoney(tonumber(tab.money)))
    

    local moneyDepositButton = vgui.Create("DButton",money)
    moneyDepositButton:Dock(TOP)
    moneyDepositButton:DockMargin(0,10,0,0)
    luctusNiceButton(moneyDepositButton)
    moneyDepositButton:SetText("Deposit Money")
    function moneyDepositButton:DoClick()
        Derma_StringRequest("Luctus Gang | Deposit Money", "How much money do you want to deposit?", "", function(text)
        net.Start("luctus_gangs")
            net.WriteString("sendmoney")
            net.WriteString(text)
        net.SendToServer()
        Frame:Close()
        end, function() end)
    end
  
    local moneyRetrieveButton = vgui.Create("DButton",money)
    moneyRetrieveButton:Dock(TOP)
    moneyRetrieveButton:DockMargin(0,5,0,0)
    luctusNiceButton(moneyRetrieveButton)
    moneyRetrieveButton:SetText("Retrieve Money")
    function moneyRetrieveButton:DoClick()
        Derma_StringRequest("Luctus Gang | Retrieve Money", "How much money do you want to retrieve?", "", function(text)
        net.Start("luctus_gangs")
            net.WriteString("getmoney")
            net.WriteString(text)
        net.SendToServer()
        Frame:Close()
        end, function() end)
    end
    
    
    local mhUpBut = vgui.Create("DButton",money)
    mhUpBut:Dock(TOP)
    mhUpBut:DockMargin(0,10,0,0)
    mhUpBut:SetText("Update history")
    luctusNiceButton(mhUpBut)
    function mhUpBut:DoClick()
        net.Start("luctus_gangs")
            net.WriteString("getmoneyhistory")
        net.SendToServer()
    end
    MoneyHistory = vgui.Create("DListView", money)
    MoneyHistory:Dock(FILL)
    MoneyHistory:SetMultiSelect(false)
    MoneyHistory:AddColumn("Date")
    MoneyHistory:AddColumn("Name")
    MoneyHistory:AddColumn("SteamID")
    MoneyHistory:AddColumn("Amount")
    luctusNiceColumns(MoneyHistory)
    
    local helpLabel = vgui.Create("DLabel",money)
    helpLabel:Dock(BOTTOM)
    helpLabel:SetText("* Need help? Contact your admin!")
    sheet:AddSheet( "Money", money, "icon16/money.png" )
    
    
    local level = vgui.Create("DPanel", sheet)
    level:Dock(FILL)
    function level:Paint()end
    local header = vgui.Create("DLabel",level)
    header:Dock(TOP)
    header:SetFont("luctus_gang_font")
    header:SetText("Lv."..tab.level)
    header:DockMargin(3,10,0,0)
    local xp = vgui.Create("DPanel",level)
    xp:Dock(TOP)
    xp:DockMargin(0,20,0,0)
    function xp:Paint(w,h)
        local barLength = ((tab.xp%LUCTUS_GANGS_XP_NEEDED)*w)/LUCTUS_GANGS_XP_NEEDED
        draw.RoundedBox(0,0,h/1.5,w,h,color_bg)
        draw.RoundedBox(0,0,h/1.5,barLength,h,color_accent)
        draw.SimpleText(tab.xp%LUCTUS_GANGS_XP_NEEDED,"Trebuchet18",0,0,color_white,TEXT_ALIGN_LEFT)
        draw.SimpleText(LUCTUS_GANGS_XP_NEEDED,"Trebuchet18",w,0,color_white,TEXT_ALIGN_RIGHT)
    end
    --local a = vgui.Create("DPanel",level)
    --a:Dock(FILL)
    --a:DockMargin(0,10,0,0)
    --a.Paint = function()end
    --local b = vgui.Create("DPanel",a)
    --b:Dock(LEFT)
    --b:SetWide(a:GetWide()/2)
    
    
    sheet:AddSheet( "Level", level, "icon16/arrow_up.png" )
    
    local settings = vgui.Create( "DPanel", sheet )
    settings.Paint = function(self, w, h) end
    settings:Dock(FILL)
  
    local espButton = vgui.Create("DButton",settings)
    espButton:SetSize(100,50)
    espButton:SetPos(10,10)
    luctusNiceButton(espButton)
    espButton:SetText("Turn "..(LUCTUS_GANGS_ESP and "off" or "on").." gang ESP")
    function espButton:DoClick()
        LUCTUS_GANGS_ESP = not LUCTUS_GANGS_ESP
        self:SetText("Turn "..(LUCTUS_GANGS_ESP and "off" or "on").." gang ESP")
    end
  
    local partyButton = vgui.Create("DButton",settings)
    partyButton:SetSize(100,50)
    partyButton:SetPos(120,10)
    luctusNiceButton(partyButton)
    partyButton:SetText("Turn "..(LUCTUS_GANGS_PARTY_HUD and "off" or "on").." party HUD")
    function partyButton:DoClick()
        LUCTUS_GANGS_PARTY_HUD = not LUCTUS_GANGS_PARTY_HUD
        self:SetText("Turn "..(LUCTUS_GANGS_PARTY_HUD and "off" or "on").." party HUD")
    end
  
    local motdButton = vgui.Create("DButton",settings)
    motdButton:SetSize(100,50)
    motdButton:SetPos(230,10)
    luctusNiceButton(motdButton)
    motdButton:SetText("Change MOTD")
    function motdButton:DoClick()
        Derma_StringRequest("Luctus Gang | MOTD Change", "MOTD can be max 300 characters!", "", function(text)
        net.Start("luctus_gangs")
            net.WriteString("motdset")
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


    --Redraw sheet buttons
    for k,v in ipairs(sheet:GetChildren()[1]:GetChildren()[1]:GetChildren()) do
        v:SetHeight(30)
        v.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, color_accent)
            v:SetTextColor(color_white)
            draw.RoundedBox(0, 1, 1, w-2, h-2, Color(47, 49, 54))
            if self.Hovered or self == sheet:GetActiveButton() then
                v:SetTextColor(color_accent)
                draw.RoundedBox(0, 1, 1, w-2, h-2, Color(66, 70, 77))
            end
        end
    end
end

print("[luctus_gangs] cl loaded")
