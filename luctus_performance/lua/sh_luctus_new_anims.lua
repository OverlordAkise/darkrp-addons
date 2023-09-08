--Luctus Performance
--Made by OverlordAkise

--[[

Comparison, according to fprofiler

type     runs       total time taken    average time taken
default  665        6.18516             0.00930099
striped  693        3.959110            0.00571300
+tables  669        2.73095             0.0040821375

This version is striped of unnecessary animations + using a table cache instead of ply index

--]]



local plycache = {}

local GAM = gmod.GetGamemode()

function GAM:HandlePlayerJumping( ply, velocity )
	if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then
		plycache[ply].m_bJumping = false
		return
	end

	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	if ( !plycache[ply].m_bJumping && !ply:OnGround() && ply:WaterLevel() <= 0 ) then

		if ( !plycache[ply].m_fGroundTime ) then

			plycache[ply].m_fGroundTime = CurTime()

		elseif ( CurTime() - plycache[ply].m_fGroundTime ) > 0 && velocity:Length2DSqr() < 0.25 then

			plycache[ply].m_bJumping = true
			plycache[ply].m_bFirstJumpFrame = false
			plycache[ply].m_flJumpStartTime = 0

		end
	end

	if plycache[ply].m_bJumping then

		if plycache[ply].m_bFirstJumpFrame then

			plycache[ply].m_bFirstJumpFrame = false
			ply:AnimRestartMainSequence()

		end

		if ( ply:WaterLevel() >= 2 ) || ( ( CurTime() - plycache[ply].m_flJumpStartTime ) > 0.2 && ply:OnGround() ) then

			plycache[ply].m_bJumping = false
			plycache[ply].m_fGroundTime = nil
			ply:AnimRestartMainSequence()

		end

		if plycache[ply].m_bJumping then
			plycache[ply].CalcIdeal = ACT_MP_JUMP
			return true
		end
	end

	return false

end

function GAM:HandlePlayerDucking( ply, velocity )
	if ( !ply:IsFlagSet( FL_ANIMDUCKING ) ) then return false end

	if ( velocity:Length2DSqr() > 0.25 ) then
		plycache[ply].CalcIdeal = ACT_MP_CROUCHWALK
	else
		plycache[ply].CalcIdeal = ACT_MP_CROUCH_IDLE
	end

	return true

end

function GAM:HandlePlayerNoClipping()end

function GAM:HandlePlayerVaulting()end

function GAM:HandlePlayerSwimming()end

function GAM:HandlePlayerLanding()end

function GAM:HandlePlayerDriving()end

--[[---------------------------------------------------------
   Name: gamemode:UpdateAnimation()
   Desc: Animation updates (pose params etc) should be done here
-----------------------------------------------------------]]
function GAM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	local len = velocity:Length()
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( ply:WaterLevel() >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !ply:IsOnGround() && len >= 1000 ) then
		rate = 0.1
	end

	ply:SetPlaybackRate( rate )

	-- We only need to do this clientside..
	if ( CLIENT ) then
		if ( ply:InVehicle() ) then
			--
			-- This is used for the 'rollercoaster' arms
			--
			local Vehicle = ply:GetVehicle()
			local Velocity = Vehicle:GetVelocity()
			local fwd = Vehicle:GetUp()
			local dp = fwd:Dot( Vector( 0, 0, 1 ) )

			ply:SetPoseParameter( "vertical_velocity", ( dp < 0 && dp || 0 ) + fwd:Dot( Velocity ) * 0.005 )

			-- Pass the vehicles steer param down to the player
			local steer = Vehicle:GetPoseParameter( "vehicle_steer" )
			steer = steer * 2 - 1 -- convert from 0..1 to -1..1
			if ( Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then steer = 0 ply:SetPoseParameter( "aim_yaw", math.NormalizeAngle( ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90 ) ) end
			ply:SetPoseParameter( "vehicle_steer", steer )

		end
		GAM:GrabEarAnimation( ply )
		GAM:MouthMoveAnimation( ply )
	end

end

--
-- If you don't want the player to grab his ear in your gamemode then
-- just override this.
--
function GAM:GrabEarAnimation( ply )
	plycache[ply].ChatGestureWeight = plycache[ply].ChatGestureWeight || 0

	-- Don't show this when we're playing a taunt!
	if ( ply:IsPlayingTaunt() ) then return end

	if ( ply:IsTyping() ) then
		plycache[ply].ChatGestureWeight = math.Approach( plycache[ply].ChatGestureWeight, 1, FrameTime() * 5.0 )
	else
		plycache[ply].ChatGestureWeight = math.Approach( plycache[ply].ChatGestureWeight, 0, FrameTime() * 5.0 )
	end

	if ( plycache[ply].ChatGestureWeight > 0 ) then

		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, plycache[ply].ChatGestureWeight )

	end

