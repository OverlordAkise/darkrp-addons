--Luctus Treefeller
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Tree"
ENT.PrintName = "Tree"
ENT.Author = ""
ENT.Category = "Treefeller"
ENT.Purpose = "To be cut down with an axe"
ENT.Instructions = "N/A"
ENT.Model = "models/props_foliage/tree_deciduous_01a-lod.mdl"

ENT.Freeze = true
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "HP")
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
    self:SetHP(LUCTUS_TREEFELLER_TREE_HEALTH)
end

function ENT:Use() end
function ENT:Think()end

function ENT:OnTakeDamage(damage)
    local ply = damage:GetAttacker()
    if not IsValid(ply) or not ply:IsPlayer() or not IsValid(ply:GetActiveWeapon()) or not ply:GetActiveWeapon():GetClass() == "weapon_luctus_axe" then return end
    self:SetHP(self:GetHP()-LUCTUS_TREEFELLER_AXE_DAMAGE)
    if self:GetHP() > 0 then return end
    
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetNoDraw(true)
    self:SpawnLogs()
    timer.Simple(LUCTUS_TREEFELLER_TREE_RESPAWNTIME,function()
        if not IsValid(self) then return end
        self:SetNoDraw(false)
        self:SetHP(LUCTUS_TREEFELLER_TREE_HEALTH)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:EmitSound("items/battery_pickup.wav")
        hook.Run("LuctusTreefellerTreeRespawned",self)
    end)
end

function ENT:SpawnLogs()
    for i=1,LUCTUS_TREEFELLER_LOG_COUNT do
        local ent = ents.Create("luctus_log")
        ent:SetPos(self:GetPos()+Vector(0,0,i*60))
        ent:Spawn()
    end
end
