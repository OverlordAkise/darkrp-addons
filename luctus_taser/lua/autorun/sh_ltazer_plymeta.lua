--Luctus Taser
--Made by OverlordAkise

local meta = FindMetaTable( "Player" )

function meta:luctusRagdoll(duration)
	if IsValid(self.luctusRagdollEnt) then
		self.luctusRagdollEnt:Remove()
	end

	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.__PEXPlayer = self
	self.luctusRagdollEnt = ragdoll
	ragdoll:SetPos( self:GetPos() )
	ragdoll:SetAngles(self:GetAngles())
	ragdoll:SetModel(self:GetModel())
	ragdoll:SetSkin(self:GetSkin())
	ragdoll:SetColor(self:GetColor())
	ragdoll:Spawn()
	ragdoll:Activate()
	ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	self:SetParent( ragdoll )
	self:DeleteOnRemove( ragdoll )

	for i, v in pairs( self:GetBodyGroups() ) do
		ragdoll:SetBodygroup( v.id, self:GetBodygroup( v.id ) )
	end

	local velocity = self:GetVelocity()
  velocity:Normalize()
  velocity:Mul(100)

  for i=0, ragdoll:GetPhysicsObjectCount() - 1 do
    local phys = ragdoll:GetPhysicsObjectNum(i)
    if not IsValid(phys) then break end
    phys:SetVelocity( velocity )
  end

	self.luctusRagdollEntData = { hp = self:Health(), armor = self:Armor(), weapons = {}, model = self:GetModel(), godmode = self:HasGodMode() }
	for i, v in pairs( self:GetWeapons() ) do
		table.insert( self.luctusRagdollEntData.weapons, v:GetClass() )
	end

	self:Spectate( OBS_MODE_CHASE )
	self:SpectateEntity( ragdoll )
	self:StripWeapons()

  timer.Create( "ltazer_ragdoll_" .. self:EntIndex(), LTAZER_STUNTIME, 1, function()
    if( IsValid( self ) ) then
      self:luctusUnRagdoll()
    end
  end)

	return ragdoll
end

function meta:luctusUnRagdoll()
	timer.Destroy( "ltazer_ragdoll_" .. self:EntIndex() )

	local ragdoll = self.luctusRagdollEnt
	local data = self.luctusRagdollEntData or {}
	self:SetParent()
	self:UnSpectate()
	self:Spawn()
  self:SetHealth(data.hp or 10)
	self:SetArmor(data.armor or 0)
  
  for k,v in pairs(data.weapons) do
    self:Give(v)
  end

	if data.model then
		self:SetModel( data.model )
	end

	if( LTAZER_FREEZETIME > 0 ) then
		self:Freeze( true )
		timer.Simple( LTAZER_FREEZETIME, function()
			if IsValid( self ) then
				self:Freeze( false )
			end
		end)
  end

  --DarkRP "babygod" kills godmode after spawning, workaround:
  if data.godmode then
    if GAMEMODE.Config.babygodtime then
      timer.Simple(GAMEMODE.Config.babygodtime+0.1,function()
        self:GodEnable()
      end)
    else
      self:GodEnable()
    end
  end

	if IsValid( ragdoll ) then
		local y = ragdoll:GetAngles().y
    self:SetAngles( Angle( 0, yaw, 0 ) )
    self:SetPos( ragdoll:GetPos() + Vector( 0, 0, 2 ) )
    self:SetVelocity( ragdoll:GetVelocity() )
    ragdoll:Remove()
	end
end
