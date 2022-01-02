--Luctus Treefeller
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Log"
ENT.PrintName = "Log"
ENT.Author = ""
ENT.Category = "Treefeller"
ENT.Purpose = "To be cut down with an axe"
ENT.Instructions = "N/A"
ENT.Model = "models/props_docks/channelmarker_gib01.mdl"

ENT.Freeze = true
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.sellprice = 100

if LUCTUS_TREE_LOG_SELLPRICE then
  ENT.sellprice = LUCTUS_TREE_LOG_SELLPRICE
end

ENT.selltext = "[E] Sell for "..ENT.sellprice.."€"

if LUCTUS_TREE_LOG_TEXT then
  ENT.selltext = string.Replace(LUCTUS_TREE_LOG_TEXT,"$SELLPRICE$",ENT.sellprice)
end

ENT.soldtext = "You got "..ENT.sellprice.."$ by selling wood."

if LUCTUS_TREE_LOG_SOLD_TEXT then
  ENT.soldtext = string.Replace(LUCTUS_TREE_LOG_SOLD_TEXT,"$SELLPRICE$",ENT.sellprice)
end


function ENT:Draw()
  self:DrawModel()
  local p = self:GetPos()
  local dist = p:Distance(LocalPlayer():GetPos())

  if (dist > 125) then return end
  p.z = p.z + 45
  local ang = self:GetAngles()
  ang:RotateAroundAxis(self:GetAngles():Forward(), 90)
  ang:RotateAroundAxis(self:GetAngles():Up(), 90)
  cam.Start3D2D(p, Angle(0, LocalPlayer():EyeAngles().y - 90, 90), 0.4)
    draw.SimpleTextOutlined(self.selltext, "Trebuchet24", 0, 0, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0,0,0,255))
  cam.End3D2D()
end

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
  end
   
  function ENT:Think()
  end
  
  function ENT:Use( act, call )
    act:addMoney(self.sellprice)
    DarkRP.notify(act, 2, 3, self.soldtext)
    self:Remove()
  end
end
