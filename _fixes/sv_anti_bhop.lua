--Luctus Anti Bunnyhop
--Made by OverlordAkise

local luctus_bhoplimit = 600
local luctus_bhopslow = 100

hook.Add( "OnPlayerHitGround", "luctus_slowbhop", function(ply, inWater, onFloater, speed)
	local vel = ply:GetVelocity()
	if luctus_bhoplimit == 0 or ( vel.x > luctus_bhoplimit or vel.x < -luctus_bhoplimit or vel.y > luctus_bhoplimit or vel.y < -luctus_bhoplimit ) then
		local doSlow = 1 + (luctus_bhopslow / 100)
		ply:SetVelocity( Vector( -( vel.x / doSlow ), -( vel.y / doSlow ), 0 ) )
	end
end)
