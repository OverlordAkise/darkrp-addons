--Luctus Radio
--Made by OverlordAkise

SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Luctus Radio"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.UseHands = true

SWEP.Author = "OverlordAkise"
SWEP.Contact = "OverlordAkise@Steam"
SWEP.Purpose = "Contact others of your faction!"
SWEP.Instructions = "LMB to activate, RMB to deactivate"

SWEP.Category = "Radiosystem"
 
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
 
SWEP.ViewModel = "models/radio/c_radio.mdl"
SWEP.WorldModel = "models/radio/w_radio.mdl"
 

SWEP.Primary.ClipSize = -1
 
SWEP.Primary.DefaultClip = -1
 
SWEP.Primary.Automatic = false
 
SWEP.Primary.Ammo = "none"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.frequency = 99
SWEP.isOn = false

if CLIENT then
    function SWEP:Initialize()
        deviceScreen = vgui.Create("DFrame")
        deviceScreen:SetSize( 157, 60 )
        deviceScreen:SetDraggable( false )
        deviceScreen:ShowCloseButton( false )
        deviceScreen:SetTitle("")
        deviceScreen:SetPos( 0, 0 )
        deviceScreen:SetPaintedManually( true )

        surface.CreateFont( "ScreenFont", {
            font = "Arial",
            size = 22,
            weight = 400,
            antialias = true
        })

        textScreen = vgui.Create("DLabel", deviceScreen)
        textScreen:SetText("")
        textScreen:SetFont("ScreenFont")
        textScreen:SizeToContents()
        textScreen:SetWidth(130)
        textScreen:SetWrap( true )
        textScreen:SetTextColor( Color( 255, 255, 255, 255 ) )
        textScreen:Center()
        return true
    end
end

function SWEP:Reload()
    if CLIENT then
        if not self.r or not IsValid(self.r) then
            self.r = Derma_StringRequest(
                "Radio Frequency", 
                "Please set a radio frequency (any number)",
                "99",
                function(text)
                    if not tonumber(text) then return end
                    if tonumber(text) > 99999 or tonumber(text) < 0 or tonumber(text) % 1 ~= 0 then
                        surface.PlaySound( "buttons/combine_button1.wav" )
                        notification.AddLegacy("Please enter a whole number between 0 and 99999!", NOTIFY_ERROR, 5 )
                        return
                    end
                    net.Start("luctus_radio_frequency")
                    net.WriteString(text)
                    net.SendToServer()
                    self.frequency = tonumber(text)
                end,
                function(text) end
            )
        end
    end
end
 
function SWEP:Think()
    if not deviceScreen then return end
    deviceScreen.Paint = function()
        if self.isOn then --radio on
            draw.RoundedBox( 8, 0, 0, deviceScreen:GetWide(), deviceScreen:GetTall(), Color(0,255,19) )
        else
            draw.RoundedBox( 8, 0, 0, deviceScreen:GetWide(), deviceScreen:GetTall(), Color(20,20,20) )
        end
    end
end

function SWEP:PostDrawViewModel(vm, wep, ply)
	if IsValid(vm) then
		local BoneIndx = vm:LookupBone("ValveBiped.Bip01_R_Hand")
		local BonePos, BoneAng = vm:GetBonePosition( BoneIndx )
		TextPos = BonePos + BoneAng:Forward( ) * 5.18 + BoneAng:Right( ) * 3.9 + BoneAng:Up( ) * -4.21
		TextAngle = BoneAng
		TextAngle:RotateAroundAxis(TextAngle:Right(), 185)
		TextAngle:RotateAroundAxis(TextAngle:Up(), -2)
		TextAngle:RotateAroundAxis(TextAngle:Forward( ), 95)
		if self.isOn then --radio on
			textScreen:SetText("Freq.: "..self.frequency)
		else --radio off
			textScreen:SetText(" ")
		end
		cam.Start3D2D(TextPos, TextAngle, 0.015)
			deviceScreen:PaintManual()
		cam.End3D2D()
	end
end

function SWEP:Deploy()
    self:SetHoldType("slam")
    return true
end
 

function SWEP:PrimaryAttack()
    if SERVER then
        LuctusRadioToggle(self:GetOwner(),true)
    end
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.isOn = true
    self:SetNextPrimaryFire( CurTime() + 1 )
    self:SetNextSecondaryFire( CurTime() + 1 )
end
 

function SWEP:SecondaryAttack()
    if SERVER then
        LuctusRadioToggle(self:GetOwner(),false)
    end
    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.isOn = false
    self:SetNextPrimaryFire( CurTime() + 1 )
    self:SetNextSecondaryFire( CurTime() + 1 )
end
