AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/metalPot001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	--[[
	local visProp = ents.Create("prop_physics")
	visProp:SetModel("models/props_phx/wheels/magnetic_med_base.mdl")
	visProp:SetPos(self:GetPos()+self:GetUp()*6)
	visProp:SetAngles(self:GetAngles()+Angle(180, 0, 0))
	visProp:SetParent(self)
	visProp:SetMaterial("models/shadertest/predator")
	visProp:SetModelScale(0.925, 0)
	visProp:Spawn()
	
	]]--
	self.angleResetCooldown = 0
	self:SetNWInt("macid", 0);	
	self:SetNWInt("sulfur", 0)
	self:SetNWInt("time", EML_Pot_StartTime)
	self:SetNWInt("maxTime", EML_Pot_StartTime)
	self:SetNWInt("status", 0)
	self:SetPos(self:GetPos()+Vector(0, 0, 8))
end
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_pot")
	ent:SetPos(trace.HitPos + trace.HitNormal * 8)
	ent:Spawn()
	ent:Activate()
     
	return ent
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect()
	self:Remove()
end

function ENT:PhysicsCollide(data, phys)
local curTime = CurTime(); 
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_macid") and (self:GetNWInt("macid")<10) and (self:GetNWInt("status") != 1)) then
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
			if EML_Pot_DestroyEmpty then
				if (data.HitEntity:GetNWInt("amount")==0) then	
					data.HitEntity:VisualEffect()
				end;		
			end
			self:SetNWInt("time", self:GetNWInt("time")+EML_Pot_OnAdd_MuriaticAcid)
			self:SetNWInt("maxTime", self:GetNWInt("maxTime")+EML_Pot_OnAdd_MuriaticAcid)
			self:SetNWInt("macid", self:GetNWInt("macid") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
			self:VisualEffect()
		end
	end
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_sulfur") and (self:GetNWInt("sulfur")<10) and (self:GetNWInt("status") != 1)) then
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
			if EML_Pot_DestroyEmpty then
				if (data.HitEntity:GetNWInt("amount")==0) then	
					data.HitEntity:VisualEffect()
				end;		
			end;	
			self:SetNWInt("time", self:GetNWInt("time")+EML_Sulfur_Amount)
			self:SetNWInt("maxTime", self:GetNWInt("maxTime")+EML_Sulfur_Amount)
			self:SetNWInt("sulfur", self:GetNWInt("sulfur") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav");		
			self:VisualEffect()
		end
	end
end

function ENT:Use( activator, caller )
local curTime = CurTime()
	if (!self.nextUse or curTime >= self.nextUse) then
		
		if ((self:GetNWInt("status")==1) and ((self:GetNWInt("macid")>0) and (self:GetNWInt("sulfur")>0))) then			
			local redpAmount = (self:GetNWInt("macid")+self:GetNWInt("sulfur"))
		
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle2.wav")
			self:SetNWInt("macid", 0);			
			self:SetNWInt("sulfur", 0)
			self:SetNWInt("time", EML_Pot_StartTime)
			self:SetNWInt("maxTime", EML_Pot_StartTime)
			self:SetNWInt("status", 0);			
			
			redP = ents.Create("eml_redp")
			redP:SetPos(self:GetPos()+self:GetUp()*12)
			redP:SetAngles(self:GetAngles())
			redP:Spawn()
			redP:GetPhysicsObject():SetVelocity(self:GetUp()*2)
			redP:SetNWInt("amount", redpAmount)
			redP:SetNWInt("maxAmount", redpAmount);			
		end
		
		self.nextUse = curTime + 0.5
	end
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y - 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	end
end

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true)
end