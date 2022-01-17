--Made by D34THC47
--https://steamcommunity.com/sharedfiles/filedetails/?id=2195413561
--Stupidly rewritten by OverlordAkise (has alzheimers)

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.PrintName = "Chocolate"
ENT.Author = "OverlordAkise"
ENT.Purpose = "sell it to WillyWonka"
ENT.Instructions = "N/A"
ENT.Category 		= "Chocolate Maker"
ENT.Model = "models/hunter/plates/plate05x075.mdl"

ENT.sold = false

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then 
  function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetColor(Color(85,37,37,255))
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
      phys:Wake()
    end
    -- Or else it would fall through the stove
    timer.Simple(0,function()
      local phys = self:GetPhysicsObject()
      if (phys:IsValid()) then
        phys:Sleep()
      end
    end)
  end
  function ENT:Use(ply, caller, useType, value)
    if self.sold then return end
    self.sold = true
    if ply.chefChocolate then
      ply.chefChocolate = ply.chefChocolate + 1
    else
      ply.chefChocolate = 1
    end
    DarkRP.notify(ply, 3, 5, "[choc] You now have "..tostring(ply.chefChocolate).." chocolate bars!")
    self:Remove()
  end
else
  --CLIENT
  function ENT:Draw()
      self:DrawModel() 
  end
  
  function ENT:OnRemove()
    self:EmitSound("player/footsteps/chainlink2.wav", 100, 100)
  end

end