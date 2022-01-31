--Lucid Name Change
--Made by OverlordAkise

hook.Add("InitPostEntity", "luctus_namechange_fix", function()
	net.Start("luctus_namechange")
	net.SendToServer()
end )

net.Receive("luctus_namecheck",function()
  RunConsoleCommand("say","/rpname "..net.ReadString())
  NameFrame:Close()
end)
net.Receive("luctus_namechange",function()
  if IsValid(NameFrame) then return end
  NameFrame = vgui.Create("DFrame")
  NameFrame:SetSize(500, 300)
  NameFrame:Center()
  NameFrame:SetTitle("")
  NameFrame:SetDraggable(false)
  NameFrame:ShowCloseButton(false) 
  NameFrame:MakePopup()
  NameFrame.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    draw.RoundedBox(0, 0, 0, w, 30, Color(32, 34, 37,255))
    draw.SimpleText("Welcome!", "Trebuchet24", w/2, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Please set your name", "Trebuchet24", w/2, h/2 - 100, color_white, TEXT_ALIGN_CENTER)
  end
  
  local parent_x, parent_y = NameFrame:GetSize()
    
  local fname = vgui.Create( "DTextEntry", NameFrame )
  fname:SetPos( parent_x/2 - 80, parent_y/2 - 50 ) 
  fname:SetSize( 160 , 30 )
  fname:SetPlaceholderText( "First name" ) 
  
  local lname = vgui.Create( "DTextEntry", NameFrame )
  lname:SetPos( parent_x/2 - 80, parent_y/2 - 10 ) 
  lname:SetSize( 160 , 30 ) 
  lname:SetPlaceholderText( "Last name" )
  lname.OnEnter = function( self )
    chat.AddText( self:GetValue() )	-- print the form's text as server text
  end
  
  local SetButton = vgui.Create("DButton", NameFrame)
  SetButton:SetText("")
  SetButton:SetPos(parent_x/2-40,parent_y/2 + 50)
  SetButton:SetSize(80,25)
  SetButton.DoClick = function() 
    net.Start("luctus_namecheck")
      net.WriteString(fname:GetValue())
      net.WriteString(lname:GetValue())
    net.SendToServer()
    --NameFrame:Close()
  end
  function SetButton:Paint(w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(34, 37, 42))
    if (self.Hovered) then
      draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(66, 70, 77))
    end
    draw.SimpleText("Set Name", "Trebuchet18", 0+w/2, 0+h/2-9, Color(0, 195, 165), TEXT_ALIGN_CENTER)
  end
end)