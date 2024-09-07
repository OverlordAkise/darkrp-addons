--Luctus Mining System
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Crafting Table"
ENT.Author = "OverlordAkise"
ENT.Purpose = "crafting table"
ENT.Instructions = "N/A"
ENT.Category = "Luctus Miner"
ENT.Model = "models/props/cs_italy/it_mkt_table2.mdl"

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
    
    function ENT:Use(ply, caller)
        if not ply:IsPlayer() then return end
        net.Start("luctus_miner_craft")
            net.WriteEntity(self)
        net.Send(ply)
    end
    
else
    --CLIENT
    local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
    local color_bg = Color(45,45,45,255)
    local color_white = Color(255,255,255,255)
    function ENT:Draw()
        self:DrawModel()
        if (self:GetPos():Distance(LocalPlayer():GetPos()) > 300) then return end
        local a = Angle(0,0,0)
        a:RotateAroundAxis(Vector(1,0,0),90)
        a.y = LocalPlayer():GetAngles().y - 90
        cam.Start3D2D(self:GetPos() + Vector(0,0,60), a, 0.074)
            draw.RoundedBox(8,-105,-75,210,75,color_bg)
            surface.SetDrawColor(color_bg)
            draw.NoTexture()
            surface.DrawPoly(tri)
            draw.SimpleText("Craftingtable","DermaLarge",0,-40,color_white,1,1)
        cam.End3D2D()
    end
end
