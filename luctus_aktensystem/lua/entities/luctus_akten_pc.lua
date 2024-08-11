--Luctus Aktensystem
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Report PC"
ENT.Author = "OverlordAkise"
ENT.Purpose = "Press E to open the menu"
ENT.Instructions = "N/A"
ENT.Category = "Luctus Aktensystem"
ENT.Model = "models/props_lab/monitor02.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then 
    function ENT:Initialize()
        self:SetModel(self.Model)
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
        net.Start("luctus_aktensys") net.Send(activator)
    end
else
    --CLIENT
    local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
    local color_bg = Color(45,45,45,255)
    local color_white = Color(255,255,255,255)
    local offset = Vector(0,0,30)
    local rv1 = Vector(1,0,0)
    function ENT:Draw()
        self:DrawModel()
        if (self:GetPos():Distance(LocalPlayer():GetPos()) > 300) then return end
        local a = Angle(0,0,0)
        a:RotateAroundAxis(rv1,90)
        a.y = LocalPlayer():GetAngles().y - 90
        cam.Start3D2D(self:GetPos() + offset, a, 0.074)
            draw.RoundedBox(8,-105,-75,210,75,color_bg)
            surface.SetDrawColor(color_bg)
            draw.NoTexture()
            surface.DrawPoly(tri)
            draw.SimpleText(LUCTUS_AKTENSYS_TITLE,"DermaLarge",0,-40,color_white,1,1)
        cam.End3D2D()
    end
end
