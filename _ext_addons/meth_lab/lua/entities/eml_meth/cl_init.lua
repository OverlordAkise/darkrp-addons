include("shared.lua")

function ENT:Initialize()	

end

function ENT:Draw()
	self:DrawModel()
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90);	
	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 256*256 then
		cam.Start3D2D(pos + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.125)
				if !self:GetNWBool("salesman") then
					draw.SimpleTextOutlined((self:GetNWInt("value")*self:GetNWInt("valueMod")).."$", "methFont", 8, -98, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				else
					draw.SimpleTextOutlined("Take it and bring to Meth Addicted person!", "methFont", 8, -98, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
				end
		cam.End3D2D()		
		cam.Start3D2D(pos + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.1)
				draw.SimpleTextOutlined("Crystal Meth ("..self:GetNWInt("amount").." lbs)", "methFont", 8, -96, Color(1, 241, 249, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(25, 25, 25, 100))
		cam.End3D2D()
	end
end

-- maxAmount = 60
-- amount = x

