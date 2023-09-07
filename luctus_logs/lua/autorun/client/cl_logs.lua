--Luctus Logs
--Made by OverlordAkise

--Height of the window
local logHeight = 630
--Width of the window
local logWidth = 1200
--Right-Click options for players in log lines
luctus_log_ulxs = {
    ["copy name"] = function(ply) SetClipboardText(ply:Nick()) end,
    ["copy steam name"] = function(ply) SetClipboardText(ply:SteamName()) end,
    ["bring"] = function(ply) RunConsoleCommand("ulx","bring",ply:Nick()) end,
    ["return"] = function(ply) RunConsoleCommand("ulx","return",ply:Nick()) end,
    ["goto"] = function(ply) RunConsoleCommand("ulx","goto",ply:Nick()) end,
    ["slay"] = function(ply) RunConsoleCommand("ulx","slay",ply:Nick()) end,
    ["forcerespawn"] = function(ply) RunConsoleCommand("ulx","forcerespawn",ply:Nick()) end,
}



--Do not change things below this line

luctus_log_quickfilters = {
    "PlayerSay",
    "PlayerSpawn",
    "PlayerDeath",
    "PlayerConnect",
    "Damage",
    "ulx",
    "UnArrests",
    "Warrant/Wants",
    "DoorRam",
    "Cheques",
    "Doors",
    "Money",
    "AFKs",
    "WeaponChecker",
    "Lockdowns",
    "Vehicles",
    "Bought",
    "Weapons",
    "Laws",
    "Spawned",
    "Namechange",
    "Demotes",
    "ChangeJob",
    "Lockpicks",
    "Pocket",
    "Hitman"
}

luctus_log_extras = {}

hook.Add("InitPostEntity","luctus_log_get_categories",function()
    net.Start("luctus_log_cats")
    net.SendToServer()
end)

net.Receive("luctus_log_cats",function()
    luctus_log_extras = net.ReadTable()
end)

luctuslog = luctuslog or {}
if luctuslog.log_win and IsValid(luctuslog.log_win) then luctuslog.log_win:Close() end
luctuslog.log = {}
luctuslog.log_win = nil
luctuslog.list = nil
luctuslog.page = 0
luctuslog.filter = ""
luctuslog.showid = nil
luctuslog.category = ""
luctuslog.clickable = true

local color_white = Color(255,255,255)
local color_hover = Color(0, 195, 165)

net.Receive("luctus_log",function()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    if tab ~= nil then
        luctuslog.log = tab
    end
    if not IsValid(luctuslog.log_win) or not IsValid(luctuslog.list) then
        luctuslog_createLogWindow()
    end
    luctuslog.list:Clear()
    for k,v in pairs(luctuslog.log) do
        if v.date then
            local msg = v.msg
            if IsValid(luctuslog.showid) and not luctuslog.showid:GetChecked() then
                local newmsg = string.gsub(msg,"%(STEAM_%d:%d:[%d]+%)","")
                local panel = luctuslog.list:AddLine( v.date, v.cat, newmsg )
                panel.msg = msg
            else
                local panel = luctuslog.list:AddLine( v.date, v.cat, v.msg )
                panel.msg = v.msg
            end
        end
    end
end)

hook.Add("KeyPress","luctus_log_refocus",function(ply,key)
    if ( key == IN_WALK ) then
        if IsValid(luctuslog.log_win) then
            luctuslog.clickable = true
            gui.EnableScreenClicker( true )
            luctuslog.log_win:SetMouseInputEnabled( true )
            luctuslog.log_win:SetKeyboardInputEnabled( true )
            luctuslog.log_win:RequestFocus()
        end
    end
end)

function luctusPrettifyScrollbar(el)
    function el:Paint() return end
    function el.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function el.btnUp:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function el.btnDown:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
end


