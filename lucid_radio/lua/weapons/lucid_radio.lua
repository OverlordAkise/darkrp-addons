--Lucid's Radio
--Made by OverlordAkise

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Lucid's Radio"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
 
SWEP.Author = "OverlordAkise"
SWEP.Contact = "OverlordAkise@Steam"
SWEP.Purpose = "Contact others of your faction!"
SWEP.Instructions = "LMB to activate, RMB to deactivate"
 
--The category that you SWep will be shown in, in the Spawn (Q) Menu 
--(This can be anything, GMod will create the categories for you)
SWEP.Category = "Category"
 
SWEP.Spawnable = true -- Whether regular players can see it
SWEP.AdminSpawnable = true -- Whether Admins/Super Admins can see it
 
SWEP.ViewModel = "models/weapons/c_slam.mdl" -- This is the model used for clients to see in first person.
SWEP.WorldModel = "models/weapons/w_slam.mdl" -- This is the model shown to all other clients and in third-person.
 
 
--This determins how big each clip/magazine for the gun is. You can 
--set it to -1 to disable the ammo system, meaning primary ammo will 
--not be displayed and will not be affected.
SWEP.Primary.ClipSize = -1
 
--This sets the number of rounds in the clip when you first get the gun. Again it can be set to -1.
SWEP.Primary.DefaultClip = -1
 
--Obvious. Determines whether the primary fire is automatic. This should be true/false
SWEP.Primary.Automatic = false
 
--Sets the ammunition type the gun uses, see below for a list of types.
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
 
function SWEP:Reload()
  if CLIENT then
    if not self.r or not IsValid(self.r) then
      self.r = Derma_StringRequest(
        "Radio Frequency", 
        "Please set a radio frequency (0-99, whole numbers only)",
        "99",
        function(text) 
          net.Start("lucid_radio_frequency")
            net.WriteString(text)
          net.SendToServer()
        end,
        function(text) end
      )
    end
  end
end
 
function SWEP:Think()
end

function SWEP:Deploy()
  self:SetHoldType("slam")
  return true
end
 

function SWEP:PrimaryAttack()
	if SERVER then
    lucidAddRadioReceiver(self:GetOwner(),true)
  end
end
 

function SWEP:SecondaryAttack()
  if SERVER then
    lucidAddRadioReceiver(self:GetOwner(),false)
  end
end