--Luctus Mining System
--Made by OverlordAkise

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName= "Miner Sell NPC"
ENT.Author= "OverlordAkise"
ENT.Contact= ""
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Simple Miner"


function ENT:Initialize()
	if CLIENT then return end
  
	self:SetModel("models/Eli.mdl")
	--self:PhysicsInit(SOLID_VPHYSICS)     
	--self:SetMoveType(MOVETYPE_VPHYSICS)
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
  
  luctusRandomNPCPrice(self)
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		net.Start("luctus_mine_npc")
    net.WriteEntity(self)
    net.Send(activator)
	end
end

if ( SERVER ) then return end


function ENT:Draw()
  self:DrawModel()
  if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 300*300) then return end
  local a = Angle(0,0,0)
  a:RotateAroundAxis(Vector(1,0,0),90)
  a.y = LocalPlayer():GetAngles().y - 90
  cam.Start3D2D(self:GetPos() + Vector(0,0,75), a , 0.074)
    draw.RoundedBox(8,-105,-75,210,75 , Color(45,45,45,255))
    local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
    surface.SetDrawColor(Color(45,45,45,255))
    draw.NoTexture()
    surface.DrawPoly( tri )

    draw.SimpleText("Ore Seller","DermaLarge",0,-40,Color(255,255,255,255) , 1 , 1)
  cam.End3D2D()
end