function luctuslog_createLogWindow()
    if not luctuslog.log then return end
    luctuslog.page = 0
    luctuslog.log_win = vgui.Create("DFrame")
    luctuslog.log_win:SetTitle("luctuslog v3.1 | by OverlordAkise")
    luctuslog.log_win:SetSize( logWidth, logHeight )
    luctuslog.log_win:Center()
    luctuslog.log_win:SetX(ScrW()+300)
    luctuslog.log_win:MakePopup()
    luctuslog.log_win:ShowCloseButton(false)
    luctuslog.log_win:MoveTo(ScrW()/2-luctuslog.log_win:GetWide()/2, luctuslog.log_win:GetY(),0.5,0)
    function luctuslog.log_win:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    function luctuslog.log_win:OnKeyCodePressed(key) 
        if key == KEY_LALT then
            luctuslog.clickable = false
            gui.EnableScreenClicker(false)
            luctuslog.log_win:SetMouseInputEnabled(false)
            luctuslog.log_win:SetKeyboardInputEnabled(false)
        end
    end
    function luctuslog.log_win:OnClose()
        gui.EnableScreenClicker(false)
    end
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", luctuslog.log_win)
    CloseButton:SetText("X")
    CloseButton:SetPos(logWidth-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        gui.EnableScreenClicker( false )
        luctuslog.log_win:SetMouseInputEnabled( false )
        luctuslog.log_win:SetKeyboardInputEnabled( false )
        luctuslog.clickable = false
        luctuslog.log_win:MoveTo(-1*ScrW(), luctuslog.log_win:GetY(),0.5,0)
        timer.Simple(0.5,function()
            luctuslog.log_win:Close()
        end)
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end

    local toppanel = vgui.Create("DPanel",luctuslog.log_win)
    toppanel:Dock(TOP)
    function toppanel:Paint() end

    local leftpanel = vgui.Create("DPanel",luctuslog.log_win)
    leftpanel:Dock(LEFT)
    leftpanel:SetWide(150)
    function leftpanel:Paint() end

    local quicklabel = vgui.Create("DLabel",toppanel)
    quicklabel:Dock(LEFT)
    quicklabel:SetWide(150)
    quicklabel:SetText("Quick Filters")

    luctuslog.date_from = vgui.Create("DTextEntry",toppanel)
    luctuslog.date_from:Dock(LEFT)
    luctuslog.date_from:SetWide(110)
    luctuslog.date_from:SetValue( "2000-01-01 00:00:00" )
    luctuslog.date_from:SetDrawLanguageID(false)

    luctuslog.date_to = vgui.Create("DTextEntry",toppanel)
    luctuslog.date_to:Dock(LEFT)
    luctuslog.date_to:SetWide(110)
    luctuslog.date_to:SetValue( "2222-01-01 00:00:00" )
    luctuslog.date_to:SetDrawLanguageID(false)

    luctuslog.date_should = vgui.Create("DCheckBoxLabel",toppanel)
    luctuslog.date_should:Dock(LEFT)
    luctuslog.date_should:SetText("Filter by date")
    luctuslog.date_should:SetValue(false)
    luctuslog.date_should:DockMargin(10,0,10,0)

    luctuslog.filter = vgui.Create("DTextEntry",toppanel)
    luctuslog.filter:Dock(LEFT)
    luctuslog.filter:SetWide(150)
    luctuslog.filter:SetValue("")
    luctuslog.filter:SetPlaceholderText("Search...")
    luctuslog.filter:SetDrawLanguageID(false)
    
    luctuslog.showid = vgui.Create("DCheckBoxLabel",toppanel)
    luctuslog.showid:Dock(LEFT)
    luctuslog.showid:SetText("Show SteamIDs")
    luctuslog.showid:SetValue(false)
    luctuslog.showid:DockMargin(10,0,10,0)
    
    --Navigation
    
    luctuslog.SearchButton = vgui.Create("DButton",toppanel)
    luctuslog.SearchButton:SetText( "Search" )
    luctuslog.SearchButton:Dock(RIGHT)
    luctuslog.SearchButton:SetTextColor(color_hover)
    luctuslog.SearchButton.DoClick = function()
        luctuslog.category = ""
        luctuslog.page = 0
        luctuslog.PageNumber:SetText(luctuslog.page)
        luctuslog_clientRequest()
    end
    function luctuslog.SearchButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(0,255,0,255))
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function luctuslog.SearchButton:Think()
        if self:IsHovered() then
            self:SetTextColor(color_hover)
        else
            self:SetTextColor(color_white)
        end
    end
    
    luctuslog.RightButton = vgui.Create("DButton",toppanel)
    luctuslog.RightButton:SetText(">")
    luctuslog.RightButton:SetWide(25)
    luctuslog.RightButton:Dock(RIGHT)
    luctuslog.RightButton:DockMargin(0,0,10,0)
    luctuslog.RightButton:SetTextColor(color_white)
    luctuslog.RightButton.DoClick = function()
        luctuslog.page = luctuslog.page + 1
        luctuslog.PageNumber:SetText(luctuslog.page)
        luctuslog_clientRequest()
    end
    function luctuslog.RightButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function luctuslog.RightButton:Think()
        if self:IsHovered() then
            self:SetTextColor(color_hover)
        else
            self:SetTextColor(color_white)
        end
    end
    
    luctuslog.PageNumber = vgui.Create("DLabel",toppanel)
    luctuslog.PageNumber:Dock(RIGHT)
    luctuslog.PageNumber:SetText("0")
    luctuslog.PageNumber:SetWide(25)

    luctuslog.LeftButton = vgui.Create("DButton",toppanel)
    luctuslog.LeftButton:SetText("<")
    luctuslog.LeftButton:SetWide(25)
    luctuslog.LeftButton:Dock(RIGHT)
    luctuslog.LeftButton:DockMargin(0,0,10,0)
    luctuslog.LeftButton:SetTextColor(color_white)
    luctuslog.LeftButton.DoClick = function()
        luctuslog.page = luctuslog.page - 1
        if luctuslog.page < 0 then luctuslog.page = 0 end
        luctuslog.PageNumber:SetText(luctuslog.page)
        luctuslog_clientRequest()
    end
    function luctuslog.LeftButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_white)
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function luctuslog.LeftButton:Think()
        if self:IsHovered() then
            self:SetTextColor(color_hover)
        else
            self:SetTextColor(color_white)
        end
    end
    
    --Loglines

    luctuslog.list = vgui.Create("DListView",luctuslog.log_win)
    luctuslog.list:Dock(FILL)
    luctuslog.list:SetPos( 112, 52 )
    luctuslog.list:SetSize( 840-112-1, 448-1 )
    luctuslog.list:SetMultiSelect( false )
    luctuslog.list:AddColumn("Date"):SetFixedWidth(120)
    luctuslog.list:AddColumn("Cat"):SetFixedWidth(100)
    luctuslog.list:AddColumn("Message")
    function luctuslog.list:OnRowRightClick(lineID, line)
        local Menu = DermaMenu()
        Menu:AddOption("Copy line to clipboard"):SetIcon("icon16/add.png")
        Menu:AddOption("Search for category"):SetIcon("icon16/arrow_left.png")
        local players = {}
        for s in string.gmatch(line.msg,"STEAM_%d:%d:[%d]+") do
            table.insert(players,s)
        end
        for i=1,#players do
            local plysubmenu, parent = Menu:AddSubMenu("PLY#"..i.." - "..players[i])
            parent:SetIcon("icon16/user_go.png")
            plysubmenu.steamid = players[i]
            plysubmenu:AddOption("Copy SteamID of user"):SetIcon("icon16/attach.png")
            plysubmenu:AddOption("Search for SteamID of user"):SetIcon("icon16/magnifier.png")
            plysubmenu:AddSpacer()
            plysubmenu.ply = player.GetBySteamID(players[i])
            if plysubmenu.ply then
                for k,v in pairs(luctus_log_ulxs) do
                    plysubmenu:AddOption(k):SetIcon("icon16/bullet_go.png")
                end
            else
                plysubmenu:AddOption("User is offline"):SetIcon("icon16/world_go.png")
            end
            function plysubmenu:OptionSelected(selPanel,text)
                if text == "Copy SteamID of user" then
                    SetClipboardText(self.steamid)
                    return
                end
                if text == "Search for SteamID of user" then
                    luctuslog.filter:SetValue(self.steamid)
                    luctuslog.category = ""
                    luctuslog.page = 0
                    luctuslog.PageNumber:SetText(0)
                    luctuslog_clientRequest()
                    return
                end
                if luctus_log_ulxs[text] then
                    luctus_log_ulxs[text](self.ply)
                end
            end
        end
        Menu:AddSpacer()
        Menu:AddOption("Reset all filters"):SetIcon("icon16/arrow_rotate_clockwise.png")
        function Menu:OptionSelected(selPanel, panelText)
            if panelText == "Copy line to clipboard" then 
                SetClipboardText("["..line:GetColumnText(1).."] "..line.msg)
                return 
            end
            if panelText == "Search for category" then
                luctuslog.filter:SetValue("")
                luctuslog.category = line:GetColumnText(2) --Cat
                luctuslog.page = 0
                luctuslog.PageNumber:SetText(0)
                luctuslog_clientRequest()
                return
            end
            if panelText == "Reset all filters" then
                luctuslog.filter:SetValue("")
                luctuslog.category = ""
                luctuslog.page = 0
                luctuslog.PageNumber:SetText(0)
                luctuslog_clientRequest()
                return
            end
        end
        Menu:Open()
    end

    luctuslog.quicklist = vgui.Create("DCategoryList",leftpanel)
    luctuslog.quicklist:Dock(FILL)
    function luctuslog.quicklist:Paint() end

    local scrollBar = luctuslog.quicklist:GetVBar()
    luctusPrettifyScrollbar(scrollBar)
  
    --Add players to quickfilter
    playersCat = luctuslog.quicklist:Add("Players")
    for k,v in pairs(player.GetAll()) do
        luctuslogCreateButton(v:Nick(),v:SteamID(),"",playersCat)
    end
  
    --Add luctus_log_quickfilters for events
    eventsCat = luctuslog.quicklist:Add("Events")
    for k,v in pairs(luctus_log_quickfilters) do
        luctuslogCreateButton(v,"",v,eventsCat)
    end
    
    --Add addons
    addonsCat = luctuslog.quicklist:Add("Addons")
    for k,v in pairs(luctus_log_extras) do
        luctuslogCreateButton(v,"",v,addonsCat)
    end
  
