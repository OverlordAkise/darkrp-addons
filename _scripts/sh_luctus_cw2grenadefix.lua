--Luctus CW2 self-exploding grenades
--Made by OverlordAkise

--This script lets cw2 grenades explode if you hold them for too long after pulling the pin
--This uses the grenades fuse time, which is 3s (flash 2.5s)
--Also, if you throw them they will explode in (pinPulledTime - fuseTime) seconds
--This means you can "pre-cook" grenades before throwing them

hook.Add("InitPostEntity","luctus_cw2grenadefix",function()

print("[luctus_cw2grenadefix] overwriting grenade base and fixing flashbang")

local SWEP = weapons.GetStored("cw_grenade_base")
if not SWEP then error("grenade base not found?") end
function SWEP:IndividualThink()
	local curTime = CurTime()
	
	if self.pinPulled then
        if curTime > (self.throwTime-self.timeToThrow+self.fuseTime) then
            if SERVER then
                local grenade = ents.Create(self.grenadeEnt)
                grenade:SetPos(self.Owner:GetShootPos() + CustomizableWeaponry.quickGrenade:getThrowOffset(self.Owner))
                grenade:SetAngles(self.Owner:EyeAngles())
                grenade:Spawn()
                grenade:Activate()
                grenade:Fuse(0)
                grenade:SetOwner(self.Owner)
                -- CustomizableWeaponry.quickGrenade:applyThrowVelocity(self.Owner, grenade)
                self:TakePrimaryAmmo(1)
            end
            self:SetNextPrimaryFire(curTime + 1)
            self.pinPulled = false
            self.animPlayed = true
            return
        end
		if curTime > self.throwTime then
			if not self.Owner:KeyDown(IN_ATTACK) then
				if not self.animPlayed then
					self.entityTime = CurTime() + 0.15
					self:sendWeaponAnim("throw")
					self.Owner:SetAnimation(PLAYER_ATTACK1)
				end
				
				if curTime > self.entityTime then
					if SERVER then
						local grenade = ents.Create(self.grenadeEnt)
						grenade:SetPos(self.Owner:GetShootPos() + CustomizableWeaponry.quickGrenade:getThrowOffset(self.Owner))
						grenade:SetAngles(self.Owner:EyeAngles())
						grenade:Spawn()
						grenade:Activate()
						grenade:Fuse(self.throwTime-self.timeToThrow+self.fuseTime-curTime)
						grenade:SetOwner(self.Owner)
						CustomizableWeaponry.quickGrenade:applyThrowVelocity(self.Owner, grenade)
						self:TakePrimaryAmmo(1)
					end
					
					self:SetNextPrimaryFire(curTime + 1)
					
					timer.Simple(self.swapTime, function()
						if IsValid(self) then
							if self.Owner:GetAmmoCount(self.Primary.Ammo) <= 0 then -- we're out of ammo, strip this weapon
								self.Owner:ConCommand("lastinv")
							else
								self:sendWeaponAnim("draw")
							end
						end
					end)
					
					self.pinPulled = false
				end
				
				self.animPlayed = true
			end
		end
	end
end

if CLIENT then return end

--Fix the flashbang not having a configurable timer when thrown
--Really, he hardcoded a 2.5 seconds fuse time, so we have to do this
local ENT = scripted_ents.GetStored("cw_flash_thrown").t
if not ENT then error("flashbang not found?") end

local traceData = {}
traceData.mask = bit.bor(CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_DEBRIS, CONTENTS_MONSTER, CONTENTS_HITBOX, CONTENTS_WATER)

function ENT:Fuse(t)
	t = t or 2.5
	print("Fusetime for flash:",t)
    --Changed this line:
	--timer.Simple(2.5, function()
    --To this line:
	timer.Simple(t, function()
    --That's all that i have changed
		if self:IsValid() then
			local hitPos = self:GetPos()
			
			-- trace up to check for impacts
			traceData.start = hitPos
			local finishPos = traceData.start + Vector(0, 0, 32)
			
			traceData.endpos = finishPos
			traceData.filter = self
			
			local trace = util.TraceLine(traceData)
			local traceZ = trace.HitPos.z
			finishPos.z = traceZ
			
			self:EmitSound("weapons/flashbang/flashbang_explode2.wav", 85, 100)
			
			for key, obj in ipairs(player.GetAll()) do
				if obj:Alive() then
					local bone = obj:LookupBone("ValveBiped.Bip01_Head1")
					
					if bone then
						local headPos, headAng = obj:GetBonePosition(bone)
						local objDist = headPos:Distance(finishPos)
						
						if objDist <= self.FlashDistance then
							traceData.filter = obj
							
							local ourAimVec = self.Owner:GetAimVector()
							
							local direction = (finishPos - headPos):GetNormal()
							local dotToGeneralDirection = ourAimVec:DotProduct(direction)
							
							traceData.start = headPos
							
							traceData.endpos = traceData.start + direction * math.min(objDist, self.FlashDistance)
							
							local trace = util.TraceLine(traceData)
							local ent = trace.Entity
							
							if not IsValid(ent) or (not ent:IsValid() and not ent:IsWorld()) or ent == self then
								local isMaxIntensity = (objDist - self.MaxIntensityDistance) < 0
								local decay = self.FlashDistance - self.MaxIntensityDistance
								local intensity = 0
								
								if isMaxIntensity then
									intensity = 1
								else
									local decayDistance = objDist - self.MaxIntensityDistance
									intensity = 1 - decayDistance / decay
								end
								
								intensity = math.min((intensity + 0.25) * dotToGeneralDirection, 1)
								local duration = intensity * self.FlashDuration
								
								umsg.Start("CW_FLASHBANGED", obj)
									umsg.Float(intensity)
									umsg.Float(duration)
								umsg.End()
							end
						end
					end
				end
			end
			
			self:Remove()
		end
	end)
end

end)

print("[luctus_cw2grenadefix] sh loaded")
