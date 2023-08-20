--Made by ThatCatGuy
--https://github.com/ThatCatGuy
--https://steamcommunity.com/sharedfiles/filedetails/?id=2195413561
--Stupidly rewritten by OverlordAkise (has alzheimers)

AddCSLuaFile()
ENT.Type = 'anim'
 
ENT.PrintName = "Sugar"
ENT.Category = "Chocolate Maker"
ENT.Author = "OverlordAkise"
ENT.Purpose = "Make Chocolate"
ENT.Instructions = "N/A"
ENT.Model = "models/props_junk/garbage_milkcarton001a.mdl"

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