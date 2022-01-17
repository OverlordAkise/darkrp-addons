--Made by D34THC47
--https://steamcommunity.com/sharedfiles/filedetails/?id=2195413561
--Stupidly rewritten by OverlordAkise (has alzheimers)

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName= "Chocolate NPC"
ENT.Author= "OverlordAkise"
ENT.Contact= ""
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Chocolate Maker"
ENT.Name = "WillyWonka"
ENT.Model = "models/Humans/Group01/male_08.mdl"

ENT.chocWorth = 10000



if SERVER then
  function ENT:Use(ply, caller, useType, value)
    if ply.chefChocolate and ply.chefChocolate > 0 then
      local cn = ply.chefChocolate
      ply.chefChocolate = 0
      ply:addMoney(cn*self.chocWorth)
      self:EmitSound("ambient/levels/labs/coinslot1.wav", 100, 100)
      DarkRP.notify(ply,0,4,"[choc] You sold "..tostring(cn).." bars for "..tostring(cn*self.chocWorth).."$ !")
    else
      DarkRP.notify(ply,1,4,"[choc] You don't have any chocolate bars!")
    end
  end

  function ENT:Initialize()
    
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
end

if ( SERVER ) then return end

function ENT:Draw()
  self:DrawModel()
  if LocalPlayer():GetPos():Distance(self:GetPos()) < 550 then
    local a = Angle(0,0,0)
    a:RotateAroundAxis(Vector(1,0,0),90)
    a.y = LocalPlayer():GetAngles().y - 90
    cam.Start3D2D(self:GetPos() + Vector(0,0,80), a , 0.074)
      draw.RoundedBox(8,-225,-75,450,75 , Color(45,45,45,255))
      local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
      surface.SetDrawColor(Color(45,45,45,255))
      draw.NoTexture()
      surface.DrawPoly( tri )

      draw.SimpleText("Chocolate Buyer","chocolate_font",0,-40,Color(255,255,255,255) , 1 , 1)
    cam.End3D2D()
  end
end
