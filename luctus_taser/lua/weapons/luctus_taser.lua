--Luctus Taser
--Made by OverlordAkise

AddCSLuaFile()

SWEP.reloadTime = 2.2

SWEP.Author = "OverlordAkise"
SWEP.Instructions = "Leftclick to taze"

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.UseHands = true
SWEP.Category = "Taser"

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 9999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "tazer"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "tazer"

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.PrintName = "Tazer"
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = false

SWEP.reloaded = 0
SWEP.tracker = {}

function SWEP:Initialize()
    self:SetHoldType("pistol")
    self:SetMaterial("phoenix_storms/stripes")
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    self:Clean()
    return true
end

function SWEP:OnRemove()
    self:Clean()
    return true
end

function SWEP:Reload()
    if self:Clip1() == 1 then return end
    if self.reloaded > CurTime() then return end
    self.reloaded = CurTime() + self.reloadTime
    self:SetNextPrimaryFire(CurTime() + self.reloadTime)

    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)
    self:EmitSound("Weapon_Pistol.Reload")
    
    if CLIENT then return end
    timer.Simple(self.reloadTime-0.1, function()
        if not IsValid(self) then return end
        self:SetClip1(1)
        self:SendWeaponAnim(ACT_VM_IDLE)
    end)
    return true
end

function SWEP:Trace()
    local owner = self:GetOwner()
    local startpos = owner:GetPos() + owner:GetForward() * 40 + owner:GetUp() * 60
    local tr = util.TraceHull({
        start = startpos,
        endpos = startpos + owner:GetAngles():Forward() * LUCTUS_TASER_MAXRANGE,
        maxs = Vector(20,0,0),
        mins = Vector(-20,0,0),
        filter = owner
    })
    return tr
end

function SWEP:Think() end

function SWEP:Clean()
    if CLIENT then return end
    for i,ent in pairs(self.tracker) do
        if IsValid(ent) then 
            ent:Remove()
        end
    end
    self.tracker = {}
end

local zerovec = Vector(0,0,0)
function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
    local owner = self:GetOwner()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    owner:SetAnimation(PLAYER_ATTACK1)
    self:TakePrimaryAmmo(1)
    self:EmitSound(LUCTUS_TASER_SHOTSOUND,100,100)
    self:Clean()
    
    if CLIENT then return end

    local tr = self:Trace()
    local spos = self:GetPos()

    self.tracker = self.tracker or {}
    self.tracker[1] = ents.Create("luctus_stungun_rope")
    self.tracker[1]:Spawn()

    self.tracker[2] = ents.Create("luctus_stungun_rope")
    self.tracker[2]:Spawn()

    local bone = owner:LookupBone("ValveBiped.Bip01_R_Hand")
    if bone then
        bone = owner:GetBonePosition(bone)
        self.tracker[1]:SetPos(bone + self:GetRight() * 10 + self:GetUp() * 3 + self:GetForward() * 15)
        self.tracker[2]:SetPos(bone + self:GetRight() * 12 + self:GetUp() * 3 + self:GetForward() * 15)
    else
        self.tracker[1]:SetPos(spos + owner:GetUp() * 50)
        self.tracker[2]:SetPos(spos + owner:GetUp() * 50)
    end
    
    --Hit player, attach to its ragdoll
    if tr.Entity and IsValid(tr.Entity) and tr.Entity:IsPlayer() then
        local ragdoll = LuctusTazerRagdoll(tr.Entity,owner)
        if not ragdoll or not IsValid(ragdoll) then return end

        self.tracker[3] = constraint.Rope(ragdoll, self.tracker[1], 0, 0, zerovec, zerovec, spos:Distance(ragdoll:GetPos()), 0, 10, 1, "cable/blue_elec", false)

        self.tracker[4] = constraint.Rope(ragdoll, self.tracker[2], 0, 0, zerovec, zerovec, spos:Distance(ragdoll:GetPos()), 0, 10, 1, "cable/redlaser", false)
    else --Hit air
        self.tracker[3] = ents.Create("luctus_stungun_rope")
        self.tracker[3]:Spawn()
        self.tracker[3]:SetPos(tr.HitPos)

        self.tracker[4] = ents.Create("luctus_stungun_rope")
        self.tracker[4]:Spawn()
        self.tracker[4]:SetPos(tr.HitPos)

        self.tracker[5] = constraint.Rope(self.tracker[1], self.tracker[3], 0, 0, zerovec, zerovec, spos:Distance( tr.HitPos ), 20, 0, 1, "cable/blue_elec", false)

        self.tracker[6] = constraint.Rope(self.tracker[2], self.tracker[4], 0, 0, zerovec, zerovec, spos:Distance(tr.HitPos), 20, 0, 1, "cable/redlaser", false)
    end
end

function SWEP:SecondaryAttack() end

function SWEP:FireAnimationEvent()
    return true
end

if CLIENT then
    function SWEP:PreDrawViewModel(vm,wep,ply)
        vm:SetMaterial("phoenix_storms/stripes")
    end
    function SWEP:PostDrawViewModel(vm,wep,ply)
        vm:SetMaterial("")
    end
end
