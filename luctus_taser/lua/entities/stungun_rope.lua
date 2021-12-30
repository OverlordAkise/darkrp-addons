--Luctus Taser
--Made by OverlordAkise

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "TazerRopes"
ENT.Author = "SgtSGt & OverlordAkise"
ENT.Spawnable = false

function ENT:Draw()
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/hunter/plates/plate.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetColor( Color( 0, 0, 0, 0 ) )
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self:SetGravity( 0 )
		local phys = self:GetPhysicsObject()
		phys:Wake()
		phys:SetMass( 1 )
	end
end