end

--
-- Moves the mouth when talking on voicecom
--
function GAM:MouthMoveAnimation( ply )
	local flexes = {
		ply:GetFlexIDByName( "jaw_drop" ),
		ply:GetFlexIDByName( "left_part" ),
		ply:GetFlexIDByName( "right_part" ),
		ply:GetFlexIDByName( "left_mouth_drop" ),
		ply:GetFlexIDByName( "right_mouth_drop" )
	}

	local weight = ply:IsSpeaking() && math.Clamp( ply:VoiceVolume() * 2, 0, 2 ) || 0

	for k, v in ipairs( flexes ) do

		ply:SetFlexWeight( v, weight )

	end

end

function GAM:CalcMainActivity( ply, velocity )
    plycache[ply] = plycache[ply] or {}
	plycache[ply].CalcIdeal = ACT_MP_STAND_IDLE
	plycache[ply].CalcSeqOverride = -1
	if ply:IsOnGround() and not plycache[ply].m_bWasOnGround then
        ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
    end
    if not (self:HandlePlayerJumping(ply,velocity) or self:HandlePlayerDucking(ply,velocity)) then
        local len2d = velocity:Length2DSqr()
        if len2d > 22500 then
            plycache[ply].CalcIdeal = ACT_MP_RUN
        elseif len2d > 0.25 then
            plycache[ply].CalcIdeal = ACT_MP_WALK
        end
    end
    plycache[ply].m_bWasOnGround = ply:IsOnGround()
    plycache[ply].m_bWasNoclipping = ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:InVehicle()
    if ply:GetMoveType() == MOVETYPE_NOCLIP then
        plycache[ply].CalcIdeal = ACT_MP_STAND_IDLE
    end
    return plycache[ply].CalcIdeal, plycache[ply].CalcSeqOverride
end

local IdleActivity = ACT_HL2MP_IDLE
local IdleActivityTranslate = {}
IdleActivityTranslate[ ACT_MP_STAND_IDLE ]					= IdleActivity
IdleActivityTranslate[ ACT_MP_WALK ]						= IdleActivity + 1
IdleActivityTranslate[ ACT_MP_RUN ]							= IdleActivity + 2
IdleActivityTranslate[ ACT_MP_CROUCH_IDLE ]					= IdleActivity + 3
IdleActivityTranslate[ ACT_MP_CROUCHWALK ]					= IdleActivity + 4
IdleActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= IdleActivity + 5
IdleActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= IdleActivity + 5
IdleActivityTranslate[ ACT_MP_RELOAD_STAND ]				= IdleActivity + 6
IdleActivityTranslate[ ACT_MP_RELOAD_CROUCH ]				= IdleActivity + 6
IdleActivityTranslate[ ACT_MP_JUMP ]						= ACT_HL2MP_JUMP_SLAM
IdleActivityTranslate[ ACT_MP_SWIM ]						= IdleActivity + 9
IdleActivityTranslate[ ACT_LAND ]							= ACT_LAND

-- it is preferred you return ACT_MP_* in CalcMainActivity, and if you have a specific need to not tranlsate through the weapon do it here
function GAM:TranslateActivity( ply, act )
	local newact = ply:TranslateWeaponActivity( act )

	-- select idle anims if the weapon didn't decide
	if ( act == newact ) then
		return IdleActivityTranslate[ act ]
	end

	return newact

end

function GAM:DoAnimationEvent( ply, event, data )
    plycache[ply] = plycache[ply] or {}
	if ( event == PLAYERANIMEVENT_ATTACK_PRIMARY ) then

		if ply:IsFlagSet( FL_ANIMDUCKING ) then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true )
		end

		return ACT_VM_PRIMARYATTACK

	elseif ( event == PLAYERANIMEVENT_ATTACK_SECONDARY ) then

		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK

	elseif ( event == PLAYERANIMEVENT_RELOAD ) then

		if ply:IsFlagSet( FL_ANIMDUCKING ) then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true )
		end

		return ACT_INVALID

	elseif ( event == PLAYERANIMEVENT_JUMP ) then

		plycache[ply].m_bJumping = true
		plycache[ply].m_bFirstJumpFrame = true
		plycache[ply].m_flJumpStartTime = CurTime()

		ply:AnimRestartMainSequence()

		return ACT_INVALID

	elseif ( event == PLAYERANIMEVENT_CANCEL_RELOAD ) then

		ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )

		return ACT_INVALID
	end

end


print("[luctus_performance] Animation-optimization loaded")
