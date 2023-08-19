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
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(2000)
    end
end
 
function ENT:Use(activator, caller)
    if activator:IsPlayer() then
        DarkRP.notify(activator, 3, 5, "[confiscate] Drop your items with your gravity gun in here to sell them!")
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
    DarkRP.notify(ply, 3, 5, "[confiscate] You sold it for "..price.."$")
    hook.Run("LuctusPoliceConfiscationSold",ply,entity,price)
    entity:Remove()
end

function ENT:StartTouch(entity)
    if entity:IsPlayer() then return end
    local ply = entity.luctusConfiscationOwner
    if not ply or not IsValid(ply) then return end
    if LUCTUS_CONFBOX_POLICEONLY and not ply:isCP() then return end
    local class = entity:GetClass()
    if entity.GetWeaponClass then --darkrp weapon
        class = entity:GetWeaponClass()
    end
    if LUCTUS_CONFBOX_ITEMS[class] then
        self:SellItem(ply,entity,LUCTUS_CONFBOX_ITEMS[class])
        return
    end
    if LUCTUS_CONFBOX_F4ALLOWED then
        for i, item in ipairs(DarkRPEntities) do
            if class == item.ent then
                local price = math.Round(item.price*LUCTUS_CONFBOX_F4RATIO)
                self:SellItem(ply,entity,price)
                return
            end
        end
    end
end
