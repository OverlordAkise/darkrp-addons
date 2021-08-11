AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/jar01b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.angleResetCooldown = 0
	self:SetNWInt("amount", EML_Sulfur_Amount)
	self:SetNWInt("maxAmount", EML_Sulfur_Amount)
	self:SetPos(self:GetPos()+Vector(0, 0, 8))
end
 
function ENT:SpawnFunction(ply, trace)
	local ent = ents.Create("eml_sulfur")
	ent:SetPos(trace.HitPos + trace.HitNormal * 16)
	ent:Spawn()
	ent:Activate()
     
	return ent
end

function ENT:OnTakeDamage(dmginfo)
	self:VisualEffect()
end

function ENT:VisualEffect()
	local effectData = EffectData();	
	effectData:SetStart(self:GetPos())
	effectData:SetOrigin(self:GetPos())
	effectData:SetScale(8);	
	util.Effect("GlassImpact", effectData, true, true)
	self:Remove()
end

function ENT:Use(act, caller)
	--Shift + E = Upright
	if caller:KeyDown(IN_SPEED) and self.angleResetCooldown < CurTime() then
		self:SetAngles(Angle(0,caller:GetAngles().y - 180,0))
		self.angleResetCooldown = CurTime() + 1
		self:GetPhysicsObject():Wake()
	end
end