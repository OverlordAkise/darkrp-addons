--Luctus Camera
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Name = "Camera"
ENT.PrintName = "Camera"
ENT.Author = "OverlordAkise"
ENT.Category = "Luctus Camera"
ENT.Purpose = "Camera to be placed with luctus_camera"
ENT.Instructions = "-"
ENT.Model = "models/dav0r/camera.mdl"

ENT.Freeze = true

ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:DrawShadow(false)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(1000)
        phys:Sleep()
    end
end

function ENT:Use() end

function ENT:Think() end

function ENT:OnTakeDamage() end
