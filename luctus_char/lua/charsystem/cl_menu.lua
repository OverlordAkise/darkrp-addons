--Luctus Charsystem
--Made by OverlordAkise

local BgFrame = nil

net.Receive("CharacterSystemOpenMenu", function()
  local CharTable = net.ReadTable()
  LuctusChar.OpenCharMenu(CharTable)
end)


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


function LuctusChar.DeleteCharMenuOpen(slot,name)
  if not IsValid(BgFrame) then return end
  
  local DeleteWindow = vgui.Create( "DFrame", BgFrame)
  DeleteWindow:SetPos(ScrW()/2 - 200, ScrH()/2 - 100)
  DeleteWindow:SetSize(400, 200)
  DeleteWindow:SetTitle("Please enter your name")
  DeleteWindow:SetDraggable(true)
  DeleteWindow:ShowCloseButton(false)
  function DeleteWindow.Paint(self, w, h)
    DrawBlur( self , 3 )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175) )
    draw.RoundedBox( 0 , 0 , 0 , w , 20 , Color( 0 , 0 , 0 , 190 ) )
    draw.SimpleText("Really delete this character?", "Trebuchet24", w/2, h/2 - 30, Color(255,0,0,155), TEXT_ALIGN_CENTER)
    draw.SimpleText(name, "Trebuchet24", w/2, h/2, color_white, TEXT_ALIGN_CENTER)
  end

  local CloseButton = vgui.Create("DButton", DeleteWindow)
  CloseButton:SetPos(380 ,0)
  CloseButton:SetSize(20, 20)
  CloseButton:SetFont("Trebuchet18")
  CloseButton:SetText("X")
  function CloseButton.Paint(self,w,h) end
  function CloseButton.DoClick()
    DeleteWindow:Close()
  end

  local YesButton = vgui.Create("DButton", DeleteWindow)
  YesButton:SetText("Yes")
  YesButton:SetSize(100,20)
  YesButton:SetPos(300,170)
  YesButton:SetFont("Trebuchet18")
  function YesButton.Paint(self,w,h)
  end

  function YesButton.DoClick()
    surface.PlaySound("buttons/button16.wav")
    net.Start("LuctusCharDeleteProfile")
      net.WriteUInt(slot, 8)
    net.SendToServer()
    DeleteWindow:Close()
    --surface.PlaySound( "buttons/combine_button1.wav" )
  end
  
  local NoButton = vgui.Create("DButton", DeleteWindow)
  NoButton:SetText("No")
  NoButton:SetSize(100,20)
  NoButton:SetPos(0,170)
  NoButton:SetFont("Trebuchet18")
  function NoButton.Paint(self,w,h)
  end

  function NoButton.DoClick()
    surface.PlaySound( "buttons/combine_button1.wav" )
    DeleteWindow:Close()
  end
end


