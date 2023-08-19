--Luctus Rules
--Made by OverlordAkise

function openLucidRulesWindow()
  --Main Window
  local frame = vgui.Create("DFrame")
  frame:SetSize(800,600)
  frame:SetTitle("Rules")
  frame:Center()
  frame:MakePopup()
  frame:ShowCloseButton(false)
  frame.Paint = function(self,w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
  end
  local frameX, frameY = frame:GetSize()
  
  --Close Button Top Right
  local CloseButton = vgui.Create("DButton", frame)
  CloseButton:SetText("X")
  CloseButton:SetPos(frameX-22,2)
  CloseButton:SetSize(20,20)
  CloseButton:SetTextColor(Color(0, 195, 165))
  CloseButton.DoClick = function()
    frame:Close()
  end
  CloseButton.Paint = function(self,w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
    if (self.Hovered) then
      draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
    end
  end

  --[[
  --For Text:
  local MainPanel = vgui.Create("DTextEntry",frame)
  MainPanel:Dock(FILL)
  MainPanel:SetVerticalScrollbarEnabled(true)
  MainPanel:SetMultiline(true)
  MainPanel:SetTextColor(Color(255,255,255))
  MainPanel:SetText(text_rules)
  MainPanel:SetPaintBackground(false)
  MainPanel:SetDrawLanguageID(false)
  --]]

  --For HTML:
  local MainPanel = vgui.Create("DHTML",frame)
  MainPanel:Dock(FILL)
  MainPanel:OpenURL("https://luctus.at")
  --MainPanel:SetHTML(html_rules)
  --local ctrls = vgui.Create( "DHTMLControls", frame )
  --ctrls:Dock(TOP)
  --ctrls:SetHTML( MainPanel )
  --ctrls.AddressBar:SetText("https://luctus.at")
  --]]
end

hook.Add("OnPlayerChat","lucid_openrules",function(ply,text,team,dead)
  if(ply == LocalPlayer() and text == "!rules")then
    openLucidRulesWindow()
  end
end)

hook.Add("InitPostEntity","lucid_openrulesonjoin",function()
	timer.Simple(5,function()
    openLucidRulesWindow()
	end)
end)
concommand.Add("lucid_rules",openLucidRulesWindow)

print("[luctus_rules] cl loaded")
