--CONFIG START

local quickfilters = {
  ["ULX"] = "%ulx%",
  ["PropSpawns"] = "%spawned prop%",
  ["Chats"] = "% said %",
  ["PlayerDeaths"] = "% was killed %",
  ["Dis-/Connect"] = "%connect%",
  ["Bought stuff"] = "%bought%",
  ["Spawned stuff"] = "%spawned%",
  ["Vehicles"] = "%vehicle%",
  ["Namechange"] = "%changed name%",
  ["Damage"] = "%damaged%",
  ["Arrests"] = "%arrest%",
  ["Hitman"] = "%hit%",
  ["Pocket"] = "%pocket%",
  ["Lockpick"] = "%lockpick%",
  ["Toolgun"] = "%toolgun%",
  ["Law"] = "%law%",
  ["Money"] = "%$%",
}

--CONFIG END

local lucidlog = lucidlog or {}
if lucidlog.log_win then lucidlog.log_win:Close() end
lucidlog.log = {}
lucidlog.log_win = nil
lucidlog.list = nil
lucidlog.page = 0
lucidlog.clickable = true

net.Receive("lucid_log",function()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local tab = util.JSONToTable(jtext)
  --[[for k, v in pairs( tab ) do
    print( v )
  end--]]
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

function lucidlog_createLogWindow()
  if not lucidlog.log then return end
  lucidlog.log_win = vgui.Create("DFrame")
  lucidlog.log_win:SetTitle("LucidLog v2.0 | by OverlordAkise")
  lucidlog.log_win:SetSize( 840, 500 )
  lucidlog.log_win:Center()
  lucidlog.log_win:MakePopup()
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

  lucidlog.date_from = lucidlog.log_win:Add("DTextEntry")
  lucidlog.date_from:SetPos( 111, 25 )
  lucidlog.date_from:SetSize( 110, 25 )
  lucidlog.date_from:SetValue( "2000-01-01 00:00:00" )
  lucidlog.date_from:SetDrawLanguageID(false)
  
  lucidlog.date_to = lucidlog.log_win:Add("DTextEntry")
  lucidlog.date_to:SetPos( 221, 25 )
  lucidlog.date_to:SetSize( 110, 25 )
  lucidlog.date_to:SetValue( "2222-01-01 00:00:00" )
  lucidlog.date_to:SetDrawLanguageID(false)
  
  lucidlog.date_should = lucidlog.log_win:Add("DCheckBoxLabel")
  lucidlog.date_should:SetPos( 332, 30 )
  lucidlog.date_should:SetText("Filter by date")
  lucidlog.date_should:SetValue(false)
  lucidlog.date_should:SizeToContents()
  
  lucidlog.filter = lucidlog.log_win:Add("DTextEntry")
  lucidlog.filter:SetPos( 425, 25 )
  lucidlog.filter:SetSize( 200, 25 )
  lucidlog.filter:SetValue( "%spawned prop%" )
  lucidlog.filter:SetDrawLanguageID(false)
  
  lucidlog.filter_should = lucidlog.log_win:Add("DCheckBoxLabel")
  lucidlog.filter_should:SetPos( 627, 30 )
  lucidlog.filter_should:SetText("Filter by text")
  lucidlog.filter_should:SetValue( false )
  lucidlog.filter_should:SizeToContents()
  
  lucidlog.LeftButton = lucidlog.log_win:Add("DButton")
  lucidlog.LeftButton:SetText( "<" )
  lucidlog.LeftButton:SetPos( 715, 25 )
  lucidlog.LeftButton:SetSize( 20, 25 )
  lucidlog.LeftButton.DoClick = function()
    lucidlog.page = lucidlog.page - 1
    if lucidlog.page < 0 then lucidlog.page = 0 end
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end
  
  lucidlog.PageNumber = lucidlog.log_win:Add("DLabel")
  lucidlog.PageNumber:SetPos( 740, 28 )
  lucidlog.PageNumber:SetText("0")
  
  lucidlog.RightButton = lucidlog.log_win:Add("DButton")
  lucidlog.RightButton:SetText( ">" )
  lucidlog.RightButton:SetPos( 750, 25 )
  lucidlog.RightButton:SetSize( 20, 25 )
  lucidlog.RightButton.DoClick = function()
    lucidlog.page = lucidlog.page + 1
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end
  
  lucidlog.SearchButton = lucidlog.log_win:Add("DButton")
  lucidlog.SearchButton:SetText( "Search" )
  lucidlog.SearchButton:SetPos( 778, 25 )
  lucidlog.SearchButton:SetSize( 60, 25 )
  lucidlog.SearchButton.DoClick = function()
    lucidlog.page = 0
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end

  lucidlog.list = lucidlog.log_win:Add("DListView")
  --AppList:Dock( FILL )
  lucidlog.list:SetPos( 112, 52 )
  lucidlog.list:SetSize( 840-112-1, 448-1 )
  lucidlog.list:SetMultiSelect( false )
  lucidlog.list:AddColumn( "Date" ):SetWidth(120)
  lucidlog.list:AddColumn( "Message" ):SetWidth(607)

  for k,v in pairs( lucidlog.log ) do
    if(v.date)then
      lucidlog.list:AddLine( v.date, v.msg )
    end
  end
  --lucidlog.list.OnRowSelected = function( lst, index, pnl )
    --print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
  --end
  
  local quicklabel = lucidlog.log_win:Add("DLabel")
  quicklabel:SetPos( 10, 28 )
  quicklabel:SetText("Quick Filters")
  
  lucidlog.quicklist = lucidlog.log_win:Add("DScrollPanel")
  lucidlog.quicklist:SetPos(2,51)
  lucidlog.quicklist:SetSize(110,499-51-2)
  
  local DButton = nil
  --Add players to quickfilter
  for k,v in pairs(player.GetAll()) do
    DButton = lucidlog.quicklist:Add( "DButton" )
    DButton:SetText(v:Nick())
    DButton:Dock( TOP )
    DButton:DockMargin( 0, 0, 0, 5 )
    DButton.filter = "%"..v:SteamID().."%"
    function DButton:DoClick()
      lucidlog.filter_should:SetValue(true)
      lucidlog.filter:SetValue(self.filter)
      lucidlog.page = 0
      lucidlog.PageNumber:SetText(lucidlog.page)
      lucidlog_clientRequest()
    end
  end
  
  DButton = lucidlog.quicklist:Add( "DButton" )
  DButton:SetText("------------")
  DButton:Dock( TOP )
  DButton:DockMargin( 0, 0, 0, 5 )
  
  --Add quickfilters for events
  for k,v in pairs(quickfilters) do
    local DButton = lucidlog.quicklist:Add( "DButton" )
    DButton:SetText(k)
    DButton:Dock( TOP )
    DButton:DockMargin( 0, 0, 0, 5 )
    DButton.filter = v
    function DButton:DoClick()
      lucidlog.filter_should:SetValue(true)
      lucidlog.filter:SetValue(self.filter)
      lucidlog.page = 0
      lucidlog.PageNumber:SetText(lucidlog.page)
      lucidlog_clientRequest()
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
      --DarkRP.Notify(ply, 1, 5, "[lucidlog] Please enter a valid From-Date !")
      Derma_Message("Please enter a valid From-Date (YYYY-MM-DD HH:MM:SS) !", "[lucidlog]", "OK")
      return
    end
    if zdate:match("%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d") == nil then
      --DarkRP.Notify(ply, 1, 5, "[lucidlog] Please enter a valid To-Date !")
      Derma_Message("Please enter a valid To-Date (YYYY-MM-DD HH:MM:SS) !", "[lucidlog]", "OK")
      return
    end
    local t = {}
    --t.year,t.month,t.day,t.hour,t.min,t.sec = aa:match("(%d%d%d%d).(%d%d).(%d%d) (%d%d):(%d%d):(%d%d)")
    --adate = os.time({year=t.year, month=t.month, day=t.day, hour=t.hour, min=t.min, sec=t.sec})
    local tt = {}
    --tt.year,tt.month,tt.day,tt.hour,tt.min,tt.sec = zz:match("(%d%d%d%d).(%d%d).(%d%d) (%d%d):(%d%d):(%d%d)")
    --zdate = os.time({year=tt.year, month=tt.month, day=tt.day, hour=tt.hour, min=tt.min, sec=tt.sec})
    
    --print("First")
    --PrintTable(t)
    --print("Second")
    --PrintTable(tt)
    --print("First: "..adate)
    --print("Second: "..zdate) 
  end
  net.Start("lucid_log")
    if lucidlog.filter_should:GetChecked() then 
      net.WriteString(lucidlog.filter:GetValue())
    else
      net.WriteString("%")
    end

    net.WriteString(lucidlog.page)

    if lucidlog.date_should:GetChecked() then
      --print("Sending date "..adate.." and "..zdate)
      net.WriteString(adate)
      net.WriteString(zdate)
    else
      net.WriteString("")
      net.WriteString("")
    end 
  net.SendToServer()
end