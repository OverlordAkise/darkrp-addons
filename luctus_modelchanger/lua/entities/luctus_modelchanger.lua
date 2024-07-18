--Luctus Modelchanger
--Made by OverlordAkise

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName = "Modelchanger"
ENT.Author = "OverlordAkise"
ENT.Contact = "OverlordAkise@Steam"
ENT.Purpose = "Change your model"
ENT.Instructions = ""
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Luctus Modelchanger"

ENT.ModelConfig = {}

function ENT:Initialize()
    if CLIENT then return end

    self:SetModel("models/props_wasteland/controlroom_storagecloset001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)     
    self:SetMoveType(MOVETYPE_VPHYSICS)  
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not activator:IsPlayer() then return end
    local newModel = string.lower(self.ModelConfig[team.GetName(activator:Team())])
    if not newModel then
        DarkRP.notify(activator,1,5,"You can't use this in this job!")
        return
    end
    local curModel = string.lower(activator:GetModel())
    if curModel == newModel and activator.lorigModel then
        activator:SetModel(activator.lorigModel)
        activator.lorigModel = nil
        activator.lnewModel = nil
        DarkRP.notify(activator,2,5,"Model reverted")
        return
    end
    if not activator.lorigModel then
        activator.lorigModel = curModel
    end
    DarkRP.notify(activator,0,5,"Model changed")
    activator:SetModel(newModel)
    activator.lnewModel = newModel
end

if SERVER then return end

function ENT:Draw()
    self:DrawModel()
    if (self:GetPos():Distance(LocalPlayer():GetPos()) > 512) then return end
    local pos = self:GetPos() + (self:GetAngles():Forward()*15) + (self:GetAngles():Up() * 30) + (self:GetAngles():Right() *15)
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(),90)
    cam.Start3D2D(pos, ang, 0.4)
    draw.SimpleTextOutlined(self.PrintName, "DermaLarge", 37, 0, Color( 255, 255, 255, 255 ),TEXT_ALIGN_CENTER,2,3,color_black)
    cam.End3D2D()
end
