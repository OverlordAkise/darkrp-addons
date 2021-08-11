include("shared.lua")

function ENT:Initialize()	
	self.emitTime = CurTime()
	self.gasPlace = ParticleEmitter(self:GetPos())
end

function ENT:Think()

	local gasPos = self:GetPos()+(self:GetUp()*28), self:GetPos()+(self:GetUp()*42)
	if (self:GetNWInt("amount")>0) then
		if (self.emitTime < CurTime()) then
			if (self:GetNWBool("open")) then
				local smoke = self.gasPlace:Add("particle/smokesprites_000"..math.random(1,9), gasPos)
				smoke:SetVelocity(self:GetUp()*128)
				smoke:SetDieTime(math.Rand(0.6, 1.3))
				smoke:SetStartAlpha(math.Rand(150, 200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0, 5))
				smoke:SetEndSize(math.random(16, 18))
				smoke:SetRoll(math.Rand(180, 480))
				smoke:SetRollDelta(math.Rand(-3, 3))
				smoke:SetColor(255, 255, 255)
				smoke:SetGravity(Vector(0, 0, 10))
				smoke:SetAirResistance(256)
				self.emitTime = CurTime() + .1
			end
		end;			
	end
end

local laser = Material("cable/cable")
function ENT:Draw()
	self:DrawModel()
	
	local pos = self:GetPos()
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Up(), 0)
	ang:RotateAroundAxis(ang:Forward(), 0)
	ang:RotateAroundAxis(ang:Right(), -90)
	
	local gasColor = Color(255, 222, 0, 100)
	
	if (!self:GetNWBool("open")) then
		gasColor = Color(255, 222, 0, 100)
	else
		gasColor = Color(255, 94, 0, 100)
	end
	
	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 256*256 then
		render.SetMaterial(laser)
		render.DrawBeam(self:GetPos()+(self:GetUp()*28), self:GetPos()+(self:GetUp()*42), 1, 1, 1, Color(255, 255, 255, 255))
	
		cam.Start3D2D(pos+ang:Up()*4.75, ang, 0.1)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(-176, -12, 450, 24)
			
				surface.SetDrawColor(gasColor)
				surface.DrawRect(-173, -9, math.Round((self:GetNWInt("amount")*444)/self:GetNWInt("maxAmount")), 18)	
				draw.SimpleTextOutlined(math.Round((self:GetNWInt("amount")*100)/self:GetNWInt("maxAmount")).."% ("..self:GetNWInt("amount").."/"..self:GetNWInt("maxAmount")..")", "methFont1", -170, -7, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(25, 25, 25, 200))
	
		cam.End3D2D()	
	end
end
