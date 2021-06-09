--Luctus Research
--Made by OverlordAkise

--Config is in the sv_ file

lresearch = nil
lresearch_list = nil
lresearch_page = 0
lresearch_searchid = 0
lresearch_searchtext = ""

net.Receive("luctus_research_getall",function()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local tab = util.JSONToTable(jtext)
  if tab == nil then return end
  
  if not IsValid(lresearch) then luctusOpenMainResearchWindow() end
  
  if IsValid(lresearch_list) then
    lresearch_list:Clear()
    for k,v in pairs(tab) do
      lresearch_list:AddLine( v.rowid, v.date, v.researcher, v.summary )
    end
  end
end)

net.Receive("luctus_research_getid",function(len,ply)
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local tab = util.JSONToTable(jtext)
  if tab == nil then return end
  luctusOpenPaperWindow(tab)
end)

function luctusOpenMainResearchWindow()
  --if lresearch then return end
  lresearch = vgui.Create("DFrame")
  lresearch:SetTitle("Research DB | v1.0 | Made by Luctus")
  lresearch:SetSize(800,600)
  lresearch:Center()
  lresearch:MakePopup()
  function lresearch:OnClose()
    lresearch_list = nil
    lresearch_page = 0
    lresearch_searchid = 0
    lresearch_searchtext = ""
  end
  
  local MenuBar = vgui.Create( "DMenuBar", lresearch )
  MenuBar:DockMargin( 0, 0, 0, 0 )

  local M1 = MenuBar:AddMenu( "Paper" )
  M1:AddOption("New", function()
    luctusOpenPaperWindow()
  end):SetIcon("icon16/page_add.png")
  
  M1:AddOption("Open by ID", function()
    Derma_StringRequest(
      "Research DB | Request by ID", 
      "Please enter the paper ID, numbers only!",
      "1",
      function(text)
        if not tonumber(text) then return end
        net.Start("luctus_research_getid")
          net.WriteInt(tonumber(text),32)
          net.WriteBool(false)
        net.SendToServer()
      end,
      function(text) end
    )
    
  end):SetIcon("icon16/folder.png")
  
  M1:AddOption("Edit by ID", function()
    if not LocalPlayer():IsAdmin() then
      Derma_Message("Only Admins can edit papers!", "Research DB | error", "OK")
      return
    end
    Derma_StringRequest(
      "Research DB | Edit by ID", 
      "Please enter the ID of the paper you want to edit, numbers only!",
      "1",
      function(text)
        if not tonumber(text) then return end
        net.Start("luctus_research_getid")
          net.WriteInt(tonumber(text),32)
          net.WriteBool(true)
        net.SendToServer()
      end,
      function(text) end
    )
  end):SetIcon("icon16/folder_edit.png")
  
  M1:AddOption("Delete by ID", function()
    if not LocalPlayer():IsAdmin() then
      Derma_Message("Only Admins can delete papers!", "Research DB | error", "OK")
      return
    end
    Derma_StringRequest(
      "Research DB | Delete by ID", 
      "Please enter the ID of the paper you want to delete, numbers only!",
      "1",
      function(text)
        if not tonumber(text) then return end
        net.Start("luctus_research_deleteid")
          net.WriteInt(tonumber(text),32)
        net.SendToServer()
        timer.Simple(0.1,function()
          net.Start("luctus_research_getall")
            net.WriteInt(lresearch_page,32)
          net.SendToServer()
        end)
      end,
      function(text) end
    )
  end):SetIcon("icon16/folder_delete.png")
  
  local M2 = MenuBar:AddMenu("Search")
  M2:AddOption("Researcher", function()
    Derma_StringRequest(
      "Research DB | Search by Researcher", 
      "Please enter the name of the researcher!",
      "Dr. Hustensaft",
      function(text)
        lresearch_searchid = 2
        lresearch_searchtext = text
        net.Start("luctus_research_getall")
          net.WriteInt(lresearch_page,32)
          net.WriteInt(lresearch_searchid,4)
          net.WriteString(lresearch_searchtext)
        net.SendToServer()
      end,
      function(text) end
    )
  end):SetIcon("icon16/user.png")
  
  M2:AddOption("Summary", function()
    Derma_StringRequest(
      "Research DB | Search by Summary", 
      "Please enter the text that the summary should contain!",
      "SCP",
      function(text)
        lresearch_searchid = 1
        lresearch_searchtext = text
        net.Start("luctus_research_getall")
          net.WriteInt(lresearch_page,32)
          net.WriteInt(lresearch_searchid,4)
          net.WriteString(lresearch_searchtext)
        net.SendToServer()
      end,
      function(text) end
    )
  end):SetIcon("icon16/text_allcaps.png")
  
  M2:AddOption("Reset", function()
    lresearch_searchid = 0
    lresearch_searchtext = ""
    net.Start("luctus_research_getall")
      net.WriteInt(lresearch_page,32)
      net.WriteInt(lresearch_searchid,4)
      net.WriteString(lresearch_searchtext)
    net.SendToServer()
  end):SetIcon("icon16/arrow_rotate_anticlockwise.png")
  
  local M3 = MenuBar:AddMenu("Settings")
  M3:AddOption("Refresh", function()
    net.Start("luctus_research_getall")
      net.WriteInt(lresearch_page,32)
    net.SendToServer()
  end):SetIcon("icon16/arrow_rotate_clockwise.png")
  M3:AddOption("Paper Template", function()
    luctusOpenHelpWindow()
  end):SetIcon("icon16/help.png")
  
  lresearch_list = lresearch:Add("DListView")
  lresearch_list:Dock(FILL)
  lresearch_list:SetMultiSelect( false )
  lresearch_list:AddColumn("ID"):SetWidth(20)
  lresearch_list:AddColumn("Date"):SetWidth(120)
  lresearch_list:AddColumn("Researcher"):SetWidth(150)
  lresearch_list:AddColumn("Summary"):SetWidth(500)
  function lresearch_list:DoDoubleClick( lineID, line )
    if not tonumber(line:GetColumnText(1)) then return end
    net.Start("luctus_research_getid")
      net.WriteInt(tonumber(line:GetColumnText(1)),32)
      net.WriteBool(false)
    net.SendToServer()
  end
  
  local bottomPanel = vgui.Create("DPanel",lresearch)
  bottomPanel:Dock(BOTTOM)
  bottomPanel:SetPaintBackground(false)
  button = vgui.Create("DButton",bottomPanel)
  button:Dock(RIGHT)
  button:SetText(">")
  function button:DoClick()
    lresearch_page = lresearch_page + 1
    net.Start("luctus_research_getall")
      net.WriteInt(lresearch_page,32)
      net.WriteInt(lresearch_searchid,4)
      net.WriteString(lresearch_searchtext)
    net.SendToServer()
  end
  
  local button = vgui.Create("DButton",bottomPanel)
  button:Dock(RIGHT)
  button:SetText("<")
  function button:DoClick()
    lresearch_page = lresearch_page - 1
    if lresearch_page < 0 then lresearch_page = 0 end
    net.Start("luctus_research_getall")
      net.WriteInt(lresearch_page,32)
      net.WriteInt(lresearch_searchid,4)
      net.WriteString(lresearch_searchtext)
    net.SendToServer()
  end

