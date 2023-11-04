--Luctus Quests
--Made by OverlordAkise

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName= "Quest NPC"
ENT.Author= "OverlordAkise"
ENT.Contact= ""
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Luctus Quests"
ENT.Model = "models/Humans/Group02/male_06.mdl"

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    LuctusQuestsOpenMenu(ply)
end

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:SetBloodColor(BLOOD_COLOR_RED)
    self:SetSolid(SOLID_BBOX)
    self:SetUseType(SIMPLE_USE)

    local p = self:GetPos()
    self:SetPos(p)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

if SERVER then return end

local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
local color_bg = Color(45,45,45,255)
local color_text = Color(255,255,255,255)

function ENT:Draw()
    self:DrawModel()
    if LocalPlayer():GetPos():Distance(self:GetPos()) > 550 then return end
    local a = Angle(0,0,0)
    a:RotateAroundAxis(Vector(1,0,0),90)
    a.y = LocalPlayer():GetAngles().y - 90
    cam.Start3D2D(self:GetPos() + Vector(0,0,80), a , 0.074)
        draw.RoundedBox(8,-125,-75,250,75 , color_bg)
        surface.SetDrawColor(color_bg)
        draw.NoTexture()
        surface.DrawPoly(tri)
        draw.SimpleText(self.PrintName, "DermaLarge", 0, -37, color_text, 1, 1)
    cam.End3D2D()
end
