AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/furnitureStove001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetHealth(EML_Stove_Health)
   
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
   
	
   
	self:SetNWInt("stoveConsumption", EML_Stove_Consumption)
	self:SetNWInt("stoveHeat", EML_Stove_Heat)
   
	self:SetNWInt("gasStorage", EML_Gas_Amount)
	self:SetNWInt("gasStorageMax", EML_Gas_Amount)
   
	self:SetNWBool("firePlace1", false)
	self:SetNWBool("firePlace2", false)
	self:SetNWBool("firePlace3", false)
	self:SetNWBool("firePlace4", false)
	self:SetNWBool("explode", false)
   
	self:SetPos(self:GetPos()+Vector(0, 0, 32))
   
	if EML_Stove_GravityGun then
			self:GetPhysicsObject():SetMass(105)
	end;   
end

function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_stove")
	ent:SetPos(trace.HitPos + trace.HitNormal * 8)
	ent:Spawn()
	ent:Activate()
 
	return ent
end

function ENT:OnTakeDamage(dmginfo)
	if (EML_Stove_ExplosionType == 2) then
			self:SetHealth(self:Health()-dmginfo:GetDamage())
			if self:Health() <= dmginfo:GetDamage() then
					if !self:GetNWBool("explode") then
							self:SetNWBool("explode", true)
							self:Explode()
					end
			end
	elseif (EML_Stove_ExplosionType == 1) then
			self:SetHealth(self:Health()-dmginfo:GetDamage())
			if self:Health() <= dmginfo:GetDamage() then
					self:Remove()
			end
	elseif (EML_Stove_ExplosionType == 0) then             
			return false
	end
end

function ENT:Think()
local traceF1 = {}     
traceF1.start = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*11.5)
traceF1.endpos = self:GetPos()+(self:GetUp()*24)+(self:GetForward()*2.8)+(self:GetRight()*11.5)
traceF1.filter = self

local traceF2 = {}     
traceF2.start = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*2.8)+(self:GetRight()*-11.2)
traceF2.endpos = self:GetPos()+(self:GetUp()*24)+(self:GetForward()*2.8)+(self:GetRight()*-11.2)
traceF2.filter = self

local traceF3 = {}     
traceF3.start = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*-11.2)
traceF3.endpos = self:GetPos()+(self:GetUp()*24)+(self:GetForward()*-9.8)+(self:GetRight()*-11.2)
traceF3.filter = self

local traceF4 = {}     
traceF4.start = self:GetPos()+(self:GetUp()*20)+(self:GetForward()*-9.8)+(self:GetRight()*11.5)
traceF4.endpos = self:GetPos()+(self:GetUp()*24)+(self:GetForward()*-9.8)+(self:GetRight()*11.5)
traceF4.filter = self

