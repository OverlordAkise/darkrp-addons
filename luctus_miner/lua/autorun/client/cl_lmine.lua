--Luctus Mining System
--Made by OverlordAkise

function luctusMineHUD()
  local text = ""
  surface.SetFont("DermaLarge")
  local tW, tH = surface.GetTextSize(text)
  surface.SetDrawColor(Color(0,0,0,200))
  surface.DrawRect(ScrW()/2+50, ScrH()-110, 5 + #luctus.mine.ores * 55, 50)
  for k,v in pairs(luctus.mine.ores) do
    surface.SetTextColor(v["Color"])
    surface.SetTextPos(ScrW()/2+k*55, ScrH()-100)
    surface.DrawText(LocalPlayer():GetNWInt("ore_"..v["Name"],0),TEXT_ALIGN_RIGHT)
  end
end


hook.Add("OnPlayerChangedTeam","luctus_mine_config",function(ply, numBefore, numAfter)
  local nam = TEAM_DKLASSE or -1
  if nam ~= -1 then
    if numBefore == nam then
      hook.Remove("HUDPaint","luctus_mine_hud")
    end
    if numAfter == nam then
      hook.Add("HUDPaint","luctus_mine_hud",luctusMineHUD)
    end
  end
end)

hook.Add("OnContextMenuOpen","luctus_mine_hud_on",function()
  hook.Add("HUDPaint","luctus_mine_hud",luctusMineHUD)
end)

hook.Add("OnContextMenuClose","luctus_mine_hud_off",function()
  hook.Remove("HUDPaint","luctus_mine_hud")
end)

  
net.Receive("luctus_mine_npc",function()
  luctusNPCMenu()
end)

--TODO: Translator for nice names

net.Receive("luctus_mine_craft",function()
  if IsValid(MineCraftPanel) then return end
  MineCraftPanel = vgui.Create("DFrame")
  MineCraftPanel:SetSize(700, 400)
  MineCraftPanel:Center()
  MineCraftPanel:SetTitle("Crafting Table")
  MineCraftPanel:SetDraggable(true)
  MineCraftPanel:ShowCloseButton(true)
  MineCraftPanel:MakePopup()
  MineCraftPanel.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(0,0,0,253))
    draw.RoundedBox(0, 0, 0, w, 23, Color(139,0,0,255))
  end
  
  local parent_x, parent_y = MineCraftPanel:GetSize()
  
  local DScrollPanel = vgui.Create( "DScrollPanel", MineCraftPanel )
  DScrollPanel:Dock(FILL)
  
  
  for k,v in pairs(luctus.mine.craftables) do
    local row = DScrollPanel:Add("DPanel")
    row:Dock(TOP)
    row:SetPaintBackground(false)
    row:DockMargin(0,10,0,0)
    
    local label = vgui.Create("DLabel",row)
    label:Dock(LEFT)
    --label:SetFont("Trebuchet24")
    label:SetSize(200,25)
    label:DockMargin(20,0,0,0)
    label:SetText(v["Entity"])
    
    local rLabel = vgui.Create("DLabel",row)
    rLabel:Dock(LEFT)
    rLabel:SetSize(200,25)
    local rText = ""
    for kk,vv in pairs(v) do
      if kk ~= "Entity" then
        rText = rText .. " " .. kk .. " " .. vv .. " ,"
      end
    end
    rText = string.sub(rText,1,#rText-1)
    rLabel:SetText(rText)
    
    local button = vgui.Create("DButton",row)
    button:Dock(RIGHT)
    button:SetText("Craft")
    button:DockMargin(10,0,20,0)
    button.DoClick = function()
      net.Start("luctus_mine_craft")
        net.WriteString(v["Entity"])
      net.SendToServer()
    end
    
  end
end)


function luctusNPCMenu()
  if IsValid(MineNPCPanel) then return end
  local npc = net.ReadEntity()
  MineNPCPanel = vgui.Create("DFrame")
  MineNPCPanel:SetSize(700, 400)
  MineNPCPanel:Center()
  MineNPCPanel:SetTitle("NPC - Sell Ores")
  MineNPCPanel:SetDraggable(true)
  MineNPCPanel:ShowCloseButton(true)
  MineNPCPanel:MakePopup()
  MineNPCPanel.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(0,0,0,253))
    draw.RoundedBox(0, 0, 0, w, 23, Color(139,0,0,255))
  end
  --]]
  local parent_x, parent_y = MineNPCPanel:GetSize()
  --[[
  local CloseButton = vgui.Create( "DButton", MineNPCPanel )
  CloseButton:SetText("X")
  CloseButton:SetPos( parent_x-30, 0 )
  CloseButton:SetSize( 30, 30 )
  CloseButton.DoClick = function()
    MineNPCPanel:Close()
  end
  CloseButton.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 1, w-1, h, Color(255,10,10,255))
  end
  --]]
  local DScrollPanel = vgui.Create( "DScrollPanel", MineNPCPanel )
  DScrollPanel:Dock(FILL)
  
  
  for k,v in pairs(luctus.mine.ores) do
    local row = DScrollPanel:Add("DPanel")
    --row:Dock(TOP)
    row:SetPos(0,(k-1)*25)
    row:SetSize(700,25)
    row:SetPaintBackground(false)
    
    local rowX, rowY = row:GetSize()
    
    local oreName = vgui.Create("DLabel",row)
    oreName:SetPos(20,3)
    oreName:SetColor(v["Color"])
    oreName:SetText(v["Name"])

    local oreSlider = vgui.Create("DNumSlider",row)
    oreSlider:SetPos(120,0)
    oreSlider:SetSize(400,25)	
    oreSlider:SetText(v["Name"])
    oreSlider:SetMin(0)
    oreSlider:SetMax(LocalPlayer():GetNWInt("ore_"..v["Name"],0))
    oreSlider:SetDecimals()
    oreSlider:SetDark(false)
    oreSlider:GetTextArea():SetDrawLanguageID(false)
    oreSlider:GetChildren()[3]:SetSize(0,0)
    oreSlider:GetChildren()[3]:Dock(NODOCK) -- Remove stupid label on the left

    local sellValueLabel = vgui.Create("DLabel",row)
    sellValueLabel:SetPos(530,3)
    sellValueLabel:SetText("x "..npc:GetNWInt("sOre_"..v["Name"],0).."$")  
    
    local sellButton = vgui.Create("DButton",row)
    sellButton:SetPos(600,2)
    sellButton:SetText("Sell")
    sellButton.textfield = numTextField
    sellButton.DoClick = function()
      local text = oreSlider:GetValue()
      local num = 0
      if text == "" then
        num = LocalPlayer():GetNWInt("ore_"..v["Name"],0)
      else
        num = tonumber(text)
      end
      net.Start("luctus_mine_npc")
        net.WriteInt(num,16)
        net.WriteString(v["Name"])
        net.WriteEntity(npc)
      net.SendToServer()
    end
  end

  local pickaxeButton = vgui.Create("DButton",MineNPCPanel)
  pickaxeButton:Dock(BOTTOM)
  pickaxeButton:SetText("Give me a pickaxe!")
  pickaxeButton.DoClick = function()
    net.Start("luctus_get_pickaxe")
    net.SendToServer()
    MineNPCPanel:Close()
  end
  


end

print("[luctus_minesystem] CL file loaded!")
