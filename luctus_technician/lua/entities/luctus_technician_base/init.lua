AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(2000)
    end
end
 
function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not self:GetBroken() then return end
    net.Start("luctus_technician_repair")
        net.WriteEntity(self)
    net.Send(ply)
end

function ENT:Think() end
