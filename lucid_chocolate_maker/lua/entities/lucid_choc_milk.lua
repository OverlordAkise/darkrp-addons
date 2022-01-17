--Made by D34THC47
--https://steamcommunity.com/sharedfiles/filedetails/?id=2195413561
--Stupidly rewritten by OverlordAkise (has alzheimers)

AddCSLuaFile()
ENT.Type = 'anim'
 
ENT.PrintName = "Milk"
ENT.Category = "Chocolate Maker"
ENT.Author = "OverlordAkise"
ENT.Purpose = "Make Chocolate"
ENT.Instructions = "N/A"
ENT.Model = "models/props_junk/garbage_milkcarton002a.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = true

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
  end
  
else
  --CLIENT
  function ENT:Draw()
      self:DrawModel() 
  end

end