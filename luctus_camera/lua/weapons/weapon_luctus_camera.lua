--Luctus Camera
--Made by OverlordAkise

AddCSLuaFile()

SWEP.PrintName = "Placeable Camera"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Author = "OverlordAkise"
SWEP.Instructions = "Place cameras"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.Category = "Luctus Camera"

SWEP.ViewModel  = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/dav0r/camera.mdl"

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
SWEP.csmodel = nil

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Deploy()
    if SERVER then return true end
    if not self.csmodel then
        self.csmodel = ClientsideModel("models/dav0r/camera.mdl")
        self.csmodel:SetMaterial("models/wireframe")
        self.csmodel:SetNoDraw(true)
    end
    hook.Add("PostDrawOpaqueRenderables","luctus_camera_preview",function()
        if not IsValid(self.csmodel) then return end
        self.csmodel:SetPos(self:GetOwner():GetEyeTrace().HitPos)
        self.csmodel:SetAngles(self:GetOwner():GetAimVector():GetNegated():Angle())
        self.csmodel:DrawModel()
    end)
    return true
end

function SWEP:Holster()
    if SERVER then return true end
    hook.Remove("PostDrawOpaqueRenderables","luctus_camera_preview")
    hook.Remove("HUDPaint","luctus_camera_preview")
    return true
end
function SWEP:OnRemove() return true end

function SWEP:Think() end

function SWEP:PrimaryAttack()
    if CLIENT then return end
    if LUCTUS_CAMERA_PLACEABLE <= 0 then
        if SERVER then DarkRP.notify(self:GetOwner(),1,5,"You can not place any more cameras!") end
        return
    end
    local angVec = self:GetOwner():GetAimVector():GetNegated()
    local ang = angVec:Angle()
    local pos = self:GetOwner():GetEyeTrace().HitPos+angVec
    local cent = ents.Create("luctus_camera")
    cent:SetPos(pos)
    cent:SetAngles(ang)
    cent:Spawn()
    LUCTUS_CAMERA_PLACEABLE = LUCTUS_CAMERA_PLACEABLE - 1
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    local ent = self:GetOwner():GetEyeTrace().Entity
    if IsValid(ent) and ent:GetClass() == "luctus_camera" then
        ent:Remove()
        LUCTUS_CAMERA_PLACEABLE = LUCTUS_CAMERA_PLACEABLE + 1
    end
end

function SWEP:Reload() end

function SWEP:FireAnimationEvent() return true end
function SWEP:ShouldDrawViewModel() return false end

if SERVER then return end



function SWEP:Think() end

function SWEP:DrawHUD()
    draw.SimpleTextOutlined("Leftclick = place camera", "DermaLarge", 10, ScrH()/2.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
    draw.SimpleTextOutlined("Rightclick = retrieve camera", "DermaLarge", 10, ScrH()/2.5+40, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
    draw.SimpleTextOutlined("Reload = Toggle preview", "DermaLarge", 10, ScrH()/2.5+80, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
end

local pos = Vector(0,0,0)
local ang = Vector(0,0,0)
local old = nil
function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if not self.cd then self.cd = 0 end
    if self.cd >= CurTime() then return end
    self.cd = CurTime()+0.3
    if self.Previewing then
        hook.Remove("HUDPaint","luctus_camera_preview")
        self.Previewing = false
    else
        hook.Add("HUDPaint","luctus_camera_preview",function()
            old = DisableClipping(true)
            ang = LocalPlayer():GetAimVector():GetNegated()
            pos = LocalPlayer():GetEyeTrace().HitPos+ang
            render.RenderView( {
                origin = pos,
                angles = ang:Angle(),
                x = ScrW()-640, y = 0,
                w = 640, h = 360
            } )
            DisableClipping(old)
        end)
        self.Previewing = true
    end
end

function SWEP:ShouldDrawViewModel() return false end
function SWEP:DrawWorldModel()
    local bi = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
    if not bi then return end
    local bpos,bang = self:GetOwner():GetBonePosition(bi)
    bang:RotateAroundAxis(bang:Forward(),100)
    bpos = bpos + bang:Forward()*6 + bang:Right()*1 + bang:Up()*8
    self:SetRenderOrigin(bpos)
    self:SetRenderAngles(bang)
    self:SetModelScale(0.7,0)
    self:DrawModel()
end
