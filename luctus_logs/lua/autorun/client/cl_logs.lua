--Luctus Logs
--Made by OverlordAkise

lucid_log_quickfilters = {
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

--Support for adding custom categories
hook.Add("InitPostEntity","luctus_log_categories",function()
    hook.Run("LuctusLogAddCategory")
end)

--custom addon support
--gDeathSystem
if MedConfig then
    table.insert(lucid_log_quickfilters,"gDeathSystem")
end
--cuffs
if hook.GetTable()["SetupMove"] and hook.GetTable()["SetupMove"]["Cuffs_MovePenalty"] then
    table.insert(lucid_log_quickfilters,"cuffs")
end

lucid_log_gas_quickfilters = {}

GAS = {}
GAS.Logging = {}

function GAS.Logging:FormatPlayer(ply)
    return ""
end

function GAS.Logging:AddModule(MODULE)
    print("[LucidLog] Added module "..MODULE.Name)
end


function GAS.Logging:MODULE()
    local mod = {}
    mod.catName = "GAS"
    function mod:Hook(name,id,func)
        self.catName = name
        table.insert(lucid_log_gas_quickfilters,name)
    end
    function mod:Log(text)
    end
    return mod
end

local logFiles = file.Find("gmodadminsuite/modules/logging/modules/addons/*.lua", "LUA")
PrintTable(logFiles)
for k,v in pairs(logFiles) do
    include("gmodadminsuite/modules/logging/modules/addons/"..v)
end


local lucidlog = lucidlog or {}
if lucidlog.log_win then lucidlog.log_win:Close() end
lucidlog.log = {}
lucidlog.log_win = nil
lucidlog.list = nil
lucidlog.page = 0
lucidlog.filter = ""
lucidlog.category = ""
lucidlog.clickable = true

net.Receive("lucid_log",function()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    if tab ~= nil then
        lucidlog.log = tab
    end
  
    if IsValid(lucidlog.log_win) and IsValid(lucidlog.list) and lucidlog.log ~= nil then
        lucidlog.list:Clear()
        for k,v in pairs(lucidlog.log) do
            if(v.date)then
                lucidlog.list:AddLine( v.date, v.msg )
            end
        end
    else
        lucidlog_createLogWindow()
    end
end)

hook.Add("KeyPress","lucid_log_refocus",function(ply,key)
    if ( key == IN_WALK ) then
        if IsValid(lucidlog.log_win) then
            lucidlog.clickable = true
            gui.EnableScreenClicker( true )
            lucidlog.log_win:SetMouseInputEnabled( true )
            lucidlog.log_win:SetKeyboardInputEnabled( true )
            lucidlog.log_win:RequestFocus()
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


function lucidlog_createLogWindow()
    if not lucidlog.log then return end
    lucidlog.log_win = vgui.Create("DFrame")
    lucidlog.log_win:SetTitle("LucidLog v3.1 | by OverlordAkise")
    lucidlog.log_win:SetSize( 900, 500 )
    lucidlog.log_win:Center()
    lucidlog.log_win:SetX(ScrW()+300)
    lucidlog.log_win:MakePopup()
    lucidlog.log_win:ShowCloseButton(false)
    lucidlog.log_win:MoveTo(ScrW()/2-lucidlog.log_win:GetWide()/2, lucidlog.log_win:GetY(),0.5,0)
    function lucidlog.log_win:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    function lucidlog.log_win:OnKeyCodePressed( key ) 
        if ( key == KEY_LALT ) then
            lucidlog.clickable = false
            gui.EnableScreenClicker( false )
            lucidlog.log_win:SetMouseInputEnabled( false )
            lucidlog.log_win:SetKeyboardInputEnabled( false )
        end
    end
    function lucidlog.log_win:OnClose()
        gui.EnableScreenClicker( false )
    end
  
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", lucidlog.log_win)
    CloseButton:SetText("X")
    CloseButton:SetPos(900-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        gui.EnableScreenClicker( false )
        lucidlog.log_win:SetMouseInputEnabled( false )
        lucidlog.log_win:SetKeyboardInputEnabled( false )
        lucidlog.clickable = false
        lucidlog.log_win:MoveTo(-1*ScrW(), lucidlog.log_win:GetY(),0.5,0)
        timer.Simple(0.5,function()
            lucidlog.log_win:Close()
        end)
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if (self.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end

    local toppanel = vgui.Create("DPanel",lucidlog.log_win)
    toppanel:Dock(TOP)
    function toppanel:Paint() end

    local leftpanel = vgui.Create("DPanel",lucidlog.log_win)
    leftpanel:Dock(LEFT)
    leftpanel:SetWide(150)
    function leftpanel:Paint() end

    local quicklabel = vgui.Create("DLabel",toppanel)
    quicklabel:Dock(LEFT)
    quicklabel:SetWide(150)
    quicklabel:SetText("Quick Filters")

    lucidlog.date_from = vgui.Create("DTextEntry",toppanel)
    lucidlog.date_from:Dock(LEFT)
    lucidlog.date_from:SetWide(110)
    lucidlog.date_from:SetValue( "2000-01-01 00:00:00" )
    lucidlog.date_from:SetDrawLanguageID(false)

    lucidlog.date_to = vgui.Create("DTextEntry",toppanel)
    lucidlog.date_to:Dock(LEFT)
    lucidlog.date_to:SetWide(110)
    lucidlog.date_to:SetValue( "2222-01-01 00:00:00" )
    lucidlog.date_to:SetDrawLanguageID(false)

    lucidlog.date_should = vgui.Create("DCheckBoxLabel",toppanel)
    lucidlog.date_should:Dock(LEFT)
    lucidlog.date_should:SetText("Filter by date")
    lucidlog.date_should:SetValue(false)
    lucidlog.date_should:DockMargin(0,0,10,0)

    lucidlog.filter = vgui.Create("DTextEntry",toppanel)
    lucidlog.filter:Dock(LEFT)
    lucidlog.filter:SetWide(150)
    lucidlog.filter:SetValue("")
    lucidlog.filter:SetDrawLanguageID(false)

    lucidlog.filter_should = vgui.Create("DCheckBoxLabel",toppanel)
    lucidlog.filter_should:Dock(LEFT)
    lucidlog.filter_should:SetText("Filter by text")
    lucidlog.filter_should:SetValue( false )
    lucidlog.filter_should:DockMargin(0,0,10,0)


    lucidlog.LeftButton = vgui.Create("DButton",toppanel)
    lucidlog.LeftButton:SetText( "<" )
    lucidlog.LeftButton:SetWide(25)
    lucidlog.LeftButton:Dock(LEFT)
    lucidlog.LeftButton:DockMargin(0,0,10,0)
    lucidlog.LeftButton:SetTextColor(Color(255,255,255))
    lucidlog.LeftButton.DoClick = function()
        lucidlog.page = lucidlog.page - 1
        if lucidlog.page < 0 then lucidlog.page = 0 end
        lucidlog.PageNumber:SetText(lucidlog.page)
        lucidlog_clientRequest()
    end
    function lucidlog.LeftButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255))
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function lucidlog.LeftButton:Think()
        if self:IsHovered() then
            self:SetTextColor(Color(0, 195, 165))
        else
            self:SetTextColor(Color(255,255,255))
        end
    end
  
    lucidlog.PageNumber = vgui.Create("DLabel",toppanel)
    lucidlog.PageNumber:Dock(LEFT)
    lucidlog.PageNumber:SetText("0")
    lucidlog.PageNumber:SetWide(25)

    lucidlog.RightButton = vgui.Create("DButton",toppanel)
    lucidlog.RightButton:SetText( ">" )
    lucidlog.RightButton:SetWide(25)
    lucidlog.RightButton:Dock(LEFT)
    lucidlog.RightButton:SetTextColor(Color(255,255,255))
    lucidlog.RightButton.DoClick = function()
        lucidlog.page = lucidlog.page + 1
        lucidlog.PageNumber:SetText(lucidlog.page)
        lucidlog_clientRequest()
    end
    function lucidlog.RightButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255))
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function lucidlog.RightButton:Think()
        if self:IsHovered() then
            self:SetTextColor(Color(0, 195, 165))
        else
            self:SetTextColor(Color(255,255,255))
        end
    end
  
    lucidlog.SearchButton = vgui.Create("DButton",toppanel)
    lucidlog.SearchButton:SetText( "Search" )
    lucidlog.SearchButton:Dock(RIGHT)
    lucidlog.SearchButton:SetTextColor(Color(0, 195, 165))
    lucidlog.SearchButton.DoClick = function()
        lucidlog.category = ""
        lucidlog.page = 0
        lucidlog.PageNumber:SetText(lucidlog.page)
        lucidlog_clientRequest()
    end
    function lucidlog.SearchButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(0,255,0,255))
        draw.RoundedBox(0, 1, 1, w-2, h-2, Color(32, 34, 37))
    end
    function lucidlog.SearchButton:Think()
        if self:IsHovered() then
            self:SetTextColor(Color(0, 195, 165))
        else
            self:SetTextColor(Color(255,255,255))
        end
    end

    lucidlog.list = vgui.Create("DListView",lucidlog.log_win)
    lucidlog.list:Dock( FILL )
    lucidlog.list:SetPos( 112, 52 )
    lucidlog.list:SetSize( 840-112-1, 448-1 )
    lucidlog.list:SetMultiSelect( false )
    lucidlog.list:AddColumn( "Date" ):SetWidth(120)
    lucidlog.list:AddColumn( "Message" ):SetWidth(607)
    function lucidlog.list:OnRowRightClick(lineID, line)
        local Menu = DermaMenu()
        local activeB = Menu:AddOption("Copy line to clipboard")
        activeB:SetIcon( "icon16/add.png" )
        if string.match(line:GetColumnText(2),"STEAM_%d:%d:[%d]+") ~= nil then
            local inactiveB = Menu:AddOption("Copy SteamID of user")
            inactiveB:SetIcon( "icon16/attach.png" )
            local deleteB = Menu:AddOption("Filter for user")
            deleteB:SetIcon( "icon16/magnifier_zoom_in.png" )
        end
        function Menu:OptionSelected(selPanel, panelText)
            if panelText == "Copy line to clipboard" then 
                SetClipboardText("["..line:GetColumnText(1).."] "..line:GetColumnText(2))
                return 
            end
            if string.match(line:GetColumnText(2),"STEAM_%d:%d:[%d]+") ~= nil then
                if panelText == "Copy SteamID of user" then 
                    SetClipboardText(string.match(line:GetColumnText(2),"STEAM_%d:%d:[%d]+"))
                    return 
                end
                if panelText == "Filter for user" then 
                    lucidlog.filter:SetValue(string.match(line:GetColumnText(2),"STEAM_%d:%d:[%d]+"))
                    lucidlog.filter_should:SetValue(true)
                    lucidlog.category = ""
                    lucidlog.page = 0
                    lucidlog.PageNumber:SetText(lucidlog.page)
                    lucidlog_clientRequest()
                    return 
                end
            end
        end
        Menu:Open()
    end

    for k,v in pairs( lucidlog.log ) do
        if(v.date)then
            lucidlog.list:AddLine( v.date, v.msg )
        end
    end
  
    lucidlog.quicklist = vgui.Create("DCategoryList",leftpanel)
    lucidlog.quicklist:Dock(FILL)
    function lucidlog.quicklist:Paint() end

    local scrollBar = lucidlog.quicklist:GetVBar()
    luctusPrettifyScrollbar(scrollBar)
  
    --Add players to quickfilter
    playersCat = lucidlog.quicklist:Add("Players")
    for k,v in pairs(player.GetAll()) do
        lucidLogCreateButton(v:Nick(),v:SteamID(),"",playersCat)
    end
  
    --Add lucid_log_quickfilters for events
    eventsCat = lucidlog.quicklist:Add("Events")
    for k,v in pairs(lucid_log_quickfilters) do
        lucidLogCreateButton(v,"",v,eventsCat)
    end
  
    --Add GAS modules to quickfilters
    gasEventsCat = lucidlog.quicklist:Add("GAS Events")
    for k,v in pairs(lucid_log_gas_quickfilters) do
        lucidLogCreateButton(v,"",v,gasEventsCat)
    end
  
