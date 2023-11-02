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

function SWEP:Deploy() return true end
function SWEP:Holster() return true end
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

function SWEP:DrawHUD()
    local ent = self.specEntity
    draw.RoundedBox(0,98,48,ScrW()-196,ScrH()-96,color_accent)
    draw.RoundedBox(0,100,50,ScrW()-200,ScrH()-100,color_black)
    if not IsValid(ent) then
        draw.DrawText("<NO VIDEO FEED>", "DermaLarge", ScrW()*0.5, ScrH()*0.5, color_white, TEXT_ALIGN_CENTER)
        return
    end
    if ent:IsPlayer() then
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

function SWEP:PrimaryAttack()
    if SERVER then return end
    self:SwitchCamera(-1)
end

function SWEP:SecondaryAttack()
    if SERVER then return end
    self:SwitchCamera(1)
end

function SWEP:SwitchCamera(num)
    local tab = self:GetCameraEnts()
    if not self.specIndex then self.specIndex = 1 end
    self.specIndex = (self.specIndex+num)%(#tab+1)
    self.specEntity = tab[self.specIndex]
end

function SWEP:GetCameraEnts()
    local tab = {}
    if LUCTUS_CAMERA_BODYCAMS then
        for k,ply in ipairs(player.GetAll()) do
            if ply == LocalPlayer() then continue end
            if not LUCTUS_CAMERA_BODYCAM_JOBS[team.GetName(ply:Team())] then continue end
            table.insert(tab,ply)
        end
    end
    for k,ent in ipairs(ents.FindByClass("luctus_camera")) do
        table.insert(tab,ent)
    end
    return tab
end
