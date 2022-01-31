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

ENT.HP = 100
ENT.RespawnTime = 120
ENT.logcount = 3

if LUCTUS_TREE_RESPAWNTIME then
  ENT.RespawnTime = LUCTUS_TREE_RESPAWNTIME
end

if LUCTUS_TREE_LOG_COUNT then
  ENT.logcount = LUCTUS_TREE_LOG_COUNT
end

function ENT:SetupDataTables()
  self:NetworkVar("Int", 1, "HP")
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
    self:SetHP(self.HP)
  end
   
  function ENT:Use( activator, caller )
      return
  end
   
  function ENT:Think()
  end
  
  function ENT:OnTakeDamage(damage)
    if IsValid(damage:GetAttacker()) and damage:GetAttacker():IsPlayer() and damage:GetAttacker():GetActiveWeapon():GetClass() == "weapon_luctus_axe" then
      self:SetHP(self:GetHP() - 20)
      if self:GetHP() <= 0 then
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)
        self:SpawnLogs()
        timer.Simple(60,function()
          if not IsValid(self) then return end
          self:SetNoDraw(false)
          self:SetHP(self.HP)
          self:SetCollisionGroup(COLLISION_GROUP_NONE)
        end)
      end
    end
  end
  
  function ENT:SpawnLogs()
    for i=1,self.logcount do
      local ent = ents.Create("luctus_log")
      ent:SetPos(self:GetPos()+Vector(0,0,i*60))
      ent:Spawn()
    end
  end
end