function LuctusChar.NameInputMenuOpen(slot)
  if not IsValid(BgFrame) then return end
  local NameError = ""
  local NameInput = vgui.Create( "DFrame", BgFrame)
  NameInput:SetPos(ScrW()/2 - 200, ScrH()/2 - 100)
  NameInput:SetSize(400, 200)
  NameInput:SetTitle("Please enter your name")
  NameInput:SetDraggable(true)
  NameInput:ShowCloseButton(false)
  function NameInput.Paint(self, w, h)
    DrawBlur( self , 3 )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175) )
    draw.RoundedBox( 0 , 0 , 0 , w , 20 , Color( 0 , 0 , 0 , 190 ) )
    draw.SimpleText(NameError, "Trebuchet18", w/2, h-50, Color(255,0,0,155), TEXT_ALIGN_CENTER)
  end


  local CloseButton = vgui.Create("DButton", NameInput)
  CloseButton:SetPos(380 ,0)
  CloseButton:SetSize(20, 20)
  CloseButton:SetFont("Trebuchet18")
  CloseButton:SetText("X")
  function CloseButton.Paint(self,w,h) end
  function CloseButton.DoClick()
    NameInput:Close()
  end
  
  local NameEntry = vgui.Create( "DTextEntry", NameInput )
  NameEntry:SetPos(100, NameInput:GetTall()/2-10)
  NameEntry:SetSize(200,20)
  NameEntry:SetDrawLanguageID(false)
  local NameOkay
  function NameEntry.OnChange() -- Same as DarkRP Namecheck function
    local NameText = NameEntry:GetValue()
    if(not NameText or string.Trim(NameText) == "") then 
      NameError = "Name is empty!"
      return 
    end
    if(string.len(NameText) < 2) then
      NameError = "Name is too short!"
      return
    end
    if(string.len(NameText) > 31) then
      NameError = "Name is too long!"
      return
    end
    if(not string.match(NameText, "^[a-zA-ZЀ-џ0-9 ]+$")) then
      NameError = "Forbidden characters in name!"
      return
    end
    NameError = ""
  end

  local AcceptButton = vgui.Create("DButton", NameInput)
  AcceptButton:SetText("Create")
  AcceptButton:SetSize(100,20)
  AcceptButton:SetPos(300,170)
  AcceptButton:SetFont("Trebuchet24")
  function AcceptButton.Paint(self,w,h)
  end

  function AcceptButton.DoClick()
    if(NameError == "") then
      net.Start("LuctusCharCreateProfile")
        net.WriteUInt(slot, 8)
        net.WriteString(NameEntry:GetValue())
      net.SendToServer()
      surface.PlaySound("buttons/button16.wav")
      NameInput:Close()
    else
      surface.PlaySound( "buttons/combine_button1.wav" )
    end
  end
end


