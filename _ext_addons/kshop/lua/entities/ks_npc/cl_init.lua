include("shared.lua")

function ENT:Draw()
	self:DrawModel()

	if LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
		if self.cam2d3dAng == nil then
			self.cam2d3dAng = Angle(0,LocalPlayer():GetAngles().y - 90,90)
		else
			self.cam2d3dAng = LerpAngle(7 * FrameTime(),self.cam2d3dAng, Angle(0,LocalPlayer():GetAngles().y - 90,90))
		end

		local ang = self:GetAngles()
		local pos = self:GetPos() + Vector(0,0,40) - ang:Forward() * (5) - (ang:Right() * (0+ self:GetNWInt("shop_x_offset", -0))) + (ang:Up() * (35 + self:GetNWInt("shop_y_offset", 0)))

		   	--s:SetNWInt("shop_x_offset", v["x_offset"] or 0)
		   --	s:SetNWInt("shop_y_offset", v["y_offset"] or 0)

		local alpha = 1 - math.Clamp((LocalPlayer():GetPos():Distance(self:GetPos()) / 350) * 1.1, 0, 1)

		local shopname = self:GetShopName()

		cam.Start3D2D(pos, self.cam2d3dAng, 0.05)
			draw.SimpleText((shopname or "No Name"), "ks5", 22+1, ((60-8-4)/2) - 70+1, Color(0,0,0, 255 * alpha), 1, 1)
			draw.SimpleText((shopname or "No Name"), "ks5", 22, ((60-8-4)/2) - 70, Color(255,255,255, 255 * alpha), 1, 1)
		cam.End3D2D()
	end
end