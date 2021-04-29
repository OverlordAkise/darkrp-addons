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
    DarkRP.notify(activator, 3, 5, "[sbox] Drop your confiscated items with your gravity gun in here to sell them!")
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

function ENT:SellItem(ply,entity,price)
  self:ShowSparks()
  ply:addMoney(price)
  DarkRP.notify(ply, 3, 5, "[sbox] You sold it for "..price.."$!")
  entity:Remove()
end

function ENT:StartTouch(entity)
  if(entity:IsPlayer())then return end
  if not entity.lucidConfiscationOwner or not IsValid(entity.lucidConfiscationOwner) then return end
  if(LUCID_CONFBOX_POLICEONLY and not entity.lucidConfiscationOwner:isCP())then return end
  if(entity.GetWeaponClass)then
    if(LUCID_CONFBOX_ITEMS[entity:GetWeaponClass()] ~= nil)then
      print("Selling high wep")
      self:SellItem(entity.lucidConfiscationOwner,entity,LUCID_CONFBOX_ITEMS[entity:GetWeaponClass()])
      return
    end
  end
  if(LUCID_CONFBOX_ITEMS[entity:GetClass()] ~= nil)then
    print("Selling high ent")
    self:SellItem(entity.lucidConfiscationOwner,entity,LUCID_CONFBOX_ITEMS[entity:GetWeaponClass()])
    return
  end
  if(LUCID_CONFBOX_AUTO)then
    for i, item in ipairs(DarkRPEntities) do
      if(entity:GetClass() == item.ent)then
        local price = math.Round(item.price*LUCID_CONFBOX_AUTOPRICE)
        self:SellItem(entity.lucidConfiscationOwner,entity,price)
        return
      end
    end
    if(entity.GetWeaponClass)then
      for i, item in ipairs(CustomShipments) do
        if(entity:GetWeaponClass() == item.entity)then
          local price = math.Round(item.pricesep*LUCID_CONFBOX_AUTOPRICE)
          self:SellItem(entity.lucidConfiscationOwner,entity,price)
          return
        end
      end
    end
  end
end
