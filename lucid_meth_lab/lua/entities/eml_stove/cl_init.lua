include("shared.lua")

function ENT:Initialize()	
	self.emitTime = CurTime()
	self.firePlace1 = ParticleEmitter(self:GetPos())
	self.firePlace2 = ParticleEmitter(self:GetPos())
	self.firePlace3 = ParticleEmitter(self:GetPos())
	self.firePlace4 = ParticleEmitter(self:GetPos())
end

function ENT:Think()

	local firePos1 = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*11.5)
	local firePos2 = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*-11.2)
	local firePos3 = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*-11.2)
	local firePos4 = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*11.5)
	
	if (self:GetNWInt("gasStorage")>0) then
		if (self.emitTime < CurTime()) then
			if (self:GetNWBool("firePlace1")) then
				local smoke = self.firePlace1:Add("particle/smokesprites_000"..math.random(1,9), firePos1)
				smoke:SetVelocity(Vector(0, 0, 150))
				smoke:SetDieTime(math.Rand(0.6, 2.3))
				smoke:SetStartAlpha(math.Rand(150, 200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0, 5))
				smoke:SetEndSize(math.random(33, 55))
				smoke:SetRoll(math.Rand(180, 480))
				smoke:SetRollDelta(math.Rand(-3, 3))
				smoke:SetColor(100, 100, 0)
				smoke:SetGravity(Vector(0, 0, 10))
				smoke:SetAirResistance(256)
				self.emitTime = CurTime() + .1
			end
			if (self:GetNWBool("firePlace2")) then
				local smoke = self.firePlace2:Add("particle/smokesprites_000"..math.random(1,9), firePos2)
				smoke:SetVelocity(Vector(0, 0, 150))
				smoke:SetDieTime(math.Rand(0.6, 2.3))
				smoke:SetStartAlpha(math.Rand(150, 200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0, 5))
				smoke:SetEndSize(math.random(33, 55))
				smoke:SetRoll(math.Rand(180, 480))
				smoke:SetRollDelta(math.Rand(-3, 3))
				smoke:SetColor(100, 100, 0)
				smoke:SetGravity(Vector(0, 0, 10))
				smoke:SetAirResistance(256)
				self.emitTime = CurTime() + .1
			end
			if (self:GetNWBool("firePlace3")) then
				local smoke = self.firePlace3:Add("particle/smokesprites_000"..math.random(1,9), firePos3)
				smoke:SetVelocity(Vector(0, 0, 150))
				smoke:SetDieTime(math.Rand(0.6, 2.3))
				smoke:SetStartAlpha(math.Rand(150, 200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0, 5))
				smoke:SetEndSize(math.random(33, 55))
				smoke:SetRoll(math.Rand(180, 480))
				smoke:SetRollDelta(math.Rand(-3, 3))
				smoke:SetColor(100, 100, 0)
				smoke:SetGravity(Vector(0, 0, 10))
				smoke:SetAirResistance(256)
				self.emitTime = CurTime() + .1
			end
			if (self:GetNWBool("firePlace4")) then
				local smoke = self.firePlace4:Add("particle/smokesprites_000"..math.random(1,9), firePos4)
				smoke:SetVelocity(Vector(0, 0, 150))
				smoke:SetDieTime(math.Rand(0.6, 2.3))
				smoke:SetStartAlpha(math.Rand(150, 200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(0, 5))
				smoke:SetEndSize(math.random(33, 55))
				smoke:SetRoll(math.Rand(180, 480))
				smoke:SetRollDelta(math.Rand(-3, 3))
				smoke:SetColor(100, 100, 0)
				smoke:SetGravity(Vector(0, 0, 10))
				smoke:SetAirResistance(256)
				self.emitTime = CurTime() + .1
			end;		
		end
	end
end


local laser = Material("cable/redlaser")
function ENT:Draw()
	self:DrawModel()
	
	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)

	if LocalPlayer():GetPos():DistToSqr(self:GetPos()) < 256*256 then
		render.SetMaterial(laser)
		--Fire Place #1
		render.DrawBeam(self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*11.5), self:GetPos()+(self:GetUp()*24)+(self:GetForward()*2.8)+(self:GetRight()*11.5), 1, 1, 1, Color(255, 0, 0, 0))
		
		--Fire Place #2
		render.DrawBeam(self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*-11.2), self:GetPos()+(self:GetUp()*24)+(self:GetForward()*2.8)+(self:GetRight()*-11.2), 1, 1, 1, Color(255, 0, 0, 0))

		--Fire Place #3
		render.DrawBeam(self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*-11.2), self:GetPos()+(self:GetUp()*24)+(self:GetForward()*-9.8)+(self:GetRight()*-11.2), 1, 1, 1, Color(255, 0, 0, 0))
		
		--Fire Place #4
		render.DrawBeam(self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*11.5), self:GetPos()+(self:GetUp()*24)+(self:GetForward()*-9.8)+(self:GetRight()*11.5), 1, 1, 1, Color(255, 0, 0, 0));		
		
		cam.Start3D2D(pos+ang:Up()*14.5, ang, 0.1)
		
			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-215, -51, 194, 20)
			
			surface.SetDrawColor(Color(255, 222, 0, 255))
			surface.DrawRect(-213, -50, math.Round((self:GetNWInt("gasStorage")*190)/self:GetNWInt("gasStorageMax")), 18)	
			draw.SimpleTextOutlined(math.Round((self:GetNWInt("gasStorage")*100)/self:GetNWInt("gasStorageMax")).."%", "methFont1", -211, -48, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, 1, Color(25, 25, 25, 200))

			surface.SetDrawColor(Color(0, 0, 0, 200))
			surface.DrawRect(-215, -90, 48, 32)	

			--Fire Place #1
			if !self:GetNWBool("firePlace1") then
				surface.SetDrawColor(Color(255, 0, 0, 255))
			elseif self:GetNWBool("firePlace1") then
				if (self:GetNWInt("gasStorage")>0) then
					surface.SetDrawColor(Color(0, 255, 0, 255))
				else 		
					surface.SetDrawColor(Color(255, 0, 0, 255))
				end
			end
				surface.SetMaterial(Material( "icon16/stop.png" ))
				surface.DrawTexturedRect(-212.5, -73, 14, 14)
				
			--Fire Place #2
			if !self:GetNWBool("firePlace2") then			
				surface.SetDrawColor(Color(255, 0, 0, 255))
			elseif self:GetNWBool("firePlace2") then
				if (self:GetNWInt("gasStorage")>0) then
					surface.SetDrawColor(Color(0, 255, 0, 255))
				else 		
					surface.SetDrawColor(Color(255, 0, 0, 255))
				end
			end;				
				surface.SetMaterial(Material( "icon16/stop.png" ))
				surface.DrawTexturedRect(-184.5, -73, 14, 14);	
				
			--Fire Place #3
			if !self:GetNWBool("firePlace3") then				
				surface.SetDrawColor(Color(255, 0, 0, 255));	
			elseif self:GetNWBool("firePlace3") then		
				if (self:GetNWInt("gasStorage")>0) then
					surface.SetDrawColor(Color(0, 255, 0, 255))
				else 		
					surface.SetDrawColor(Color(255, 0, 0, 255))
				end
			end;	
				surface.SetMaterial(Material( "icon16/stop.png" ));		
				surface.DrawTexturedRect(-184.5, -89, 14, 14);	
			
			--Fire Place #4
			if !self:GetNWBool("firePlace4") then					
				surface.SetDrawColor(Color(255, 0, 0, 255))
			elseif self:GetNWBool("firePlace4") then			
				if (self:GetNWInt("gasStorage")>0) then
					surface.SetDrawColor(Color(0, 255, 0, 255))
				else 		
					surface.SetDrawColor(Color(255, 0, 0, 255))
				end
			end
				surface.SetMaterial(Material( "icon16/stop.png" ))
				surface.DrawTexturedRect(-212.5, -89, 14, 14);			
					
		cam.End3D2D()
	end
end