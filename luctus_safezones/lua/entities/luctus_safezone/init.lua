--Luctus Safezones
--Made by OverlordAkise

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
    local BBOX = (self.max - self.min) / 2

    self:SetSolid(SOLID_BBOX)
    self:PhysicsInitBox(-BBOX, BBOX)
    self:SetCollisionBoundsWS(self.min, self.max)

    self:SetTrigger(true)
    self:DrawShadow(false)
    self:SetNotSolid(true)
    self:SetNoDraw(false)

    self.Phys = self:GetPhysicsObject()
    if self.Phys and self.Phys:IsValid() then
        self.Phys:Sleep()
        self.Phys:EnableCollisions(false)
    end
end

function ENT:StartTouch(ent)  
    if IsValid(ent) and ent:IsPlayer() then
        luctusEnteredSafezone(ent)
    end
end

function ENT:EndTouch(ent)
    if IsValid(ent) and ent:IsPlayer() then
        luctusLeftSafezone(ent)
    end
end
