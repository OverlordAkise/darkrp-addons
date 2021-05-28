AddCSLuaFile();

SWEP.Author			= "Sgt.Val";
SWEP.Instructions	= "Left click to taze\n STATS \n knockoutTime 3sec \n freezeTime 4sec";

SWEP.Spawnable			= true;
SWEP.AdminOnly			= true;
SWEP.UseHands			= true;
SWEP.Category 			= "DefconGaming.net";

SWEP.ViewModel			= "models/defcon/taser/c_taser.mdl";
SWEP.WorldModel 		= "models/defcon/taser/w_taser.mdl";

SWEP.Primary.ClipSize		= 1;
SWEP.Primary.DefaultClip	= 9999;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "none";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Automatic	= false;
SWEP.Secondary.Ammo			= "none";

SWEP.AutoSwitchTo			= false;
SWEP.AutoSwitchFrom			= false;

SWEP.PrintName				= "Taser";
SWEP.Slot					= 1;
SWEP.SlotPos				= 1;
SWEP.DrawAmmo				= false;

function SWEP:Initialize()
	self:SetHoldType( "pistol" );
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_IDLE );
	return true;
end

function SWEP:Holster()
	if( SERVER ) then self:Clean() end;
	 return true;
end

function SWEP:OnRemove()
	if( SERVER ) then self:Clean() end;
	 return true;
end

function SWEP:Reload()
	if( ( self.lastReloaded && self.lastReloaded + 3 > CurTime() ) || self:Clip1() == 1 ) then return; end
	self.lastReloaded = CurTime();

	self:SetNextPrimaryFire( CurTime() + 2.65 );

	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD );
	self.Owner:SetAnimation( PLAYER_RELOAD );


	if( CLIENT ) then return; end
	self.Owner:EmitSound( "weapons/smg1/smg1_reload.wav" );

	timer.Simple( 2.65, function()
		if( IsValid( self ) ) then
			self:SetClip1( 1 );
			self:SendWeaponAnim( ACT_VM_IDLE );
		end
	end );
	return true;
end

function SWEP:Trace()
	local mins = Vector( -20, 0, 0 );
	local maxs = Vector( 20, 0, 0 );
	local startpos = self.Owner:GetPos() + self.Owner:GetForward() * 40 + self.Owner:GetUp() * 60;
	local dir = self.Owner:GetAngles():Forward();
	local len = PEX.Settings.taserDistance;

	local tr = util.TraceHull( {
		start = startpos,
		endpos = startpos + dir * len,
		maxs = maxs,
		mins = mins,
		filter = self.Owner;
	} );

	return tr;
end

function SWEP:Think()
	/*if( self:Clip1() < self.Primary.ClipSize
		&& ( !self.lastAmmo || self.lastAmmo + PEX.Settings.TaserAmmoRecovery < CurTime() ) ) then
		self:SetClip1( self:Clip1() + 1 );
		self.lastAmmo = CurTime();
	end*/

	if( CLIENT ) then
		local tr = self:Trace();
		if( tr.Entity && tr.Entity:IsPlayer() ) then
			self.target = tr.Entity;
		else
			self.target = nil;
		end
	else
		/*if( self.ropeDel && self.ropeDel <= CurTime() ) then
			self:Clean();
		end*/
	end
end

function SWEP:Clean()
	for i, v in pairs( self.tracker or {} ) do
		if( v && IsValid( v ) ) then v:Remove(); end
	end
	self.ropeDel = nil;
end

function SWEP:PrimaryAttack()
	if( !self:CanPrimaryAttack() ) then return; end

	if( self:Clip1() == self.Primary.ClipSize - 1 ) then
		self.lastAmmo = CurTime();
	end

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );

	if( SERVER ) then
		self:Clean();
		self.Owner:EmitSound( "stungun/realtasesound.wav", 100 ,100 );

		local tr = self:Trace();

		self.tracker = self.tracker or {};
		self.tracker[ 1 ] = ents.Create( "stungun_rope" );
		self.tracker[ 1 ]:Spawn();

		self.tracker[ 2 ] = ents.Create( "stungun_rope" );
		self.tracker[ 2 ]:Spawn();

		local bone = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" );
		if( bone ) then
			bone = self.Owner:GetBonePosition( bone );
			self.tracker[ 1 ]:SetPos( bone + self:GetRight() * 10 + self:GetUp() * 3 + self:GetForward() * 15 );
			self.tracker[ 2 ]:SetPos( bone + self:GetRight() * 12 + self:GetUp() * 3 + self:GetForward() * 15 );
		else
			self.tracker[ 1 ]:SetPos( self:GetPos() + self.Owner:GetUp() * 50 );
			self.tracker[ 2 ]:SetPos( self:GetPos() + self.Owner:GetUp() * 50 );
		end

		if( tr.Entity && tr.Entity:IsPlayer() ) then
			local ragdoll = tr.Entity:PEX_Ragdoll( PEX.Settings.knockoutTime, PEX.Settings.freezeTime );
			if( ragdoll && IsValid( ragdoll ) ) then

				self.tracker[ 3 ] = constraint.Rope( ragdoll, self.tracker[ 1 ],
					0, 0, Vector( 1, .1, 0 ),
					Vector( 0, 0, 0 ),
					self:GetPos():Distance( ragdoll:GetPos() ), 0, 10, 1, "cable/blue_elec", false );

				self.tracker[ 4 ] = constraint.Rope( ragdoll, self.tracker[ 2 ],
					0, 0, Vector( 0.1, 0.1, 0 ),
					Vector( 0, 0, 0 ),
					self:GetPos():Distance( ragdoll:GetPos() ), 0, 10, 1, "cable/redlaser", false );
			end
		else
			self.tracker[ 3 ] = ents.Create( "stungun_rope" );
			self.tracker[ 3 ]:Spawn();
			self.tracker[ 3 ]:SetPos( tr.HitPos );

			self.tracker[ 4 ] = ents.Create( "stungun_rope" );
			self.tracker[ 4 ]:Spawn();
			self.tracker[ 4 ]:SetPos( tr.HitPos );

			self.tracker[ 5 ] = constraint.Rope( self.tracker[ 1 ], self.tracker[ 3 ], 0, 0, Vector( 1, .1, 0 ),
				Vector( 0, 0, 0 ),
				self:GetPos():Distance( tr.HitPos ), 20, 0, 1, "cable/blue_elec", false );

			self.tracker[ 6 ] = constraint.Rope( self.tracker[ 2 ], self.tracker[ 4 ], 0, 0, Vector( 0.1, 0.1, 0 ),
				Vector( 0, 0, 0 ),
				self:GetPos():Distance( tr.HitPos ), 20, 0, 1, "cable/redlaser", false );
		end
	end
	self:TakePrimaryAmmo( 1 );
	timer.Simple( 0.5, function()
		if( IsValid( self ) ) then
			self:SendWeaponAnim( ACT_VM_IDLE );
		end
	end );
end

function SWEP:SecondaryAttack()
	if( !IsFirstTimePredicted() ) then
		return;
	end
end

function SWEP:FireAnimationEvent( event )
   return false;
end