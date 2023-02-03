--Simple Medic NPC
--Made by OverlordAkise

AddCSLuaFile()

ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName= "Medic NPC"
ENT.Author= "OverlordAkise"
ENT.Contact= "OverlordAkise@Steam"
ENT.Purpose= ""
ENT.Instructions= ""
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.Category = "Medic"

chef_medic_hp = {
  [25] = 2500,
  [50] = 5000,
  [100] = 10000,
}

if SERVER then
  util.AddNetworkString("luctus_medic_npc")
  net.Receive("luctus_medic_npc",function(len,ply)
    local mednpc = net.ReadEntity()
    if mednpc:GetPos():DistToSqr(ply:GetPos()) >= 500*500 then return end
    if ply:Health() >= ply:GetMaxHealth() then
      DarkRP.notify(ply,1,4,"You already have full HP!")
      return
    end
    local option = net.ReadInt(16)
    if not chef_medic_hp[option] then return end
    if not ply:canAfford(chef_medic_hp[option]) then
      DarkRP.notify(ply,1,4,"You can't afford this!")
      return
    end
    ply:addMoney(-chef_medic_hp[option])
    ply:SetHealth(math.min(ply:Health()+option,ply:GetMaxHealth()))
  end)
end

function ENT:Initialize()
	if CLIENT then return end
  
	self:SetModel("models/Humans/Group03m/Female_02.mdl")
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
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		net.Start("luctus_medic_npc")
      net.WriteEntity(self)
    net.Send(activator)
	end
end

if ( SERVER ) then return end

surface.CreateFont("ChefsFancyFont", {font = "Tahoma", size = 55, weight = 1000, blursize = 0, scanlines = 0})

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

    draw.SimpleText("Medic","ChefsFancyFont",0,-40,color_white , 1 , 1)
  cam.End3D2D()
  end
end

surface.CreateFont("Font", {font = "Arial",extended = false,size = 30,})

net.Receive("luctus_medic_npc",function()
  if IsValid(MedicPanel) then return end
  local ent = net.ReadEntity()
  local faded_black = Color(0, 0, 0, 200)
  MedicPanel = vgui.Create("DFrame")
  MedicPanel:SetSize(500, 310)
  MedicPanel:Center()
  MedicPanel:SetTitle("")
  --MedicPanel:SetDraggable(false)
  MedicPanel:ShowCloseButton(false)
  MedicPanel:MakePopup()
  MedicPanel.Paint = function(self, w, h)
    draw.RoundedBox(2, 0, 0, w, h, faded_black)
    draw.RoundedBox(0, 0, 0, w, 22, Color(0,0,0,240))
    draw.SimpleText("MEDIC SHOP", "Trebuchet24", w/2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  
  local parent_x, parent_y = MedicPanel:GetSize()

  local CloseButton = vgui.Create( "DButton", MedicPanel )
  CloseButton:SetText( "" )
  CloseButton:SetPos( parent_x-22, 0 )
  CloseButton:SetSize( 22, 22 )
  CloseButton.DoClick = function()
    MedicPanel:Close()
  end
  CloseButton.Paint = function(self, w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(200,10,10,225))
  end
  
  local DScrollPanel = vgui.Create("DScrollPanel", MedicPanel)
  DScrollPanel:Dock(FILL)
  
  local i = 0
  for k,v in pairs(chef_medic_hp) do
    local BuyButton = DScrollPanel:Add("DButton")
    BuyButton:SetText("")
    BuyButton.mid = k
    BuyButton:SetPos(10,(40*i)+(i*5))
    BuyButton:SetSize(450,40)
    BuyButton.Paint = function(self, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(255,255,255,230))
      draw.SimpleText(k.." HP", "Font", 5, 0+h/2-13, color_black, TEXT_ALIGN_LEFT)
      draw.SimpleText(v, "Font", w-5, 0+h/2-13, color_black, TEXT_ALIGN_RIGHT)
    end
    BuyButton.DoClick = function(self)
      net.Start("luctus_medic_npc")
        net.WriteEntity(ent)
        net.WriteInt(self.mid,16)
      net.SendToServer()
      MedicPanel:Remove()
    end
    i = i + 1
  end
  
end)