local traceFire1 = util.TraceLine(traceF1)
local traceFire2 = util.TraceLine(traceF2)
local traceFire3 = util.TraceLine(traceF3)
local traceFire4 = util.TraceLine(traceF4)

	if ((!self.nextHeat or CurTime() >= self.nextHeat) and (self:GetNWInt("gasStorage")>0)) then   
			if IsValid(traceFire1.Entity) then     
					if ((((traceFire1.Entity:GetClass() == "eml_pot") and ((traceFire1.Entity:GetNWInt("sulfur")>0) and (traceFire1.Entity:GetNWInt("macid")>0))))
					or (((traceFire1.Entity:GetClass() == "eml_spot") and ((traceFire1.Entity:GetNWInt("redp")>0) and (traceFire1.Entity:GetNWInt("ciodine")>0))))) then
							self:SetNWInt("gasStorage", math.Clamp(self:GetNWInt("gasStorage")-EML_Stove_Consumption, 0, self:GetNWInt("gasStorageMax")))
							traceFire1.Entity:SetNWInt("time", math.Clamp(traceFire1.Entity:GetNWInt("time")-1, 0, traceFire1.Entity:GetNWInt("maxTime")));                
							if (traceFire1.Entity:GetNWInt("time") == 0) then
									traceFire1.Entity:SetNWInt("status", 1)
									--traceFire1.Entity:EmitSound("ambient/fire/ignite.wav")
							end;                                           
							local soundChance = math.random(1, 2)
									if soundChance == 2 then
											traceFire1.Entity:EmitSound("ambient/levels/canals/toxic_slime_gurgle"..math.random(2, 8)..".wav")
									end
							self:SetNWBool("firePlace1", true)
					end
			else
					self:SetNWBool("firePlace1", false)
			end
			if IsValid(traceFire2.Entity) then     
					if ((((traceFire2.Entity:GetClass() == "eml_pot") and ((traceFire2.Entity:GetNWInt("sulfur")>0) and (traceFire2.Entity:GetNWInt("macid")>0))))
					or (((traceFire2.Entity:GetClass() == "eml_spot") and ((traceFire2.Entity:GetNWInt("redp")>0) and (traceFire2.Entity:GetNWInt("ciodine")>0))))) then
							self:SetNWInt("gasStorage", math.Clamp(self:GetNWInt("gasStorage")-EML_Stove_Consumption, 0, self:GetNWInt("gasStorageMax")))
							traceFire2.Entity:SetNWInt("time", math.Clamp(traceFire2.Entity:GetNWInt("time")-1, 0, traceFire2.Entity:GetNWInt("maxTime")));                
							if (traceFire2.Entity:GetNWInt("time") == 0) then
									traceFire2.Entity:SetNWInt("status", 1)
									--traceFire1.Entity:EmitSound("ambient/fire/ignite.wav")
							end;                                           
							local soundChance = math.random(1, 2)
									if soundChance == 2 then
											traceFire2.Entity:EmitSound("ambient/levels/canals/toxic_slime_gurgle"..math.random(2, 8)..".wav")
									end
							self:SetNWBool("firePlace2", true)
					end
			else
					self:SetNWBool("firePlace2", false)
			end
			if IsValid(traceFire3.Entity) then     
					if ((((traceFire3.Entity:GetClass() == "eml_pot") and ((traceFire3.Entity:GetNWInt("sulfur")>0) and (traceFire3.Entity:GetNWInt("macid")>0))))
					or (((traceFire3.Entity:GetClass() == "eml_spot") and ((traceFire3.Entity:GetNWInt("redp")>0) and (traceFire3.Entity:GetNWInt("ciodine")>0))))) then
							self:SetNWInt("gasStorage", math.Clamp(self:GetNWInt("gasStorage")-EML_Stove_Consumption, 0, self:GetNWInt("gasStorageMax")))
							traceFire3.Entity:SetNWInt("time", math.Clamp(traceFire3.Entity:GetNWInt("time")-1, 0, traceFire3.Entity:GetNWInt("maxTime")));                
							if (traceFire3.Entity:GetNWInt("time") == 0) then
									traceFire3.Entity:SetNWInt("status", 1)
									--traceFire1.Entity:EmitSound("ambient/fire/ignite.wav")
							end;                                           
							local soundChance = math.random(1, 2)
									if soundChance == 2 then
											traceFire3.Entity:EmitSound("ambient/levels/canals/toxic_slime_gurgle"..math.random(2, 8)..".wav")
									end
							self:SetNWBool("firePlace3", true)
					end
			else
					self:SetNWBool("firePlace3", false)
			end
			if IsValid(traceFire4.Entity) then     
					if ((((traceFire4.Entity:GetClass() == "eml_pot") and ((traceFire4.Entity:GetNWInt("sulfur")>0) and (traceFire4.Entity:GetNWInt("macid")>0))))
					or (((traceFire4.Entity:GetClass() == "eml_spot") and ((traceFire4.Entity:GetNWInt("redp")>0) and (traceFire4.Entity:GetNWInt("ciodine")>0))))) then
							self:SetNWInt("gasStorage", math.Clamp(self:GetNWInt("gasStorage")-EML_Stove_Consumption, 0, self:GetNWInt("gasStorageMax")))
							traceFire4.Entity:SetNWInt("time", math.Clamp(traceFire4.Entity:GetNWInt("time")-1, 0, traceFire4.Entity:GetNWInt("maxTime")));                
							if (traceFire4.Entity:GetNWInt("time") == 0) then
									traceFire4.Entity:SetNWInt("status", 1)
									--traceFire1.Entity:EmitSound("ambient/fire/ignite.wav")
							end;                                           
							local soundChance = math.random(1, 2)
									if soundChance == 2 then
											traceFire4.Entity:EmitSound("ambient/levels/canals/toxic_slime_gurgle"..math.random(2, 8)..".wav")
									end
							self:SetNWBool("firePlace4", true)
					end
			else
					self:SetNWBool("firePlace4", false)
			end;           
	self.nextHeat = CurTime() + 1
	end
end

function ENT:Explode() 
	local explosionSize = EML_Stove_ExplosionDamage
   
	local explosion = ents.Create("env_explosion");                        
	explosion:SetPos(self:GetPos())
	explosion:SetKeyValue("iMagnitude", explosionSize)
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire("Explode", 0, 0)
   
	local shake = ents.Create("env_shake")
	shake:SetPos(self:GetPos())
	shake:SetKeyValue("amplitude", (explosionSize*2))
	shake:SetKeyValue("radius", explosionSize)
	shake:SetKeyValue("duration", "1.5")
	shake:SetKeyValue("frequency", "255")
	shake:SetKeyValue("spawnflags", "4")
	shake:Spawn()
	shake:Activate()
	shake:Fire("StartShake", "", 0)
   
	self:Remove()
end