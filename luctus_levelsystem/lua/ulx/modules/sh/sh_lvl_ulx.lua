--Luctus LevelSystem ULX Module
--Made by OverlordAkise

local CATEGORY_NAME = "LevelSystem"

-- !setlevel
function ulx.setlevel( calling_ply, target_ply, amount )
    target_ply:setLevel(math.floor(amount))
    target_ply:setXP(0)
    LuctusLevelSave(target_ply)
    if target_ply.DarkRPUnInitialized then return end
    ulx.fancyLogAdmin( calling_ply, "#A set level of #T to #s", target_ply, amount )
end
local setlevel = ulx.command( CATEGORY_NAME, "ulx setlevel", ulx.setlevel, "!setlevel" )
setlevel:addParam{ type=ULib.cmds.PlayerArg }
setlevel:addParam{ type=ULib.cmds.NumArg, min=0, max=1000000, default=100, hint="level" }
setlevel:defaultAccess( ULib.ACCESS_SUPERADMIN )
setlevel:help( "Sets level of player." )

-- !givexp
function ulx.givexp( calling_ply, target_ply, amount )
    target_ply:addXP(amount)
    if target_ply.DarkRPUnInitialized then return end
    ulx.fancyLogAdmin( calling_ply, "#A gave  #T #s XP", target_ply, amount )
end
local givexp = ulx.command( CATEGORY_NAME, "ulx givexp", ulx.givexp, "!givexp" )
givexp:addParam{ type=ULib.cmds.PlayerArg }
givexp:addParam{ type=ULib.cmds.NumArg, min=0, max=1000000, default=100, hint="xp" }
givexp:defaultAccess( ULib.ACCESS_SUPERADMIN )
givexp:help( "Give XP to player." )

print("[luctus_levelsystem] ulx loaded!")
