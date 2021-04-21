--Lucid lcrashScreen
--by OverlordAkise

lcrash_pingFrequency = 5 --seconds
lcrash_timeout = 10 --seconds
lcrash_reconnectDelay = 60 --seconds

---------------------

lcrash_lastReceived = CurTime()
net.Receive("lucidcrash_ping", function(len)
	lcrash_lastReceived = CurTime()
  if lcrashScreen:IsVisible() then
    print("[lucidcrash] Closing CrashScreen!")

    lcrashScreen:AlphaTo(0,0.3,0)
    timer.Simple(0.3,function(  )
      lcrashScreen:SetVisible(false)
    end)
    gui.EnableScreenClicker(false)
    timer.Remove("LucidCrashscreen_retry")
  end
end)

surface.CreateFont( "LucidScoreFontBig", { font = "Montserrat", size = 35, weight = 800, antialias = true, bold = true })
surface.CreateFont( "LucidScoreFontSmall", { font = "Montserrat", size = 20, weight = 700, antialias = true, bold = true })


hook.Add( "InitPostEntity", "LucidCrashScreenInit", function(ply)
  lcrashScreen = vgui.Create("DPanel")
	lcrashScreen:SetSize(ScrW(),ScrH())
	lcrashScreen:SetAlpha(0)
	lcrashScreen:SetVisible(false)
  lcrashScreen.disconnected = false

	--Create a paint function.
	lcrashScreen.Paint = function( s, w, h )

		--Draw the background.
		surface.SetDrawColor(Color(0,0,0,190))
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(color_white)
		draw.SimpleText("CONNECTION PROBLEMS","LucidScoreFontBig",w / 2, h * 0.23,color_white,TEXT_ALIGN_CENTER)
		draw.SimpleText("Connection to the server has been lost.","LucidScoreFontBig",w / 2, h * 0.34,color_white,TEXT_ALIGN_CENTER)
		draw.SimpleText("You will automatically reconnect in "..lcrash_reconnectDelay.."seconds","LucidScoreFontBig",w / 2, h * 0.37,color_white,TEXT_ALIGN_CENTER)

	end

	local paintFunction = function( s, w, h )
		surface.SetDrawColor(s:IsHovered() and Color(140,140,140,220) or Color(40,40,40,190))
		surface.DrawRect(0,0,w,h)

		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,w,h)

		surface.SetDrawColor(color_white)
	end
  
	local buttonWidth = ScrH() * 0.25
	local buttonHeight = ScrH() * 0.1
	--Create reconnect button.
	local reconnectBtn = vgui.Create("DButton",lcrashScreen)
	reconnectBtn:SetSize(buttonWidth,buttonHeight)
	reconnectBtn:SetPos(ScrW() / 2 - buttonWidth - ScrH() * 0.04,ScrH() * 0.82 - buttonHeight)
	reconnectBtn:SetTextColor(color_white)
	reconnectBtn:SetFont("LucidScoreFontBig")
	reconnectBtn:SetText("Reconnect")
	reconnectBtn.Paint = paintFunction
	reconnectBtn.DoClick = function()
		RunConsoleCommand("retry")
	end

	--Create leave button.
	local leaveBtn = vgui.Create("DButton",lcrashScreen)
	leaveBtn:SetSize(buttonWidth,buttonHeight)
	leaveBtn:SetPos(ScrW() / 2 + ScrH() * 0.04, ScrH() * 0.82 - buttonHeight)
	leaveBtn:SetTextColor(color_white)
	leaveBtn:SetFont("LucidScoreFontBig")
	leaveBtn:SetText("Disconnect")
	leaveBtn.Paint = paintFunction
	leaveBtn.DoClick = function(  )
		RunConsoleCommand("disconnect")
	end
  
  hook.Add("Think","LucidlcrashScreen", function()
    if (CurTime() - lcrash_lastReceived > lcrash_timeout) then
      if (lcrashScreen:IsVisible() == false) then
        lcrashScreen:SetVisible(true)
        lcrashScreen:AlphaTo(255,0.3)
        gui.EnableScreenClicker(true)
        lcrashScreen.disconnected = true
        print("[lucidcrash] Opening CrashScreen!")
        timer.Create("LucidCrashscreen_retry",lcrash_reconnectDelay,1,function()
          RunConsoleCommand("retry")
        end)
      end
    end
  end)
end)