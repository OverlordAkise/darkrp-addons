-- Please DO NOT Re-upload this addon --



local meta = FindMetaTable( "Player" );



// tazer
function meta:PEX_Ragdoll( duration, freezeTime, bean )
	if( IsValid( self.__PEXRagdoll ) ) then
		self.__PEXRagdoll:Remove();
	end

	local ragdoll = ents.Create( "prop_ragdoll" );
	ragdoll.__PEXPlayer = self;
	self.__PEXRagdoll = ragdoll;
	ragdoll:SetPos( self:GetPos() );
	if( bean ) then
		ragdoll:SetPos( self:GetPos() - Vector( 0, 0, 20 ) );
	end
	ragdoll:SetAngles( self:GetAngles() );
	ragdoll:SetModel( self:GetModel() );
	ragdoll:SetSkin( self:GetSkin() );
	ragdoll:SetColor( self:GetColor() );
  ragdoll.lplyHP = self:Health()
  ragdoll.lplyArmor = self:Armor()
  ragdoll.lweapons = self:GetWeapons()
	ragdoll:Spawn();
	ragdoll:Activate();
	ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );

	self:SetParent( ragdoll );
	self:DeleteOnRemove( ragdoll );

	for i, v in pairs( self:GetBodyGroups() ) do
		ragdoll:SetBodygroup( v.id, self:GetBodygroup( v.id ) );
	end

	local velocity = self:GetVelocity();
	velocity = Vector(
		math.Clamp( velocity.x, -5000, 5000 ),
		math.Clamp( velocity.y, -5000, 5000 ),
		math.Clamp( velocity.z, -5000, 5000 )
	);

	local id = 1;
	while( true ) do
		local phys = ragdoll:GetPhysicsObjectNum( id );
		id = id + 1;

		if( IsValid( phys ) ) then
			phys:SetVelocity( velocity );
		else
			break;
		end
	end

	self.__PEXRagdollData = { hp = self:Health(), armor = self:Armor(), weapons = {}, model = self:GetModel() };
	for i, v in pairs( self:GetWeapons() ) do
		table.insert( self.__PEXRagdollData.weapons, v:GetClass() );
	end

	self:Spectate( OBS_MODE_CHASE );
	self:SpectateEntity( ragdoll );
	self:StripWeapons();

	if( duration ) then
		timer.Create( "PEX::Ragdoll::" .. self:EntIndex(), duration, 1, function()
			if( IsValid( self ) ) then
				self:PEX_UnRagdoll( freezeTime );
			end
		end );
	end

	return ragdoll;
end

function meta:PEX_UnRagdoll( freezeTime )
	timer.Destroy( "PEX::Ragdoll::" .. self:EntIndex() );

	local ragdoll = self.__PEXRagdoll;
	local data = self.__PEXRagdollData or {};
	self:SetParent();
	self:UnSpectate();
	self:Spawn();
  self:SetHealth( data.hp or 10 );
	self:SetArmor( data.armor or 0 );
  for k,v in pairs(data.weapons) do
    self:Give(v)
  end
	if( data.model ) then
		self:SetModel( data.model );
	end
	if( data.model ) then
		self:SetModel( data.model );
	end

	if( freezeTime ) then
		self:Freeze( true );
		timer.Simple( freezeTime, function()
			if( IsValid( self ) ) then
				self:Freeze( false );
			end
		end );
	end

	if( !IsValid( ragdoll ) ) then
		return;
	end

	local y = ragdoll:GetAngles().y;
	self:SetAngles( Angle( 0, yaw, 0 ) );
	self:SetPos( ragdoll:GetPos() + Vector( 0, 0, 2 ) );
	self:SetVelocity( ragdoll:GetVelocity() );
	ragdoll:Remove();
end