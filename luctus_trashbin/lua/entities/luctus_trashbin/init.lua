--Luctus Trashbin
--Made by OverlordAkise

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(2000)
    end
end
 
function ENT:Use( activator, caller )
    if activator:IsPlayer() then
        DarkRP.notify(activator, 3, 5, "[trashbin] Drop your items onto me to remove them!")
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
    if entity:IsPlayer()then return end
    local class = entity:GetClass()
    if(entity.GetWeaponClass)then
        class = entity:GetWeaponClass()
    end
    --print("Touching class: "..class)
    
    if (LUCTUS_TRASHBIN_WHITELIST and LUCTUS_TRASHBIN_LIST[class]) or (not LUCTUS_TRASHBIN_WHITELIST and not LUCTUS_TRASHBIN_LIST[class]) then
        self:ShowSparks()
        entity:Remove()
        self:EmitSound("physics/concrete/concrete_break"..math.random(2,3)..".wav")
    end
end
