--Luctus Camera
--Made by OverlordAkise

AddCSLuaFile()

SWEP.PrintName = "Camera Viewer"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Author = "OverlordAkise"
SWEP.Instructions = "A tablet to view your cameras"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.Category = "Luctus Camera"

SWEP.ViewModel  = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/props/cs_office/computer_monitor_p2a.mdl"

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

SWEP.specEntity = nil
SWEP.specIndex = nil
local color_accent = Color(0, 195, 165)
local ang = nil
local pos = nil

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Deploy()
    if SERVER then LuctusCameraActivate(self:GetOwner(),true) end
    if CLIENT then hook.Add("ShouldDrawLocalPlayer","luctus_camera",function(ply) return true end) end
    return true
end
function SWEP:Holster()
    if SERVER then LuctusCameraActivate(self:GetOwner(),false) end
    if CLIENT then hook.Remove("ShouldDrawLocalPlayer","luctus_camera") end
    return true
end
function SWEP:OnRemove() return true end
function SWEP:Think() end
function SWEP:Reload() end
function SWEP:FireAnimationEvent() return true end
function SWEP:ShouldDrawViewModel() return false end


function SWEP:DrawWorldModel()
    local bi = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
    if not bi then return end
    local bpos,bang = self:GetOwner():GetBonePosition(bi)
    bang:RotateAroundAxis(bang:Right(),-120)
    bpos = bpos + bang:Forward()*-2 + bang:Right()*7 + bang:Up()*-2
    self:SetRenderOrigin(bpos)
    self:SetRenderAngles(bang)
    self:SetModelScale(0.7,0)
    self:DrawModel()
end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    LuctusCameraSwitch(self:GetOwner(),-1)
    self:SetNextPrimaryFire(CurTime()+0.2)
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    LuctusCameraSwitch(self:GetOwner(),1)
    self:SetNextSecondaryFire(CurTime()+0.2)
end

if SERVER then return end

LUCTUS_CAMERA_ENT = nil
LUCTUS_CAMERA_VEC = nil
LUCTUS_CAMERA_ANG = nil
LUCTUS_CAMERA_TEXT = ""
net.Receive("luctus_camera_pvs",function()
    local isoffline = net.ReadBool()
    if isoffline then
        LUCTUS_CAMERA_ENT = nil
        LUCTUS_CAMERA_VEC = nil
        LUCTUS_CAMERA_ANG = nil
        LUCTUS_CAMERA_TEXT = LUCTUS_CAMERA_TEXT_IF_OFFLINE
        return
    end
    LUCTUS_CAMERA_TEXT = LUCTUS_CAMERA_TEXT_IF_NO_CAMERA_FOUND
    local isent = net.ReadBool()
    local ent = net.ReadEntity()
    local vec = net.ReadVector()
    local ang = net.ReadAngle()
    if not isent then
        LUCTUS_CAMERA_ENT = nil
        LUCTUS_CAMERA_VEC = nil
        LUCTUS_CAMERA_ANG = nil
        return
    end
    if not IsValid(ent) then
        LUCTUS_CAMERA_ENT = nil
        LUCTUS_CAMERA_VEC = vec
        LUCTUS_CAMERA_ANG = ang
        return
    end
    LUCTUS_CAMERA_ENT = ent
end)

function SWEP:DrawHUD()
    local ent = LUCTUS_CAMERA_ENT
    draw.RoundedBox(0,98,48,ScrW()-196,ScrH()-96,color_accent)
    draw.RoundedBox(0,100,50,ScrW()-200,ScrH()-100,color_black)
    if not IsValid(LUCTUS_CAMERA_ENT) and not LUCTUS_CAMERA_VEC then
        draw.DrawText(LUCTUS_CAMERA_TEXT, "DermaLarge", ScrW()*0.5, ScrH()*0.5, color_white, TEXT_ALIGN_CENTER)
        return
    end
    if not IsValid(ent) then
        ang = LUCTUS_CAMERA_ANG
        pos = LUCTUS_CAMERA_VEC
    elseif ent:IsPlayer() then
        ang = ent:GetAimVector():Angle()
        pos = ent:EyePos()+ent:GetAimVector()*5
    else
        ang = ent:GetAngles()
        pos = ent:GetPos()+ang:Forward()*7
    end
    render.RenderView({
        origin = pos,
        angles = ang,
        x = 100, y = 50,
        w = ScrW()-200, h = ScrH()-100,
        drawviewmodel = false,
    })
    draw.DrawText("< Leftclick", "Trebuchet24", 120, ScrH()-100, color_white, TEXT_ALIGN_LEFT)
    draw.DrawText("Rightclick >", "Trebuchet24", ScrW()-100-20, ScrH()-100, color_white, TEXT_ALIGN_RIGHT)
end
