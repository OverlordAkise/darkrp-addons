--Luctus Safezones
--Made by OverlordAkise

AddCSLuaFile()

SWEP.Author      = "OverlordAkise"
SWEP.Instructions  = "Set Safezones"

SWEP.Spawnable      = true
SWEP.AdminOnly      = true
SWEP.UseHands      = true
SWEP.Category       = "Safezones"

SWEP.ViewModel      = "models/weapons/c_pistol.mdl"
SWEP.WorldModel     = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip  = -1
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo      = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic  = false
SWEP.Secondary.Ammo      = "none"

SWEP.AutoSwitchTo      = false
SWEP.AutoSwitchFrom      = false

SWEP.PrintName        = "SafezoneTool"
SWEP.Slot          = 0
SWEP.SlotPos        = 1
SWEP.DrawAmmo        = false


SWEP.pos_one = nil
SWEP.pos_two = nil
SWEP.window = nil

function SWEP:Initialize()
  self:SetHoldType("pistol")
end

function SWEP:Deploy()
  if SERVER then return true end
  --hook.Add("PreDrawEffects",
  return true
end

function SWEP:Holster()
  if SERVER then return true end

  return true
end

function SWEP:OnRemove()
   return true
end

function SWEP:Reload()
  if SERVER then return end
  if IsValid(self.window) then return end
  self.window = vgui.Create("DFrame")
  self.window:SetTitle("Safezone Menu")
  self.window:SetSize(400,300)
  self.window:ShowCloseButton(false)
  self.window:Center()
  self.window:MakePopup()
  function self.window:Paint(w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
  end
  
  local closeButton = vgui.Create("DButton",self.window)
  closeButton:SetPos(400-32,2)
  closeButton:SetSize(30,20)
  closeButton:SetText("X")
  closeButton:SetTextColor( Color(255,0,0) )
  closeButton.DoClick = function(s)
    self.window:Close()
  end
  function closeButton:Paint(w,h)
    draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
    if (self.Hovered) then
      draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
    end
  end
  
  local helpText = nil
  local text = {"Click to delete!","How To: Go to the safezone you want to delete","click on the one with the smallest distance to you!"}
  for k,v in pairs(text) do
    helpText = vgui.Create("DLabel",self.window)
    helpText:SetFont("Trebuchet18")
    helpText:SetText(v)
    helpText:SetTextColor(Color(0,195,165))
    helpText:SetContentAlignment(5)
    helpText:DockMargin(1,1,1,1)
    helpText:Dock(TOP)
  end

  local DScrollPanel = vgui.Create( "DScrollPanel", self.window )
  DScrollPanel:Dock(FILL)
  
  local safezones = {}
  for i=1,#ents.GetAll() do
    if ents.GetAll()[i]:GetClass() == "luctus_safezone" then
      table.insert(safezones,ents.GetAll()[i])
    end
  end
  
  for k,v in pairs(safezones) do
    local zonebutton = DScrollPanel:Add("DButton")
    zonebutton:SetText("  "..v:GetID().." - Distance to zone: "..v:GetPos():Distance(LocalPlayer():GetPos()))
    zonebutton.id = v:GetID()
    zonebutton.ent = v
    zonebutton:DockMargin(1,1,1,1)
    zonebutton:SetTextColor( Color(255, 255, 255) )
    zonebutton:Dock(TOP)
    zonebutton:SetContentAlignment(4) --middle-left
    zonebutton.DoClick = function(s)
      net.Start("luctus_safezone_delete")
        net.WriteString(s.id)
      net.SendToServer()
      self.window:Close()
    end
    function zonebutton:Paint(w,h)
      draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
      if (self.Hovered) then
        draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
      end
    end
    --[[function zonebutton:Think()
      if not self.cd then self.cd = 0 end
      if self.cd > CurTime() then return end
      self.cd = CurTime() + 1
      self:SetText("   "..self.ent:GetID().." - Distance to zone: "..self.ent:GetPos():Distance(LocalPlayer():GetEyeTrace().HitPos))
    end--]]
  end
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
  self.pos_one = self.Owner:GetEyeTrace().HitPos
end

function SWEP:SecondaryAttack()
  if not self.pos_one then
    self.Owner:PrintMessage(HUD_PRINTTALK, "Please set the first point first! (leftclick)")
    return
  end
  self.pos_two = self.Owner:GetEyeTrace().HitPos
  if CLIENT then return end
  luctusSaveSafezone(self.pos_one, self.pos_two)
  self.pos_one = nil
  self.pos_two = nil
end

function SWEP:FireAnimationEvent( event )
   return true
end

if SERVER then return end

function SWEP:DrawHUD()
  draw.SimpleTextOutlined("Leftclick = place first point", "DermaLarge", 10, ScrH()/2.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
  draw.SimpleTextOutlined("Rightclick = place second point & save", "DermaLarge", 10, ScrH()/2.5+40, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
  draw.SimpleTextOutlined("Reload = Open menu to delete safezones", "DermaLarge", 10, ScrH()/2.5+80, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
end
