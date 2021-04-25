--Lucid MOTD
--Original by Mjctechguy (MjcMOTD)
--Refactored, Reformated and Fixes by OverlordAkise
--Code looked like ass tbh

------------------
-- Config Start --
------------------

emotd_textcolor = Color(255,255,255)
emotd_button_color = Color(36,36,36)
emotd_button_color_hover = Color(158, 163, 168)
emotd_background = Color(44, 62, 80)

emotd_command = "!motd"
emotd_start_link = "https://eternitycommunity.mistforums.com/"
emotd_servername = "Welcome to "..GetHostName()

--The URLs need to be EXACT! Copy them from your browser URL bar
emotd_buttons = {
  ["Steam Group"] = "https://eternitycommunity.mistforums.com/",
  ["Forum"] = "https://eternitycommunity.mistforums.com/",
  ["Rules"] = "https://eternitycommunity.mistforums.com/thread/rules--080121-663088",
  ["Donate"] = "https://eternitycommunity.mistforums.com/donate",
}


----------------
-- Config End --
----------------



surface.CreateFont("emotd_font", {
  font = "Roboto",
  size = 20,
  weight = 5,
  blursize = 0,
  scanlines = 0,
  antialias = true,
})

emotd_frame = nil
function eMOTD()
  emotd_frame = vgui.Create("DFrame")
  emotd_frame:SetSize(ScrW()-50, ScrH()-50)
  emotd_frame:Center()
  emotd_frame:SetTitle("MOTD")
  emotd_frame:SetDraggable(false)
  --emotd_frame:ShowCloseButton(false)
  emotd_frame:MakePopup()
  emotd_frame.Paint = function( self, w, h )
    Derma_DrawBackgroundBlur( self, self.startTime )
  end
  emotd_frame.OnClose = function(self)
    gui.EnableScreenClicker(false)
  end
  
  
  local emotd_main = vgui.Create("DPanel", emotd_frame)
  emotd_main:SetSize(ScrW()-50, ScrH()-50)
  emotd_main:SetPos(100,100)
  emotd_main:Dock(FILL)
  emotd_main.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, emotd_textcolor )
  end

  --Left Frame
  local emotd_left = vgui.Create("DPanel", emotd_main)
  emotd_left:SetSize(300, ScrH()-50)
  emotd_left:Dock(LEFT)
  emotd_left.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, emotd_background )
  end


  local emotd_user = vgui.Create("DPanel", emotd_left)
  emotd_user:SetSize(300, 84)
  emotd_user:Dock(TOP)
  emotd_user.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, emotd_background )
  end
  --Avatar
  local emotd_avatar = vgui.Create("AvatarImage", emotd_user)
  emotd_avatar:SetPlayer(LocalPlayer(), 84)
  emotd_avatar:SetSize(84,84)
  emotd_avatar:Dock(LEFT)
  --Steam Name
  local emotd_username = vgui.Create("DLabel", emotd_user)
  emotd_username:SetText(LocalPlayer():GetName())
  emotd_username:SetFont("DermaLarge")
  emotd_username:SetSize(300,300)
  emotd_username:Dock(LEFT)
  emotd_username:DockMargin(10,0,0,0)
  --Server Current Map
  local emotd_leftSM = vgui.Create("DLabel", emotd_left)
  emotd_leftSM:SetSize(250, emotd_left:GetTall()/30)
  emotd_leftSM:Dock(TOP)
  emotd_leftSM:SetContentAlignment( 4 )
  emotd_leftSM:SetText("Map: "..game.GetMap())
  emotd_leftSM:SetFont("DermaLarge")
  --Server Current Players
  local emotd_leftPC = vgui.Create("DLabel", emotd_left)
  emotd_leftPC:SetSize(250, emotd_left:GetTall()/30)
  emotd_leftPC:Dock(TOP)
  emotd_leftPC:SetContentAlignment( 4 )
  emotd_leftPC:SetText("Players: "..#player.GetAll().."/"..game.MaxPlayers())
  emotd_leftPC:SetFont("DermaLarge")
  --Left Frame
  local emotd_leftButtons = vgui.Create("DScrollPanel", emotd_left)
  emotd_leftButtons:Dock(FILL)
  emotd_leftButtons.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, emotd_background )
  end
  local emotd_html = vgui.Create("DHTML", emotd_main)
  emotd_html:Dock(FILL)
  emotd_html:OpenURL(emotd_start_link)

  --Add the close button here so that people don't accidently remove it
  emotd_buttons["Close"] = function() emotd_frame:Close() end
  for k, v in SortedPairs(emotd_buttons,true) do
    local emotd_button = vgui.Create("DButton", emotd_leftButtons)
    emotd_button:SetSize(250, emotd_left:GetTall()/9)
    emotd_button:Dock(TOP)
    emotd_button:DockMargin(0,0,0,5)
    emotd_button:SetText(k)
    emotd_button:SetColor(emotd_textcolor)
    emotd_button.bcolor = emotd_button_color
    emotd_button:SetFont("DermaLarge")
    emotd_button.Paint = function( self, w, h )
      draw.RoundedBox(0, 0, 0, w, h, self.bcolor)
    end
    function emotd_button:OnCursorEntered()
      self.bcolor = emotd_button_color_hover
    end
    function emotd_button:OnCursorExited()
      self.bcolor = emotd_button_color
    end
    emotd_button.DoClick = function()
      if type(v) == "string" then
        print("OPENING URL: "..v)
        emotd_html:OpenURL(v)
      else
        v()
      end
    end
  end


 local emotd_message = vgui.Create("DPanel", emotd_main)
  emotd_message:Dock(TOP)
  emotd_message:SetSize(ScrW()-50, 40)
  emotd_message.Paint = function( self, w, h )
    draw.RoundedBox( 0, 0, 0, w, h, emotd_background )
    draw.DrawText(emotd_servername,"DermaLarge",0,5,emotd_textcolor,TEXT_ALIGN_LEFT)
  end
end

hook.Add("InitPostEntity", "emotd_start", function()
  eMOTD()
  gui.EnableScreenClicker(true)
end)

hook.Add("OnPlayerChat", "emotd_chat", function(ply, text)
  if ply == LocalPlayer() then
    if text == emotd_command then
      eMOTD()
      gui.EnableScreenClicker(true)
    end
  end
end)

concommand.Add("emotd", function( ply )
  eMOTD()
  gui.EnableScreenClicker(true)
end)