function LuctusChar.OpenCharMenu(CharTable)
  if(IsValid(BgFrame)) then BgFrame:Close() end
  BgFrame = vgui.Create( "DFrame" )
  BgFrame:SetSize( ScrW() , ScrH() )
  BgFrame:SetPos( 0 , 0 )
  BgFrame:SetDraggable( false )
  BgFrame:ShowCloseButton( false )
  BgFrame:MakePopup()
  function BgFrame:Paint(w, h)
		DrawBlur( self , 5 )
    draw.RoundedBox(0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175 ))
	end
  function BgFrame:OnKeyCodePressed( keyCode ) 
		if (keyCode == 93) then --if F2 pressed
      self:Close()
    end
	end


  local TopPanel = vgui.Create( "DPanel" , BgFrame ) -- left sided panel
  TopPanel:SetPos( 0 , 0 )
  TopPanel:SetSize( ScrW(), 60)
  TopPanel.Paint = function( self , w , h )
    DrawBlur( self , 3 )
    draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 100 ) )
  end



  local WelcomeText = vgui.Create("DLabel", BgFrame)
  surface.SetFont("DermaLarge")
  local x,y = surface.GetTextSize(LuctusChar.Config.WelcomeMessage)
  WelcomeText:SetPos((ScrW()/2)-(x/2), 100)
  WelcomeText:SetSize(ScrW(), 50)
  WelcomeText:SetText( LuctusChar.Config.WelcomeMessage )
  WelcomeText:SetFont( "DermaLarge" )


  local firstButtonPadding = (ScrW()/2)-((#LuctusChar.Config.CustomButtons*75))
  for k,v in pairs(LuctusChar.Config.CustomButtons) do
    local CustomButton = vgui.Create( "DButton" , TopPanel ) -- 1st Custom Button
    CustomButton:SetPos(firstButtonPadding+((k-1)*5)+((k-1)*150), 0)
    CustomButton:SetSize( 150 , 60 )
    CustomButton:SetText( v[1] )
    CustomButton:SetFont( "Trebuchet24" )
    function CustomButton.Paint( self , w , h )
      DrawBlur( self , 3 )
      draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175 ) )
    end
    function CustomButton.DoClick()
      gui.OpenURL( v[2] )
    end
  end
  
  
  local PanelPosi = {
    {0.052, 0.277},
    {0.364, 0.277},
    {0.677, 0.277}
  }
  
  for k,v in pairs(PanelPosi) do
    local px = ScrW() * 0.260
    local py = ScrH() * 0.555
    local character = CharTable[k]
    if not character then character = {} end
    
    local CharPanel = vgui.Create( "DPanel" , BgFrame ) -- char 1 panel
    CharPanel:SetPos( ScrW() * v[1] , ScrH()* v[2])
    CharPanel:SetSize( px , py )
    CharPanel.Paint = function( self , w , h )
      DrawBlur( self , 3 )
      draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175 ) )
      draw.RoundedBox(0,0,0,w,h*0.2,Color(0,0,0,190))
    end
    local CharModelPan = vgui.Create( "DModelPanel" , CharPanel ) -- char 1 model preview
    CharModelPan:SetPos( 0 , py*0.15 )
    CharModelPan:SetSize( px , py*0.7 )
    
    local jobcmd = character.job
    local jobmodel = ""
    
    for k,v in pairs(RPExtraTeams) do
      if v.command == jobcmd then
        if(istable(v.model))then
          jobmodel = v.model[1]
        else
          jobmodel = v.model
        end
      end
    end
    if(CharModelPan:GetModel() != jobmodel) then
      CharModelPan:SetModel(jobmodel)
    end


    local CharName1Label = vgui.Create( "DLabel" , CharPanel )
    CharName1Label:SetPos( 0 , py*0.03 )
    CharName1Label:SetContentAlignment(5)
    CharName1Label:SetFont( "DermaLarge" )

    CharName1Label:SetSize( CharPanel:GetWide() , ScrH() * 0.046 )
    CharName1Label:SetText( character.name or "Empty" )

    local Char1JobLabel = vgui.Create( "DLabel" , CharPanel ) -- 1st Character Name
    Char1JobLabel:SetPos( 0 , py*0.1 )
    Char1JobLabel:SetContentAlignment(5)
    Char1JobLabel:SetFont( "Trebuchet24" )
    Char1JobLabel:SetSize( px , 30 )
    Char1JobLabel:SetText(team.GetName(tonumber(character.job)) or "")
    
    if(character.name) then
      local CharDeleteButton = vgui.Create( "DButton" , CharPanel )
      CharDeleteButton:SetPos( CharPanel:GetWide() - 33, 0)
      CharDeleteButton:SetSize( 30 , 30 )
      CharDeleteButton:SetText("delete")
      function CharDeleteButton.DoClick()
        LuctusChar.DeleteCharMenuOpen(k,character.name)
      end
      function CharDeleteButton.Paint() end
    end

    local CharPlay = vgui.Create( "DButton" , CharPanel )
    CharPlay:SetPos( 0 , CharPanel:GetTall() - ScrH() * 0.074)
    CharPlay:SetSize( ScrW() * 0.260 , ScrH() * 0.074 )
    CharPlay:SetFont( "Trebuchet24" )
    CharPlay.Paint = function( self , w , h )
      draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 120 ) )
    end
    if(character.playing) then
      CharPlay:SetText( "Currently playing!" )
    elseif not character.name then
      CharPlay:SetText( "Create new character!" )
    elseif character.name then
      CharPlay:SetText( "Play this character!" )
    end
    function CharPlay.DoClick()
      if not character.name then
        LuctusChar.NameInputMenuOpen(k)
      elseif(character.name and not character.playing) then
        net.Start("LuctusCharPlayProfile")
          net.WriteUInt(k, 8)
        net.SendToServer()
        BgFrame:Close()
      end
      
    end
  
  end
  
end

net.Receive("ColorMessage",function(len,ply)
  local ColorMessageTable = net.ReadTable()
  if (!istable(ColorMessageTable)) then return end
  chat.AddText(unpack(ColorMessageTable))
end)



