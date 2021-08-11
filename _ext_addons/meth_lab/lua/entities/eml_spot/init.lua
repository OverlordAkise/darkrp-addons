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
	self:SetNWInt("redp", 0);	
	self:SetNWInt("ciodine", 0)
	self:SetNWInt("time", EML_SpecialPot_StartTime)
	self:SetNWInt("maxTime", EML_SpecialPot_StartTime)
	self:SetNWInt("status", 0)
	self:SetPos(self:GetPos()+Vector(0, 0, 8))
end
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_spot")
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
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_redp") and (self:GetNWInt("redp")<10) and (self:GetNWInt("status") != 1)) then	
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
			if (data.HitEntity:GetNWInt("amount")==0) then	
				data.HitEntity:VisualEffect()
			end;			
			self:SetNWInt("time", self:GetNWInt("time")+EML_SpecialPot_OnAdd_RedPhosphorus)
			self:SetNWInt("maxTime", self:GetNWInt("maxTime")+EML_SpecialPot_OnAdd_RedPhosphorus)
			self:SetNWInt("redp", self:GetNWInt("redp") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
			self:VisualEffect()
		end
	end
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_ciodine") and (self:GetNWInt("ciodine")<10) and (self:GetNWInt("status") != 1)) then		
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
			if (data.HitEntity:GetNWInt("amount")==0) then	
				data.HitEntity:VisualEffect()
			end;				
			self:SetNWInt("time", self:GetNWInt("time")+EML_SpecialPot_OnAdd_CrystallizedIodine)
			self:SetNWInt("maxTime", self:GetNWInt("maxTime")+EML_SpecialPot_OnAdd_CrystallizedIodine)
			self:SetNWInt("ciodine", self:GetNWInt("ciodine") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav");		
			self:VisualEffect()
		end
	end
end

function ENT:Use(activator, caller)
local curTime = CurTime()
	if (!self.nextUse or curTime >= self.nextUse) then
		
		if ((self:GetNWInt("status")==1) and ((self:GetNWInt("redp")>0) and (self:GetNWInt("ciodine")>0))) then			
			local methAmount = (self:GetNWInt("redp")+self:GetNWInt("ciodine"))
		
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle2.wav")
			self:SetNWInt("redp", 0);			
			self:SetNWInt("ciodine", 0)
			self:SetNWInt("time", EML_SpecialPot_StartTime)
			self:SetNWInt("maxTime", EML_SpecialPot_StartTime)
			self:SetNWInt("status", 0);			
			
			meth = ents.Create("eml_meth")
			meth:SetPos(self:GetPos()+self:GetUp()*12)
			meth:SetAngles(self:GetAngles())
			meth:Spawn()
			meth:GetPhysicsObject():SetVelocity(self:GetUp()*2)
			meth:SetNWInt("amount", methAmount)
			meth:SetNWInt("maxAmount", methAmount)
			meth:SetNWInt("value", methAmount)
		end
		
		self.nextUse = curTime + 0.5
	end
	--Shift + E = Upright
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
