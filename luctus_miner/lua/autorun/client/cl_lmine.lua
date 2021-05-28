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

net.Receive("luctus_mine_craft",function()
  if IsValid(MineCraftPanel) then return end
  MineCraftPanel = vgui.Create("DFrame")
  MineCraftPanel:SetSize(700, 400)
  MineCraftPanel:Center()
  MineCraftPanel:SetTitle("")
  MineCraftPanel:SetDraggable(false)
  MineCraftPanel:ShowCloseButton(false)
  MineCraftPanel:MakePopup()
  MineCraftPanel.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(0,0,0,255))
    draw.RoundedBox(2, 1, 1, w-2, h-2, Color(150,150,150,255))
    draw.RoundedBox(0, 0, 0, w, 30, Color(0,0,0,240))
    draw.SimpleText("Crafting Table", "DermaLarge", w/2, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  
  local parent_x, parent_y = MineCraftPanel:GetSize()
  
  local CloseButton = vgui.Create( "DButton", MineCraftPanel )
  CloseButton:SetText( "X" )
  CloseButton:SetPos( parent_x-30, 1 )
  CloseButton:SetSize( 29, 29 )
  CloseButton.DoClick = function()
    MineCraftPanel:Close()
  end
  CloseButton.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(255,10,10,255))
  end
  
  local DScrollPanel = vgui.Create( "DScrollPanel", MineCraftPanel )
  DScrollPanel:SetPos(0,33)
  DScrollPanel:SetSize(parent_x-2,parent_y-35)
  DScrollPanel.Paint = function(w, h)
    --draw.RoundedBox
  end
  
  
  for k,v in pairs(luctus.mine.craftables) do
    k = k - 1
    local button = DScrollPanel:Add( "DButton" )
    button:SetPos( 5, 35*k )
    button:SetText("")
    button.Paint = function(self,w,h)
      draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255))
      draw.DrawText("Craft","Default",w/2,5,Color(0,0,0,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
    end
    button.DoClick = function()
      net.Start("luctus_mine_craft")
        net.WriteString(v["Entity"])
      net.SendToServer()
    end
    
    local label = DScrollPanel:Add( "DLabel" )
    label:SetColor(Color(0,0,0,255))
    label:SetPos(0, 35*k-2)
    label:SetSize(700,50)
    label:SetContentAlignment(4) --middle-left
    label:SetText("")--v["Entity"])
    label.Paint = function(self,w,h)
      --draw.RoundedBox(0,0,0,w,25,Color(255,255,255,255))
      draw.DrawText(v["Entity"],"Trebuchet24",85,0,Color(0,0,0,255))
      draw.RoundedBox(0,0,30,698,1,Color(0,0,0,255))
    end
    
    local rLabel = DScrollPanel:Add( "DLabel" )
    rLabel:SetColor(Color(0,0,0,255))
    rLabel:SetPos(300, 35*k-2)
    rLabel:SetSize(300,30)
    rLabel:SetContentAlignment(4) --middle-left
    local rText = ""
    for k,vv in pairs(v) do
      if k ~= "Entity" then
        rText = rText .. " " .. k .. " " .. vv .. " ,"
      end
    end
    rText = string.sub(rText,1,#rText-1)
    rLabel:SetText("")
    rLabel.Paint = function(self,w,h)
      draw.RoundedBox(0,0,h,w,h+1,Color(255,255,255,255))
      draw.DrawText(rText,"Trebuchet24",0,3,Color(0,0,0,255))
    end
    
    
  end
end)


function luctusNPCMenu()
  if IsValid(MineNPCPanel) then return end
  local npc = net.ReadEntity()
  MineNPCPanel = vgui.Create("DFrame")
  MineNPCPanel:SetSize(300, 300)
  MineNPCPanel:Center()
  MineNPCPanel:SetTitle("")
  MineNPCPanel:SetDraggable(false)
  MineNPCPanel:ShowCloseButton(false)
  MineNPCPanel:MakePopup()
  MineNPCPanel.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, Color(0,0,0,255))
    draw.RoundedBox(2, 1, 1, w-2, h-2, Color(150,150,150,255))
    draw.RoundedBox(0, 0, 0, w, 30, Color(0,0,0,240))
    --surface.DrawOutlinedRect( number x, number y, number w, number h, number thickness )
    draw.SimpleText("NPC - Sell Ores", "DermaLarge", w/2-10, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  
  local parent_x, parent_y = MineNPCPanel:GetSize()
  
  local CloseButton = vgui.Create( "DButton", MineNPCPanel )
  CloseButton:SetText( "X" )
  CloseButton:SetPos( parent_x-30, 0 )
  CloseButton:SetSize( 30, 30 )
  CloseButton.DoClick = function()
    MineNPCPanel:Close()
  end
  CloseButton.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 1, w-1, h, Color(255,10,10,255))
  end
  
  local DScrollPanel = vgui.Create( "DScrollPanel", MineNPCPanel )
  DScrollPanel:SetPos(0,30)
  DScrollPanel:SetSize(parent_x,parent_y-30)
  DScrollPanel.Paint = function(w, h)
    --draw.RoundedBox
  end
  
  
  for k,v in pairs(luctus.mine.ores) do
    local button = DScrollPanel:Add( "DButton" )
    button:SetPos( 5, 25*k )
    button:SetColor(v["Color"])
    button:SetText(v["Name"])
    button.Paint = function(self,w,h)
      --draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255))
    end
    
    local numTextField = DScrollPanel:Add( "DTextEntry" )
    numTextField:SetPos( 85, 25*k )
    numTextField:SetPlaceholderText(""..LocalPlayer():GetNWInt("ore_"..v["Name"],0).."")
    
    local buttonMoney = DScrollPanel:Add( "DLabel" )
    buttonMoney:SetPos( 160, 25*k )
    buttonMoney:SetColor(Color(0,0,0,255))
    buttonMoney:SetText("x "..npc:GetNWInt("sOre_"..v["Name"],0).."$")
    buttonMoney.Paint = function(self,w,h)
      --draw.RoundedBox(0,0,0,w,h,Color(255,255,255,255))
    end
    
    local sellButton = DScrollPanel:Add( "DButton" )
    sellButton:SetPos( 220, 25*k )
    sellButton:SetText("Sell")
    sellButton.textfield = numTextField
    sellButton.DoClick = function()
      local text = sellButton.textfield:GetValue()
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
  local pickaxeButton = DScrollPanel:Add( "DButton" )
  pickaxeButton:SetPos( 75, 25*(#luctus.mine.ores + 1) )
  pickaxeButton:SetSize(150,25)
  pickaxeButton:SetText("Gib mir eine Spitzhacke!")
  pickaxeButton.DoClick = function()
    net.Start("luctus_get_pickaxe")
    net.SendToServer()
    MineNPCPanel:Close()
  end
  
end

print("[luctus_minesystem] CL file loaded!")
