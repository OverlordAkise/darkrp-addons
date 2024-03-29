--Luctus Performance
--Made by OverlordAkise

--[[

Comparison, according to fprofiler

type     runs       total time taken    average time taken
default  665        6.18516             0.00930099
striped  693        3.959110            0.00571300
+tables  669        2.73095             0.0040821375
+meta    681        1.544720            0.0022683113

This is the default gmod animation lua but:
 - striped from swimming,noclipping,vaulting animations
 - using tables instead of ply index (tab[ply].x instead of ply.x)
 - caching meta functions, this was by far using the most ply __index

--]]



local plycache = {}

local GAM = gmod.GetGamemode()

local plymeta = FindMetaTable("Player")
local entmeta = FindMetaTable("Entity")
local plyOnGround = entmeta.OnGround
local plyAnimRestartMainSequence = plymeta.AnimRestartMainSequence
local plyWaterLevel = entmeta.WaterLevel
local plyTranslateWeaponActivity = plymeta.TranslateWeaponActivity
local plyGetMoveType = entmeta.GetMoveType
local plyIsFlagSet = entmeta.IsFlagSet
local plySetPlaybackRate = entmeta.SetPlaybackRate
local entLookupSequence = entmeta.LookupSequence
local plyInVehicle = plymeta.InVehicle


function GAM:HandlePlayerJumping( ply, velocity )
	if ( plyGetMoveType(ply) == MOVETYPE_NOCLIP ) then
		plycache[ply].m_bJumping = false
		return
	end

	-- airwalk more like hl2mp, we airwalk until we have 0 velocity, then it's the jump animation
	-- underwater we're alright we airwalking
	if ( !plycache[ply].m_bJumping && !plyOnGround(ply) && plyWaterLevel(ply) <= 0 ) then

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
			plyAnimRestartMainSequence(ply)

		end

		if ( plyWaterLevel(ply) >= 2 ) || ( ( CurTime() - plycache[ply].m_flJumpStartTime ) > 0.2 && plyOnGround(ply) ) then

			plycache[ply].m_bJumping = false
			plycache[ply].m_fGroundTime = nil
			plyAnimRestartMainSequence(ply)

		end

		if plycache[ply].m_bJumping then
			plycache[ply].CalcIdeal = ACT_MP_JUMP
			return true
		end
	end

	return false

end

function GAM:HandlePlayerDucking( ply, velocity )
	if ( !plyIsFlagSet(ply, FL_ANIMDUCKING ) ) then return false end

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

function GAM:HandlePlayerDriving(ply)
    if not plyInVehicle(ply) or not IsValid(ply:GetParent()) then return false end

	local pVehicle = ply:GetVehicle()

	if not pVehicle.HandleAnimation and pVehicle.GetVehicleClass then
		local c = pVehicle:GetVehicleClass()
		local t = list.Get("Vehicles")[c]
		if t and t.Members and t.Members.HandleAnimation then
			pVehicle.HandleAnimation = t.Members.HandleAnimation
		else
			pVehicle.HandleAnimation = true -- Prevent this if block from trying to assign HandleAnimation again.
		end
	end

	if isfunction(pVehicle.HandleAnimation) then
		local seq = pVehicle:HandleAnimation(ply)
		if seq != nil then
			plycache[ply].CalcSeqOverride = seq
		end
	end

	if plycache[ply].CalcSeqOverride == -1 then -- pVehicle.HandleAnimation did not give us an animation
		local class = pVehicle:GetClass()
		if class == "prop_vehicle_jeep" then
			plycache[ply].CalcSeqOverride = entLookupSequence(ply,"drive_jeep")
		elseif class == "prop_vehicle_airboat" then
			plycache[ply].CalcSeqOverride = entLookupSequence(ply,"drive_airboat")
		elseif class == "prop_vehicle_prisoner_pod" and pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" then
			plycache[ply].CalcSeqOverride = entLookupSequence(ply,"drive_pd")
		else
			plycache[ply].CalcSeqOverride = entLookupSequence(ply,"sit_rollercoaster")
		end
	end

	local use_anims = plycache[ply].CalcSeqOverride == entLookupSequence(ply,"sit_rollercoaster") or plycache[ply].CalcSeqOverride == entLookupSequence(ply,"sit")
	if use_anims and ply:GetAllowWeaponsInVehicle() and IsValid(ply:GetActiveWeapon()) then
		local holdtype = ply:GetActiveWeapon():GetHoldType()
		if holdtype == "smg" then holdtype = "smg1" end

		local seqid = entLookupSequence(ply,"sit_"..holdtype)
		if seqid != -1 then
			plycache[ply].CalcSeqOverride = seqid
		end
	end

	return true
end

--[[---------------------------------------------------------
   Name: gamemode:UpdateAnimation()
   Desc: Animation updates (pose params etc) should be done here
-----------------------------------------------------------]]
--CL: 34->29ms
function GAM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	local len = velocity:Length()
	local movement = 1.0

	if ( len > 0.2 ) then
		movement = ( len / maxseqgroundspeed )
	end

	local rate = math.min( movement, 2 )

	-- if we're under water we want to constantly be swimming..
	if ( plyWaterLevel(ply) >= 2 ) then
		rate = math.max( rate, 0.5 )
	elseif ( !plyOnGround(ply) && len >= 1000 ) then
		rate = 0.1
	end

	plySetPlaybackRate(ply,rate)

	if CLIENT then
		GAM:GrabEarAnimation( ply )
		GAM:MouthMoveAnimation( ply )
	end
