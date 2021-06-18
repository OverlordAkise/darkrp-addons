--Luctus Mining System
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Miner Rock"
ENT.PrintName = "Miner Rock"
ENT.Author = ""
ENT.Category = "Simple Miner"
ENT.Purpose = "Simple Miner"
ENT.Instructions = "N/A"
ENT.Model = "models/props_wasteland/rockgranite02a.mdl"

ENT.Freeze = true

ENT.Spawnable = true
ENT.AdminSpawnable = true

if luctus and luctus.miner_respawn_time then
  ENT.RespawnTime = luctus.miner_respawn_time
else
  ENT.RespawnTime = 120
end
ENT.HP = 200

function ENT:SetupDataTables()
  self:NetworkVar("Int", 1, "OreHP")
end

if CLIENT then
  function ENT:Initialize()
  end

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
      draw.RoundedBox(0, -50, 1, math.max((self:GetOreHP()*100)/self.HP,0), 18, Color(0,255,0,255))
    cam.End3D2D()
  end
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
    self:SetOreHP(self.HP)
  end
   
  function ENT:Use( activator, caller )
      return
  end
   
  function ENT:Think()
  end
  
  function ENT:OnTakeDamage(damage)
    if IsValid(damage:GetAttacker()) and damage:GetAttacker():IsPlayer() then
      self:SetOreHP(self:GetOreHP() - 10)
      if math.random(1,100) < luctus.mine.orePercent then return end
      luctusMineGiveOre(damage:GetAttacker())
      --PrintMessage(HUD_PRINTTALK, randomOre["Name"])
      if self:GetOreHP() <= 0 then
        self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
        self:SetNoDraw(true)
        timer.Simple(60,function()
          if not IsValid(self) then return end
          self:SetNoDraw(false)
          self:SetOreHP(self.HP)
          self:SetCollisionGroup(COLLISION_GROUP_NONE)
        end)
      end
    end
  end
end
