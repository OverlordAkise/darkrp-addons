--Luctus Taser
--Made by OverlordAkise

AddCSLuaFile()

SWEP.Author			= "OverlordAkise"
SWEP.Instructions	= "Leftclick to taze"

SWEP.Spawnable			= true
SWEP.AdminOnly			= true
SWEP.UseHands			= true
SWEP.Category 			= "Taser"

SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel 		= "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 9999
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "tazer"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "tazer"

SWEP.AutoSwitchTo			= false
SWEP.AutoSwitchFrom			= false

SWEP.PrintName				= "Tazer"
SWEP.Slot					= 1
SWEP.SlotPos				= 1
SWEP.DrawAmmo				= false

SWEP.reloaded = 0

function SWEP:Initialize()
	self:SetHoldType("pistol")
  self:SetMaterial("phoenix_storms/stripes")
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	if( SERVER ) then self:Clean() end
	 return true
end

function SWEP:OnRemove()
	if( SERVER ) then self:Clean() end
	 return true
end

function SWEP:Reload()
	if self:Clip1() == 1 then return end
  if self.reloaded > CurTime() then return end
  self.reloaded = CurTime() + 2.2
	self:SetNextPrimaryFire( CurTime() + 2.2 )

	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	self.Owner:SetAnimation( PLAYER_RELOAD )


	if( CLIENT ) then return end
	self.Owner:EmitSound( "Weapon_Pistol.Reload" )

	timer.Simple( 2, function()
		if IsValid( self ) then
			self:SetClip1( 1 )
			self:SendWeaponAnim( ACT_VM_IDLE )
		end
	end)
	return true
end

function SWEP:Trace()
	local mins = Vector( -20, 0, 0 )
	local maxs = Vector( 20, 0, 0 )
	local startpos = self.Owner:GetPos() + self.Owner:GetForward() * 40 + self.Owner:GetUp() * 60
	local dir = self.Owner:GetAngles():Forward()
	local range = LTAZER_MAXRANGE

	local tr = util.TraceHull({
		start = startpos,
		endpos = startpos + dir * range,
		maxs = maxs,
		mins = mins,
		filter = self.Owner
	})

	return tr
end

function SWEP:Think()
end

function SWEP:Clean()
	for i, v in pairs( self.tracker or {} ) do
		if v and IsValid( v ) then 
      v:Remove()
    end
	end
end

function SWEP:PrimaryAttack()
	if( !self:CanPrimaryAttack() ) then return end

	if( self:Clip1() == self.Primary.ClipSize - 1 ) then
		self.lastAmmo = CurTime()
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if( SERVER ) then
		self:Clean()
		self.Owner:EmitSound( "npc/roller/mine/rmine_shockvehicle2.wav", 100 ,100 )

		local tr = self:Trace()

		self.tracker = self.tracker or {}
		self.tracker[ 1 ] = ents.Create( "stungun_rope" )
		self.tracker[ 1 ]:Spawn()

		self.tracker[ 2 ] = ents.Create( "stungun_rope" )
		self.tracker[ 2 ]:Spawn()

		local bone = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
		if( bone ) then
			bone = self.Owner:GetBonePosition( bone )
			self.tracker[ 1 ]:SetPos( bone + self:GetRight() * 10 + self:GetUp() * 3 + self:GetForward() * 15 )
			self.tracker[ 2 ]:SetPos( bone + self:GetRight() * 12 + self:GetUp() * 3 + self:GetForward() * 15 )
		else
			self.tracker[ 1 ]:SetPos( self:GetPos() + self.Owner:GetUp() * 50 )
			self.tracker[ 2 ]:SetPos( self:GetPos() + self.Owner:GetUp() * 50 )
		end

		if tr.Entity and tr.Entity:IsPlayer() then
    
			local ragdoll = tr.Entity:luctusRagdoll()
      
			if ragdoll and IsValid(ragdoll) then

				self.tracker[ 3 ] = constraint.Rope( ragdoll, self.tracker[ 1 ],
					0, 0, Vector( 1, .1, 0 ),
					Vector( 0, 0, 0 ),
					self:GetPos():Distance( ragdoll:GetPos() ), 0, 10, 1, "cable/blue_elec", false )

				self.tracker[ 4 ] = constraint.Rope( ragdoll, self.tracker[ 2 ],
					0, 0, Vector( 0.1, 0.1, 0 ),
					Vector( 0, 0, 0 ),
					self:GetPos():Distance( ragdoll:GetPos() ), 0, 10, 1, "cable/redlaser", false )
			end
		else
			self.tracker[ 3 ] = ents.Create( "stungun_rope" )
			self.tracker[ 3 ]:Spawn()
			self.tracker[ 3 ]:SetPos( tr.HitPos )

			self.tracker[ 4 ] = ents.Create( "stungun_rope" )
			self.tracker[ 4 ]:Spawn()
			self.tracker[ 4 ]:SetPos( tr.HitPos )

			self.tracker[ 5 ] = constraint.Rope( self.tracker[ 1 ], self.tracker[ 3 ], 0, 0, Vector( 1, 0.1, 0 ),
				Vector( 0, 0, 0 ),
				self:GetPos():Distance( tr.HitPos ), 20, 0, 1, "cable/blue_elec", false )

			self.tracker[ 6 ] = constraint.Rope( self.tracker[ 2 ], self.tracker[ 4 ], 0, 0, Vector( 0.1, 0.1, 0 ),
				Vector( 0, 0, 0 ),
				self:GetPos():Distance( tr.HitPos ), 20, 0, 1, "cable/redlaser", false )
		end
	end
	self:TakePrimaryAmmo( 1 )
end

function SWEP:SecondaryAttack()
end

function SWEP:FireAnimationEvent( event )
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
