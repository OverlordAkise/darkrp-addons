--Luctus Trashbin
--Made by OverlordAkise

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
  self:SetModel(self.Model)
  self:PhysicsInit( SOLID_VPHYSICS )
  self:SetMoveType( MOVETYPE_VPHYSICS )
  self:SetSolid( SOLID_VPHYSICS )
  self:SetUseType(SIMPLE_USE)
  local phys = self:GetPhysicsObject()
  if (phys:IsValid()) then
    phys:Wake()
    phys:SetMass(2000)
  end
end
 
function ENT:Use( activator, caller )
  if activator:IsPlayer() then
   -- DarkRP.notify(activator, 3, 5, "[trashbin] Touch me with your items to remove them!")
  end
end

function ENT:ShowSparks()
  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetPos())
  effectdata:SetMagnitude(1)
  effectdata:SetScale(1)
  effectdata:SetRadius(2)
  util.Effect("Sparks", effectdata)
end

function ENT:StartTouch(entity)
end

function ENT:Touch(entity)
  local class = entity:GetClass()
  if(entity.GetWeaponClass)then
    class = entity:GetWeaponClass()
  end
  --print("Touching class: "..class)
  if(entity:IsPlayer())then return end
  if(LUCTUS_TRASHBIN_WHITELIST and LUCTUS_TRASHBIN_LIST[class]) or (LUCTUS_TRASHBIN_WHITELIST == false and LUCTUS_TRASHBIN_LIST[class] == nil) then
    self:ShowSparks()
    entity:Remove()
  end
end
