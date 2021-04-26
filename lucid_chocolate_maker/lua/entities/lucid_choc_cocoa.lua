AddCSLuaFile()
ENT.Type = 'anim'
 
ENT.PrintName = "Cocoa"
ENT.Category = "Chocolate Maker"
ENT.Author = "OverlordAkise"
ENT.Purpose = "Make Chocolate"
ENT.Instructions = "N/A"
ENT.Model = "models/props_junk/garbage_glassbottle001a.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then 
  function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
    self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
    self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
      phys:Wake()
    end
  end
  
else
  --CLIENT
  function ENT:Draw()
      self:DrawModel() 
  end

end