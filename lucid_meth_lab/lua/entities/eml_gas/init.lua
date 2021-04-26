AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/canister01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	
	self:SetNWInt("amount", EML_Gas_Amount)
	self:SetNWInt("maxAmount", EML_Gas_Amount)
	self:SetNWBool("open", false)
	self:SetNWBool("explode", false)
	self:GetPhysicsObject():SetMass(105)
	self:SetPos(self:GetPos()+Vector(0, 0, 32))
end
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_gas")
	ent:SetPos(trace.HitPos + trace.HitNormal * 16)
	ent:Spawn()
	ent:Activate()
     
	return ent
end

function ENT:Use(activator, caller)
local curTime = CurTime()
	if (!self.nextUse or curTime >= self.nextUse) then
		if !self:GetNWBool("open") then
			self:SetNWBool("open", true)
			self.gasSound = CreateSound(self, Sound("ambient/gas/cannister_loop.wav"))
			self.gasSound:SetSoundLevel(42)
			self.gasSound:PlayEx(1, 150)
		else
			self:SetNWBool("open", false)
			if self.gasSound then
				self.gasSound:Stop()
			end
		end
		self.nextUse = curTime + 0.5
	end
end

function ENT:Think()
local traceGas = {}	
traceGas.start = (self:GetPos()+(self:GetUp()*28))
traceGas.endpos = (self:GetPos()+(self:GetUp()*42))
traceGas.filter = self

local traceConnect = util.TraceLine(traceGas)

	if ((!self.nextGas or CurTime() >= self.nextGas) and (self:GetNWInt("amount")>0) and self:GetNWBool("open")) then	
		if IsValid(traceConnect.Entity) then	
			if (traceConnect.Entity:GetClass() == "eml_stove") then
				self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")))
				traceConnect.Entity:SetNWInt("gasStorage", math.Clamp(traceConnect.Entity:GetNWInt("gasStorage")+1, 0, traceConnect.Entity:GetNWInt("gasStorageMax")));			
			else
				self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")))
			end
		else
			self:SetNWInt("amount", math.Clamp(self:GetNWInt("amount")-1, 0, self:GetNWInt("maxAmount")))
		end;	
	self.nextGas = CurTime() + 0.01
	end
	
	if (self:GetNWInt("amount")==0) then
		if self.gasSound then
			self.gasSound:Stop()
		end
    self:VisualEffect()
	end
	
end

function ENT:OnTakeDamage(dmginfo)
	if (EML_Gas_ExplosionType == 2) then
		if !self:GetNWBool("explode") then
			self:SetNWBool("explode", true)
			if (self:GetNWInt("amount")>0) then
				if self.gasSound then
					self.gasSound:Stop()
				end;	
				self:Explode()
			else
				self:VisualEffect()
			end
		end
	elseif (EML_Gas_ExplosionType == 1) then
		if self.gasSound then
			self.gasSound:Stop()
		end;	
		self:VisualEffect()
	elseif (EML_Gas_ExplosionType == 0) then		
		return false
	end
end

function ENT:Explode()	
	local explosionSize = math.Round(self:GetNWInt("amount")/2)
	
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

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true)
	self:Remove()
end

