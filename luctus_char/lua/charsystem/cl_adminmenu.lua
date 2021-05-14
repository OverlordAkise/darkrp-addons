--Luctus Charsystem
--Made by OverlordAkise

local blur = Material("pp/blurscreen") -- blur Material
local function DrawBlur( panel , amount ) -- blur function
  local x , y = panel:LocalToScreen( 0 , 0 )
  local scrW , scrH = ScrW() , ScrH()
  surface.SetDrawColor( 255 , 255 , 255 )
  surface.SetMaterial(blur)
  for i = 1 , 3 do
    blur:SetFloat("$blur" , ( i / 3) * (amount or 6))
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect( x * -1 , y * -1 , scrW , scrH )
  end
end


function OpenAdminSystem(characters, steamid)
  if IsValid(AdminFrame) then return end
  local curChar = -1
  
  local AdminFrame = vgui.Create( "DFrame" )
  AdminFrame:SetTitle("User: "..steamid)
  AdminFrame:SetSize( 900 , 500 )
  AdminFrame:Center()
  AdminFrame:MakePopup()
  AdminFrame.Paint = function( self , w , h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 34, 40, 49, 255 ) )
  end
  
  local CharPanel = vgui.Create( "DPanel" , AdminFrame )
  CharPanel:SetPos( 50 , 100 )
  CharPanel:SetSize( 800 , 370 )
  function CharPanel.Paint( self , w , h )
    DrawBlur( self , 3 )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 57, 62, 70, 200 ) )
  end
  
  --Middle stuff
  local CharNameLabel = vgui.Create("DLabel", CharPanel)
  CharNameLabel:SetPos(12,10)
  CharNameLabel:SetSize(200,20)
  CharNameLabel:SetText("Name")
  local CharName = vgui.Create("DTextEntry", CharPanel)
  CharName:SetPos(10 , 33)
  CharName:SetSize(200 , 20)
  CharName:SetText("None")
  
  local CharMoneyLabel = vgui.Create("DLabel", CharPanel)
  CharMoneyLabel:SetPos(12,60)
  CharMoneyLabel:SetSize(200,20)
  CharMoneyLabel:SetText("Money")
  local CharMoney = vgui.Create("DTextEntry", CharPanel)
  CharMoney:SetPos(10, 83)
  CharMoney:SetSize(200, 20)
  CharMoney:SetText("0")
  
  local CharJob = vgui.Create("DComboBox", CharPanel)
  CharJob:SetPos(10, 110)
  CharJob:SetSize(200, 30)
  CharJob:SetFont("Trebuchet24")
  CharJob:SetValue("")
  function CharJob.Paint ( self , w , h )
    draw.RoundedBox( 0, 0, 0, w, h, Color( 181, 84, 0, 190 ) )
  end
  for k,v in pairs(RPExtraTeams) do
    CharJob:AddChoice(v.command)
  end
  
  local CharDelete = vgui.Create( "DButton" , CharPanel )
  CharDelete:SetPos( 10 , 280 )
  CharDelete:SetSize( 200 , 30 )
  CharDelete:SetText( "Delete Character" )
  CharDelete:SetFont( "Trebuchet24" )
  function CharDelete.Paint( self , w , h )
    draw.RoundedBox( 7 , 0 , 0 , w , h , Color( 255, 0, 0 , 90 ) )
  end
  function CharDelete.DoClick()
    if curChar ~= -1 then
      net.Start("AdminMenuDeleteChar")
        net.WriteUInt(curChar,8)
        net.WriteString(steamid)
      net.SendToServer()
      AdminFrame:Close()
    end
  end

  local CharSave = vgui.Create( "DButton" , CharPanel )
  CharSave:SetPos( 10 , 320 )
  CharSave:SetSize( 200 , 30 )
  CharSave:SetText( "Save Changes" )
  CharSave:SetFont( "Trebuchet24" )
  function CharSave.Paint( self , w , h )
    draw.RoundedBox( 7 , 0 , 0 , w , h , Color( 0, 255, 0 , 90 ) )
  end
  function CharSave.DoClick()
    if curChar ~= -1 then
      net.Start("AdminMenuUpdateChar")
        net.WriteString(steamid)
        net.WriteString(CharName:GetValue())
        net.WriteString(CharMoney:GetValue())
        net.WriteString(CharJob:GetValue())
        net.WriteUInt(curChar,8)
      net.SendToServer()
    end
  end
  
  --Top Buttons
  local Char1Button = vgui.Create( "DButton" , AdminFrame )
  Char1Button:SetSize( 100 , 30 )
  Char1Button:SetPos( 150 - 50 , 60 )
  Char1Button:SetText( "Slot 1" )
  Char1Button:SetFont( "Trebuchet24" )
  function Char1Button.Paint( self , w , h )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 200, 200, 200 , 255 ) )
  end
  function Char1Button.DoClick()
    CharName:SetText(characters[1] and characters[1].name or "None")
    CharMoney:SetText(characters[1] and characters[1].money or "0")
    CharJob:SetValue(characters[1] and characters[1].job or "None")
    curChar = 1
  end

  local Char2Button = vgui.Create( "DButton" , AdminFrame )
  Char2Button:SetSize( 100 , 30 )
  Char2Button:SetPos( 450 - 50 , 60 )
  Char2Button:SetText( "Slot 2" )
  Char2Button:SetFont( "Trebuchet24" )
  function Char2Button.Paint( self , w , h )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 200, 200, 200 , 255 ) )
  end
  function Char2Button.DoClick()
    CharName:SetText(characters[2] and characters[2].name or "None")
    CharMoney:SetText(characters[2] and characters[2].money or "0")
    CharJob:SetValue(characters[2] and characters[2].job or "None")
    curChar = 2
  end

  local Char3Button = vgui.Create( "DButton" , AdminFrame )
  Char3Button:SetSize( 100 , 30 )
  Char3Button:SetPos( 750 - 50 , 60 )
  Char3Button:SetText( "Slot 3" )
  Char3Button:SetFont( "Trebuchet24" )
  function Char3Button.Paint( self , w , h )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 200, 200, 200 , 255 ) )
  end
  function Char3Button.DoClick()
    CharName:SetText(characters[3] and characters[3].name or "None")
    CharMoney:SetText(characters[3] and characters[3].money or "0")
    CharJob:SetValue(characters[3] and characters[3].job or "None")
    curChar = 3
  end

end

net.Receive("LuctusCharAdminMenuOpen", function()
  local CharTable = net.ReadTable()
  local steamid = net.ReadString()
  
  OpenAdminSystem(CharTable, steamid)
end)
