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

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.player = nil

if SERVER then

    function ENT:Initialize()
        self:SetModel(self.Model)
        self:SetMaterial(LUCTUS_NLR_MATERIAL)
        self:Activate()
        self.Phys = self:GetPhysicsObject()
        if self.Phys and self.Phys:IsValid() then
            self.Phys:Sleep()
            self.Phys:EnableCollisions(false)
        end
        
        local va, vb = self:GetModelBounds()
        va:Mul(LUCTUS_NLR_SIZE)
        self:SetSolid(SOLID_BBOX)
        self:PhysicsInitSphere(va.x-1, "ice")
        self:SetModelScale(LUCTUS_NLR_SIZE,0.1)
        
        self:SetTrigger(true)
        self:DrawShadow(false)
        self:SetNotSolid(true)
        self:SetNoDraw(false)
    end
      
    function ENT:StartTouch(ent)
        if not self.player or not IsValid(self.player) or self.player ~= ent then return end
        LuctusNLRTakeWeapons(self.player)
    end
      
    function ENT:EndTouch(ent)
        if not self.player or not IsValid(self.player) or self.player ~= ent then return end
        LuctusNLRReturnWeapons(self.player)
    end
      
end

if SERVER then return end
  
function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
    self:SetNoDraw(true)
end