end

--
-- If you don't want the player to grab his ear in your gamemode then
-- just override this.
--
local plyIsPlayingTaunt = plymeta.IsPlayingTaunt
local plyIsTyping = plymeta.IsTyping

function GAM:GrabEarAnimation( ply )
    if not plycache[ply] then return end
	plycache[ply].ChatGestureWeight = plycache[ply].ChatGestureWeight or 0

	-- Don't show this when we're playing a taunt!
	if plyIsPlayingTaunt(ply) then return end

	if plyIsTyping(ply) then
		plycache[ply].ChatGestureWeight = math.Approach( plycache[ply].ChatGestureWeight, 1, FrameTime() * 5.0 )
	else
		plycache[ply].ChatGestureWeight = math.Approach( plycache[ply].ChatGestureWeight, 0, FrameTime() * 5.0 )
	end

	if plycache[ply].ChatGestureWeight > 0 then

		ply:AnimRestartGesture( GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true )
		ply:AnimSetGestureWeight( GESTURE_SLOT_VCD, plycache[ply].ChatGestureWeight )

	end

end

--
-- Moves the mouth when talking on voicecom
--
local plyIsSpeaking = plymeta.IsSpeaking
local entGetFlexIDByName = entmeta.GetFlexIDByName
local plyVoiceVolume = plymeta.VoiceVolume --cl only
local entSetFlexWeight = entmeta.SetFlexWeight

function GAM:MouthMoveAnimation( ply )
	local flexes = {
		entGetFlexIDByName(ply,"jaw_drop"),
		entGetFlexIDByName(ply,"left_part"),
		entGetFlexIDByName(ply,"right_part"),
		entGetFlexIDByName(ply,"left_mouth_drop"),
		entGetFlexIDByName(ply,"right_mouth_drop")
	}

	local weight = plyIsSpeaking(ply) and math.Clamp( plyVoiceVolume(ply) * 2, 0, 2 ) or 0

	for k,v in ipairs(flexes) do

		entSetFlexWeight(ply,v,weight)

	end

end

function GAM:CalcMainActivity( ply, velocity )
    plycache[ply] = plycache[ply] or {}
	plycache[ply].CalcIdeal = ACT_MP_STAND_IDLE
	plycache[ply].CalcSeqOverride = -1
	if plyOnGround(ply) and not plycache[ply].m_bWasOnGround then
        ply:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)
    end
    if not (self:HandlePlayerJumping(ply,velocity) or self:HandlePlayerDucking(ply,velocity) or self:HandlePlayerDriving(ply)) then
        local len2d = velocity:Length2DSqr()
        if len2d > 22500 then
            plycache[ply].CalcIdeal = ACT_MP_RUN
        elseif len2d > 0.25 then
            plycache[ply].CalcIdeal = ACT_MP_WALK
        end
    end
    plycache[ply].m_bWasOnGround = plyOnGround(ply)
    plycache[ply].m_bWasNoclipping = plyGetMoveType(ply) == MOVETYPE_NOCLIP and not plyInVehicle(ply)
    if plyGetMoveType(ply) == MOVETYPE_NOCLIP then
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
	local newact = plyTranslateWeaponActivity(ply,act)

	-- select idle anims if the weapon didn't decide
	if ( act == newact ) then
		return IdleActivityTranslate[ act ]
	end

	return newact

end

function GAM:DoAnimationEvent( ply, event, data )
    plycache[ply] = plycache[ply] or {}
	if ( event == PLAYERANIMEVENT_ATTACK_PRIMARY ) then

		if plyIsFlagSet(ply, FL_ANIMDUCKING ) then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_CROUCH_PRIMARYFIRE, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_ATTACK_STAND_PRIMARYFIRE, true )
		end

		return ACT_VM_PRIMARYATTACK

	elseif ( event == PLAYERANIMEVENT_ATTACK_SECONDARY ) then

		-- there is no gesture, so just fire off the VM event
		return ACT_VM_SECONDARYATTACK

	elseif ( event == PLAYERANIMEVENT_RELOAD ) then

		if plyIsFlagSet(ply, FL_ANIMDUCKING ) then
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_CROUCH, true )
		else
			ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_MP_RELOAD_STAND, true )
		end

		return ACT_INVALID

	elseif ( event == PLAYERANIMEVENT_JUMP ) then

		plycache[ply].m_bJumping = true
		plycache[ply].m_bFirstJumpFrame = true
		plycache[ply].m_flJumpStartTime = CurTime()

		plyAnimRestartMainSequence(ply)

		return ACT_INVALID

	elseif ( event == PLAYERANIMEVENT_CANCEL_RELOAD ) then

		ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )

		return ACT_INVALID
	end

end


print("[luctus_performance] Animation-optimization loaded")
