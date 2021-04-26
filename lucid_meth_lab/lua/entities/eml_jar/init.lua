AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/jar01a.mdl")
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
	self:SetNWInt("iodine", 0)
	self:SetNWInt("water", 0)
	self:SetNWInt("progress", EML_Jar_StartProgress)
	self:SetNWString("status", "inprogress")
	self:SetNWInt("status", 0)

	self:SetPos(self:GetPos()+Vector(0, 0, 8));	
end
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_jar")
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
			if (data.HitEntity:GetNWInt("amount")==0) then	
        data.HitEntity:VisualEffect()
      end
			self:SetNWInt("macid", self:GetNWInt("macid") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav")
			self:VisualEffect()
		end
	end
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_iodine") and (self:GetNWInt("iodine")<10) and (self:GetNWInt("status") != 1)) then
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
      if (data.HitEntity:GetNWInt("amount")==0) then	
        data.HitEntity:VisualEffect()
      end
			self:SetNWInt("iodine", self:GetNWInt("iodine") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav");		
			self:VisualEffect()
		end
	end
	if ((data.DeltaTime > 0) and (data.HitEntity:GetClass() == "eml_water") and (self:GetNWInt("water")<10) and (self:GetNWInt("status") != 1)) then
		if (data.HitEntity:GetNWInt("amount")>0) then
			data.HitEntity:SetNWInt("amount", math.Clamp(data.HitEntity:GetNWInt("amount") - 1, 0, 100))
      if (data.HitEntity:GetNWInt("amount")==0) then	
        data.HitEntity:VisualEffect()
      end
			self:SetNWInt("water", self:GetNWInt("water") + 1)
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle3.wav");		
			self:VisualEffect()
		end
	end;	
end

function ENT:Think()
	local progressTime = CurTime()

	if ((!self.progressTime or CurTime() >= self.progressTime) and (self:GetNWInt("macid")>0) and (self:GetNWInt("iodine")>0) and (self:GetNWInt("water")>0)) then
		if (self:GetNWInt("progress") != 100) then
			if ((self:GetVelocity():Length() > EML_Jar_MinShake) and (self:GetVelocity():Length() < EML_Jar_MaxShake)) then
				self:SetNWInt("progress", math.Clamp(self:GetNWInt("progress") + EML_Jar_CorrectShake, 0, 100))
				self:EmitSound("ambient/levels/canals/toxic_slime_sizzle4.wav", 100, 200)
			elseif (self:GetVelocity():Length() > EML_Jar_MaxShake) then
				self:SetNWInt("progress", math.Clamp(self:GetNWInt("progress") - EML_Jar_WrongShake, 0, 100))
				self:EmitSound("ambient/levels/canals/toxic_slime_sizzle4.wav", 100, 150);			
			end
		elseif (self:GetNWInt("progress") == 100) then		
			self:SetNWInt("status", 1)
		end
	self.progressTime = CurTime() + 0.5
	end

end

function ENT:Use(activator, caller)
local curTime = CurTime()
	if (!self.nextUse or curTime >= self.nextUse) then
		
		if ((self:GetNWInt("status")==1) and ((self:GetNWInt("macid")>0) and (self:GetNWInt("iodine")>0) and (self:GetNWInt("water")>0))) then			
			local ciodineAmount = math.Round((self:GetNWInt("macid")+self:GetNWInt("iodine")+self:GetNWInt("water"))/2)
		
			self:EmitSound("ambient/levels/canals/toxic_slime_sizzle2.wav")
			self:SetNWInt("macid", 0);			
			self:SetNWInt("iodine", 0)
			self:SetNWInt("water", 0)
			self:SetNWInt("progress", EML_Jar_StartProgress)
			self:SetNWInt("status", 0);			
			
			redP = ents.Create("eml_ciodine")
			redP:SetPos(self:GetPos()+self:GetUp()*12)
			redP:SetAngles(self:GetAngles())
			redP:Spawn()
			redP:GetPhysicsObject():SetVelocity(self:GetUp()*2)
			redP:SetNWInt("amount", ciodineAmount)
			redP:SetNWInt("maxAmount", ciodineAmount);			
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
