include("shared.lua")

function ENT:Initialize()	

end

function ENT:Draw()
	self:DrawModel()
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	local macidColor = Color(160, 221, 99, 255)
	local iodineColor = Color(137, 69, 54, 255)
	local waterColor = Color(133, 202, 219, 255)
	
	local potTime = "Progress: "..self:GetNWInt("progress").."% (Shake it!)"
	
	if (self:GetNWInt("status") == 0) then
		potTime = "Progress: "..self:GetNWInt("progress").."% (Shake it!)"
	elseif (self:GetNWInt("status") == 1) then	
		potTime = "Ready! Use to extract!"
	end
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 256*256 then
		cam.Start3D2D(pos + ang:Up()*5, ang, 0.10)
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-64, -38, 128, 96);		
		cam.End3D2D()
		cam.Start3D2D(pos + ang:Up()*5, ang, 0.055)
			draw.SimpleTextOutlined("Crystallized Iodine", "methFont", 0, -56, Color(220, 134, 159, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("______________", "methFont", 0, -54, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-104, -32, 204, 24);			
			surface.SetDrawColor(Color(220, 134, 159, 255))
			surface.DrawRect(-101.5, -30, math.Round((self:GetNWInt("progress")*198)/100), 20);		
			
			draw.SimpleTextOutlined("Ingredients", "methFont", -101, 8, Color(220, 134, 159, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("______________", "methFont", 0, 10, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))

			if (self:GetNWInt("macid")==0) then
				macidColor = Color(100, 100, 100, 255)
			else
				macidColor = Color(160, 221, 99, 255)
			end
			
			if (self:GetNWInt("iodine")==0) then
				iodineColor = Color(100, 100, 100, 255)
			else
				iodineColor = Color(137, 69, 54, 255)
			end

			if (self:GetNWInt("water")==0) then
				waterColor = Color(100, 100, 100, 255)
			else
				waterColor = Color(133, 202, 219, 255)
			end;											
		cam.End3D2D();	
		
		cam.Start3D2D(pos + ang:Up()*5, ang, 0.045)		
			draw.SimpleTextOutlined("Muriatic Acid ("..self:GetNWInt("macid")..")", "methFont", -121, 44, macidColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
			draw.SimpleTextOutlined("Liquid Iodine ("..self:GetNWInt("iodine")..")", "methFont", -121, 74, iodineColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));	
			draw.SimpleTextOutlined("Water ("..self:GetNWInt("water")..")", "methFont", -121, 104, waterColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));			
		cam.End3D2D();			
		cam.Start3D2D(pos + ang:Up()*5, ang, 0.035)		
			draw.SimpleTextOutlined(potTime, "methFont", -152, -32, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100));		
		cam.End3D2D();		
		
	end
end

