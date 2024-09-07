--Luctus Mining System
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Name = "Miner Rock"
ENT.PrintName = "Miner Rock"
ENT.Author = "OverlordAkise"
ENT.Category = "Luctus Miner"
ENT.Purpose = "Provide ore"
ENT.Instructions = "Hit to get ore"
ENT.Model = "models/props_wasteland/rockgranite02a.mdl"

ENT.Freeze = true

ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "OreHP")
end


if CLIENT then return end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    self:SetOreHP(LUCTUS_MINER_ROCK_HP)
end

function ENT:Use() end

function ENT:Think() end

function ENT:OnTakeDamage(damage)
    local ply = damage:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if ply:GetActiveWeapon():GetClass() != LUCTUS_MINER_PICKAXE_CLASSNAME then return end
    self:SetOreHP(self:GetOreHP() - 10)
    if math.random(1,100) >= LUCTUS_MINER_OREPERCENT then
        LuctusMinerGiveRandomOre(ply)
    end
    if self:GetOreHP() > 0 then return end
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetNoDraw(true)
    timer.Simple(LUCTUS_MINER_RESPAWNTIME,function()
        if not IsValid(self) then return end
        self:SetNoDraw(false)
        self:SetOreHP(LUCTUS_MINER_ROCK_HP)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        hook.Run("LuctusMinerRockRespawned",self)
    end)
end
