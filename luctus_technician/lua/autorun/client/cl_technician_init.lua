--Luctus Technician
--Made by OverlordAkise

surface.CreateFont( "TechnicianText", {
	font = "Arial",
	extended = false,
	size = 150,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

bank_search_starttime = 0
bank_search_progress = 0
SmoothedProgress = 0

net.Receive("luctus_technician_repair", function()
	local enabled = net.ReadBool()
	if enabled then 
		bank_search_starttime = CurTime() 
	else 
		bank_search_starttime = 0 
		bank_search_progress = 0 
		SmoothedProgress = 0
	end
end)

net.Receive("luctus_technician_togglehud", function()
  local shouldBeActive = net.ReadBool()
  if shouldBeActive then
    --print("Adding Technician HUD!")
    hook.Add("HUDPaint", "luctus_technician_hud",luctusTechnicianHUD)
  else
    --print("Removing Technician HUD!")
    hook.Remove("HUDPaint", "luctus_technician_hud")
  end
end)

function luctusTechnicianHUD()
	local SW, SH = ScrW(), ScrH()

	if bank_search_starttime ~= 0 then
		bank_search_progress = ((CurTime() - bank_search_starttime) / 10) * 100
		if bank_search_progress > 100 then bank_search_progress = 100 end
		SmoothedProgress = math.Approach(SmoothedProgress, bank_search_progress, (bank_search_progress - SmoothedProgress) / 2)
    
    surface.SetDrawColor(0,0,0,255)
    surface.DrawOutlinedRect( SW*0.3-2, SH/2+18, SW*0.4+4, 20+4, 2 )
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect( SW*0.3, SH/2+20, (SW*0.4)*(SmoothedProgress*0.01), 20 )
		surface.SetDrawColor( 255, 255, 255, 5 )
		surface.DrawRect( SW*0.3, SH/2+20, SW*0.4, 20 )
    draw.SimpleTextOutlined( "Repairing...", "Trebuchet24", SW/2, SH/2+60, color_white,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,1,color_black)
	end
  --Show broken entities on the screen
  for _, ent in ipairs( ents.FindByClass( "luctus_tec*" ) ) do
    if not ent:GetBroken() then continue end
		local point = ent:GetPos() + ent:OBBCenter()
		local data2D = point:ToScreen()
		if ( not data2D.visible ) then continue end
		draw.SimpleTextOutlined("r", "Marlett", data2D.x, data2D.y, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,1,color_black)
    draw.SimpleTextOutlined(math.Round(LocalPlayer():GetPos():Distance(ent:GetPos())), "DermaDefault", data2D.x, data2D.y+20, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,1,color_black)
	end
end
