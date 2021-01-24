local lucidlog = lucidlog or {}
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
        lucidlog.list:AddLine( os.date("%Y.%m.%d %H:%M:%S",v.date), v.msg )
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
  lucidlog.log_win:SetTitle("Lucid's DarkRP Log")
  lucidlog.log_win:SetSize( 800, 500 )
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
  lucidlog.date_from:SetPos( 1, 25 )
  lucidlog.date_from:SetSize( 126, 25 )
  lucidlog.date_from:SetValue( "2000.01.01 00:00:00" )
  
  lucidlog.date_to = lucidlog.log_win:Add("DTextEntry")
  lucidlog.date_to:SetPos( 127, 25 )
  lucidlog.date_to:SetSize( 125, 25 )
  lucidlog.date_to:SetValue( "2222.01.01 00:00:00" )
  
  lucidlog.date_should = lucidlog.log_win:Add("DCheckBoxLabel")
  lucidlog.date_should:SetPos( 256, 30 )
  lucidlog.date_should:SetText("Filter by date")
  lucidlog.date_should:SetValue( false )
  lucidlog.date_should:SizeToContents()
  
  lucidlog.filter = lucidlog.log_win:Add("DTextEntry")
  lucidlog.filter:SetPos( 360, 25 )
  lucidlog.filter:SetSize( 200, 25 )
  lucidlog.filter:SetValue( "%spawned prop%" )
  lucidlog.filter.OnEnter = function( self )
    chat.AddText( self:GetValue() )
  end
  
  lucidlog.filter_should = lucidlog.log_win:Add("DCheckBoxLabel")
  lucidlog.filter_should:SetPos( 564, 30 )
  lucidlog.filter_should:SetText("Filter by text")
  lucidlog.filter_should:SetValue( false )
  lucidlog.filter_should:SizeToContents()
  
  lucidlog.LeftButton = lucidlog.log_win:Add("DButton")
  lucidlog.LeftButton:SetText( "<" )
  lucidlog.LeftButton:SetPos( 660, 25 )
  lucidlog.LeftButton:SetSize( 20, 25 )
  lucidlog.LeftButton.DoClick = function()
    lucidlog.page = lucidlog.page - 1
    if lucidlog.page < 0 then lucidlog.page = 0 end
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end
  
  lucidlog.PageNumber = lucidlog.log_win:Add("DLabel")
  lucidlog.PageNumber:SetPos( 688, 28 )
  lucidlog.PageNumber:SetText("0")
  
  lucidlog.RightButton = lucidlog.log_win:Add("DButton")
  lucidlog.RightButton:SetText( ">" )
  lucidlog.RightButton:SetPos( 700, 25 )
  lucidlog.RightButton:SetSize( 20, 25 )
  lucidlog.RightButton.DoClick = function()
    lucidlog.page = lucidlog.page + 1
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end
  
  lucidlog.SearchButton = lucidlog.log_win:Add("DButton")
  lucidlog.SearchButton:SetText( "Search" )
  lucidlog.SearchButton:SetPos( 730, 25 )
  lucidlog.SearchButton:SetSize( 68, 25 )
  lucidlog.SearchButton.DoClick = function()
    lucidlog.page = 0
    lucidlog.PageNumber:SetText(lucidlog.page)
    lucidlog_clientRequest()
  end

  lucidlog.list = lucidlog.log_win:Add("DListView")
  --AppList:Dock( FILL )
  lucidlog.list:SetPos( 0, 52 )
  lucidlog.list:SetSize( 800, 448 )
  lucidlog.list:SetMultiSelect( false )
  lucidlog.list:AddColumn( "Date" )
  lucidlog.list:AddColumn( "Message" )

  for k,v in pairs( lucidlog.log ) do
    lucidlog.list:AddLine( os.date("%Y.%m.%d %H:%M:%S",v.date), v.msg )
  end
  lucidlog.list.OnRowSelected = function( lst, index, pnl )
    --print( "Selected " .. pnl:GetColumnText( 1 ) .. " ( " .. pnl:GetColumnText( 2 ) .. " ) at index " .. index )
  end
end

function lucidlog_clientRequest()
  local adate = {}
  local zdate = {}
  if lucidlog.date_should:GetChecked() then
    local aa = lucidlog.date_from:GetValue()
    local zz = lucidlog.date_to:GetValue()
    if aa:match("%d%d%d%d.%d%d.%d%d %d%d:%d%d:%d%d") == nil then
      DarkRP.notify(ply, 1, 5, "[lucidloglog] Please enter a valid From-Date !")
      return
    end
    if zz:match("%d%d%d%d.%d%d.%d%d %d%d:%d%d:%d%d") == nil then
      DarkRP.notify(ply, 1, 5, "[lucidloglog] Please enter a valid To-Date !")
      return
    end
    local t = {}
    t.year,t.month,t.day,t.hour,t.min,t.sec = aa:match("(%d%d%d%d).(%d%d).(%d%d) (%d%d):(%d%d):(%d%d)")
    adate = os.time({year=t.year, month=t.month, day=t.day, hour=t.hour, min=t.min, sec=t.sec})
    local tt = {}
    tt.year,tt.month,tt.day,tt.hour,tt.min,tt.sec = zz:match("(%d%d%d%d).(%d%d).(%d%d) (%d%d):(%d%d):(%d%d)")
    zdate = os.time({year=tt.year, month=tt.month, day=tt.day, hour=tt.hour, min=tt.min, sec=tt.sec})
    
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