--Luctus Mining System
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.PrintName = "Crafting Table"
ENT.Author = ""
ENT.Purpose = "crafting table"
ENT.Instructions = "N/A"
ENT.Category 		= "Simple Miner"
ENT.Model = "models/props/cs_italy/it_mkt_table2.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if SERVER then 
  function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
      phys:Wake()
    end
    self:SetUseType( SIMPLE_USE )
  end
  function ENT:Use( activator, caller )
    if ( activator:IsPlayer() ) then
      net.Start("luctus_mine_craft")
      net.Send(activator)
    end
  end
else
  --CLIENT
  function ENT:Draw()
    self:DrawModel()
    if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 300*300) then return end
    local a = Angle(0,0,0)
    a:RotateAroundAxis(Vector(1,0,0),90)
    a.y = LocalPlayer():GetAngles().y - 90
    cam.Start3D2D(self:GetPos() + Vector(0,0,60), a , 0.074)
      draw.RoundedBox(8,-105,-75,210,75 , Color(45,45,45,255))
      local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
      surface.SetDrawColor(Color(45,45,45,255))
      draw.NoTexture()
      surface.DrawPoly( tri )

      draw.SimpleText("Craftingtable","DermaLarge",0,-40,Color(255,255,255,255) , 1 , 1)
    cam.End3D2D()
  end
end
