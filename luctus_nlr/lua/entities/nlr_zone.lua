--Luctus NLR
--Made by OverlordAkise

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "nlr_zone"
ENT.Category = "NLR"
ENT.Author = "OverlordAkise"
ENT.Purpose = "NLRE (New Life Rule Enforcement)"
ENT.Instructions = "N/A"
ENT.Model = "models/XQM/Rails/gumball_1.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.sizeMul = LUCTUS_NLR_SIZE
ENT.player = nil

if SERVER then 
  function ENT:Initialize()
    --print(self:GetPos())
    --print(player.GetAll()[1]:GetEyeTrace().HitPos)
    self:SetModel(self.Model)
    self:SetMaterial(LUCTUS_NLR_MATERIAL)
    
    self:Activate()
    

    self.Phys = self:GetPhysicsObject()
    if self.Phys and self.Phys:IsValid() then
      self.Phys:Sleep()
      self.Phys:EnableCollisions( false )
    end
    
    local va, vb = self:GetModelBounds()
    va:Mul(self.sizeMul)
    self:SetSolid( SOLID_BBOX )
    self:PhysicsInitSphere( va.x-1, "ice" )
    self:SetModelScale(self.sizeMul,0.1)
    
    self:SetTrigger( true )
    self:DrawShadow( false )
    self:SetNotSolid( true )
    self:SetNoDraw( false )
  end
  
  function ENT:StartTouch(ent)
    if self.player and IsValid(self.player) then
      luctusTakeWeapons(self.player)
    end
  end
  
  function ENT:EndTouch(ent)
    if self.player and IsValid(self.player) then
      luctusGiveWeaponsBack(self.player)
    end
  end
  
else
  --CLIENT
  function ENT:Draw()
      self:DrawModel()
  end
  function ENT:Initialize()
    self:SetNoDraw(true)
  end
end
