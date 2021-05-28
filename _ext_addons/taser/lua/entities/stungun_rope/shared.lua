ENT.Type = "anim";
ENT.Base = "base_gmodentity";
ENT.PrintName = "SgtSGt";
ENT.Author = "SgtSGt";
ENT.Spawnable = false;

if SERVER then
	AddCSLuaFile();
end

if CLIENT then
	function ENT:Draw()
	--	self:DrawModel()
	end
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/hunter/plates/plate.mdl" );
		self:PhysicsInit( SOLID_VPHYSICS );
		self:SetMoveType( MOVETYPE_VPHYSICS );
		self:SetColor( Color( 0, 0, 0, 0 ) );
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS );
		self:SetSolid( SOLID_VPHYSICS );
		self:DrawShadow( false );
		self:SetGravity( 0 );
		local phys = self:GetPhysicsObject();
		phys:Wake();
		phys:SetMass( 1 );
	end
end


function ENT:SetParentAE(ply)
		self:DrawShadow(false)
		self:SetParent(ply)
		self:Fire("SetParentAttachmentMaintainOffset", "Anim_Attachment_RH", 0.01)
		self:SetSolid(SOLID_NONE)
		self:SetMoveType(MOVETYPE_VPHYSICS)
end

function ENT:SetTarget(ply,dist)
	self:DrawShadow(false)
	self:SetParent(nil)
	self.Target = ply
	self.Distance = dist
	self:SetMoveType(5)
	self:SetSolid(SOLID_NONE)
end

function ENT:SetPoint(vec)
	self.Vec = vec
	self:SetMoveType(5)
	self:SetSolid(SOLID_NONE)
	self.Timer = CurTime()+0.3
	self:SetAngles( (self.Vec - self:GetPos()):Angle())
end

function ENT:Think()
	if IsValid(self.Target) and self.Distance then
		local numb = self.Distance
		local power = 0
		if self.Target:IsPlayer() then numb = 60 power = 1 end
		if self.Target:GetPos():Distance(self:GetPos()) > numb then
		local dist = self.Target:GetPos():Distance(self:GetPos())
			self:SetAngles( (self.Target:GetPos()+Vector(0,0,0) - self:GetPos()):Angle())
			self.Entity:SetLocalVelocity(self:GetForward()*dist*power)
		else
			self.Entity:SetLocalVelocity(Vector(0,0,0))
		end
	elseif self.Vec and self.Timer and CurTime()<self.Timer then
		local dist = self.Vec:Distance(self:GetPos())
		print(dist)

		self.Entity:SetLocalVelocity(self:GetForward()*980)
	elseif self.Timer then
		self:SetMoveType(5)
		self.Entity:SetLocalVelocity(Vector(0,0,0))
		self.Timer = nil
	end
end