end

function lucidLogCreateButton(name,filter,category,categoryList)
    local DButton = categoryList:Add( name )
    DButton:SetHeight(32)
    DButton:SetTextColor(Color(255,255,255))
    DButton.filter = filter
    DButton.category = category
    function DButton:DoClick()
        lucidlog.filter:SetValue(self.filter)
        if self.filter ~= "" then
            lucidlog.filter_should:SetValue(true)
        else
            lucidlog.filter_should:SetValue(false)
        end
        lucidlog.category = self.category
        lucidlog.page = 0
        lucidlog.PageNumber:SetText(lucidlog.page)
        lucidlog_clientRequest()
    end
    function DButton:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,Color(32, 34, 37))
        draw.RoundedBox(0, 1, h-2, w, h-1, Color(200,200,200,255))
    end
    function DButton:Think()
        if self:IsHovered() then
            self:SetTextColor(Color(0, 195, 165))
        else
            self:SetTextColor(Color(255,255,255))
        end
    end
end

function lucidlog_clientRequest()
    local adate = ""
    local zdate = ""
    if lucidlog.date_should:GetChecked() then
        adate = lucidlog.date_from:GetValue()
        zdate = lucidlog.date_to:GetValue()
        if adate:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") == nil then
            Derma_Message("Please enter a valid From-Date (YYYY-MM-DD HH:MM:SS) !", "[lucidlog]", "OK")
            return
        end
        if zdate:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") == nil then
            Derma_Message("Please enter a valid To-Date (YYYY-MM-DD HH:MM:SS) !", "[lucidlog]", "OK")
            return
        end
    end
    net.Start("lucid_log")
        if lucidlog.filter_should:GetChecked() then 
            net.WriteString(lucidlog.filter:GetValue())
        else
            net.WriteString("")
        end

        net.WriteString(lucidlog.page)

        if lucidlog.date_should:GetChecked() then
            net.WriteString(adate)
            net.WriteString(zdate)
        else
            net.WriteString("")
            net.WriteString("")
        end
        net.WriteString(lucidlog.category)
    net.SendToServer()
end

print("[luctus_logs] cl loaded")