end

--rowid,date,researcher,summary,fulltext
function luctusOpenPaperWindow(tab)
  local mainFrame = vgui.Create("DFrame")
  mainFrame:SetTitle("Research DB | Paper #"..(tab and tab.rowid or "X"))
  mainFrame:SetSize(400,600)
  mainFrame:Center()
  mainFrame:MakePopup()
  mainFrame.rowid = tab and tab.rowid or nil
  
  local summaryLabel = vgui.Create("DLabel",mainFrame)
  summaryLabel:Dock(TOP)
  summaryLabel:SetText("Summary")
  local summaryText = vgui.Create("DTextEntry",mainFrame)
  summaryText:Dock(TOP)
  summaryText:SetDrawLanguageID(false)
  summaryText:SetPlaceholderText("Put your short summary here")
  summaryText:SetText(tab and tab.summary or "")
  
  local nameLabel = vgui.Create("DLabel",mainFrame)
  nameLabel:Dock(TOP)
  nameLabel:SetText("Researcher Name")
  local nameText = vgui.Create("DTextEntry",mainFrame)
  nameText:Dock(TOP)
  nameText:SetDrawLanguageID(false)
  nameText:SetPlaceholderText("Put your own name here")
  nameText:SetText(tab and tab.researcher or "")
  
  local descLabel = vgui.Create("DLabel",mainFrame)
  descLabel:Dock(TOP)
  descLabel:SetText("Content")
  local descText = vgui.Create("DTextEntry",mainFrame)
  descText:Dock(FILL)
  descText:SetDrawLanguageID(false)
  descText:SetMultiline(true)
  descText:SetPlaceholderText("")
  descText:SetText(tab and tab.fulltext or "")
  
  if tab and tab.rowid and not tab.edit then return end
  local saveButton = vgui.Create("DButton",mainFrame)
  saveButton:SetText("SAVE PAPER")
  saveButton:Dock(BOTTOM)
  function saveButton:DoClick()
    if summaryText:GetText() == "" or nameText:GetText() == "" or descText:GetText() == "" then
      Derma_Message("Please fill in every field!", "Research DB | error", "OK")
      return
    end
    if tab and tab.edit then
      net.Start("luctus_research_editid")
      net.WriteInt(tab.rowid,32)
    else
      net.Start("luctus_research_save")
    end
      net.WriteString(summaryText:GetText())
      net.WriteString(nameText:GetText())
      local a = util.Compress(descText:GetText())
      net.WriteInt(#a,17)
      net.WriteData(a,#a)
    net.SendToServer()
    mainFrame:Close()
    timer.Simple(0.1,function()
      net.Start("luctus_research_getall")
        net.WriteInt(lresearch_page,32)
      net.SendToServer()
    end)
  end
end

function luctusOpenHelpWindow()
  local mainFrame = vgui.Create("DFrame")
  mainFrame:SetTitle("Research DB | Template")
  mainFrame:SetSize(400,500)
  mainFrame:Center()
  mainFrame:MakePopup()
  
  local mainText = vgui.Create("DTextEntry",mainFrame)
  mainText:Dock(FILL)
  mainText:SetDrawLanguageID(false)
  mainText:SetMultiline(true)
  mainText:SetText([[
Summary: Testing if tears will work like blinking with SCP173
Content:

Researcher: Dr. Hustensaft
Test-Subject: SCP173
Duration of contact with Test-Subject: 10min

Tested with: 1 D-Class Personell
Names: 
  Peter Peterovsky

Goal:
Verify if tears and the resulting blurry vision enable SCP173 to move, even if the subject doesn't blink.

Preperation:
One D-Class subject was picked randomly and has been carefully moved into the cell of SCP173.

Execution:
Peter Peterovsky, the D-Class Personell, was forced to cry and was alone with SCP173 for 10 minutes.

Result:
The D-Class Personell survived the test and said that SCP173 couldn't move, no matter how many tears were in his eyes.
The tester, Peter Peterovsky, was released and is save again.

-Hustensaft
  ]])
  
end

print("[luctus_research] Loaded CL!")