end

function luctuslogCreateButton(name,filter,category,categoryList)
    local DButton = categoryList:Add( name )
    DButton:SetHeight(32)
    DButton:SetTextColor(color_white)
    DButton.filter = filter
    DButton.category = category
    function DButton:DoClick()
        luctuslog.filter:SetValue(self.filter)
        luctuslog.category = self.category
        luctuslog.page = 0
        luctuslog.PageNumber:SetText(luctuslog.page)
        luctuslog_clientRequest()
    end
    function DButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(32, 34, 37))
        draw.RoundedBox(0, 1, h-2, w, h-1, Color(200,200,200,255))
    end
    function DButton:Think()
        if self:IsHovered() then
            self:SetTextColor(color_hover)
        else
            self:SetTextColor(color_white)
        end
    end
end

function luctuslog_clientRequest()
    local adate = ""
    local zdate = ""
    if luctuslog.date_should:GetChecked() then
        adate = luctuslog.date_from:GetValue()
        zdate = luctuslog.date_to:GetValue()
        if adate:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") == nil then
            Derma_Message("Please enter a valid From-Date (YYYY-MM-DD HH:MM:SS) !", "[luctuslog]", "OK")
            return
        end
        if zdate:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") == nil then
            Derma_Message("Please enter a valid To-Date (YYYY-MM-DD HH:MM:SS) !", "[luctuslog]", "OK")
            return
        end
    end
    net.Start("luctus_log")
        net.WriteString(luctuslog.filter:GetValue())
        net.WriteString(luctuslog.page)
        if luctuslog.date_should:GetChecked() then
            net.WriteString(adate)
            net.WriteString(zdate)
        else
            net.WriteString("")
            net.WriteString("")
        end
        net.WriteString(luctuslog.category)
    net.SendToServer()
end

print("[luctus_logs] cl loaded")
