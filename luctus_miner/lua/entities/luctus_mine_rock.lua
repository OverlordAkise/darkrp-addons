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
ENT.AdminSpawnable = true
ENT.RespawnTime = LUCTUS_MINE_RESPAWNTIME

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "OreHP")
end

if CLIENT then
    function ENT:Initialize()
    end
    
    --[[
    function ENT:Draw()
        self:DrawModel()
        local p = self:GetPos()
        local dist = p:DistToSqr(LocalPlayer():GetPos())

        if (dist > 125*125) then return end
        p.z = p.z + 45
        local ang = self:GetAngles()
        ang:RotateAroundAxis(self:GetAngles():Forward(), 90)
        ang:RotateAroundAxis(self:GetAngles():Up(), 90)
        --ang:RotateAroundAxis(LocalPlayer():GetAngles():Right(),90)

        cam.Start3D2D(p, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.4)
            draw.RoundedBox(0, -51, 0, 102, 20, Color(255,255,255,255))
            draw.RoundedBox(0, -50, 1, math.max((self:GetOreHP()*100)/LUCTUS_MINE_ROCK_HP,0), 18, Color(0,255,0,255))
        cam.End3D2D()
    end
    --]]
end

if SERVER then
    function ENT:Initialize()
        self:SetModel(self.Model)
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        local phys = self:GetPhysicsObject()
        if (phys:IsValid()) then
            phys:Wake()
        end
        self:SetOreHP(LUCTUS_MINE_ROCK_HP)
    end
   
    function ENT:Use(activator, caller) return end
   
    function ENT:Think() end
  
    function ENT:OnTakeDamage(damage)
        if not IsValid(damage:GetAttacker()) or not damage:GetAttacker():IsPlayer() then return end
        if damage:GetAttacker():GetActiveWeapon():GetClass() != LUCTUS_MINE_PICKAXE_CLASSNAME then return end
        self:SetOreHP(self:GetOreHP() - 10)
        if math.random(1,100) < LUCTUS_MINE_OREPERCENT then return end
        luctusMineGiveOre(damage:GetAttacker())
        --PrintMessage(HUD_PRINTTALK, randomOre["Name"])
        if self:GetOreHP() > 0 then return end
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)
        timer.Simple(LUCTUS_MINE_RESPAWNTIME,function()
            if not IsValid(self) then return end
            self:SetNoDraw(false)
            self:SetOreHP(LUCTUS_MINE_ROCK_HP)
            self:SetCollisionGroup(COLLISION_GROUP_NONE)
        end)
    end
end
