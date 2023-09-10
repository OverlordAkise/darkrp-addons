--Luctus Levelsystem
--Made by OverlordAkise

--Current XP multiplier
LUCTUS_LEVEL_XP_MULTIPLIER = 1
--Should each job have its own leveling
LUCTUS_XP_PERJOB = false
--Interval for giving XP in seconds
LUCTUS_XP_TIMER = 300
--How many XP every interval
LUCTUS_XP_TIMER_XP = 20
--How many XP per player kill
LUCTUS_XP_KILL = 5

--Function for calculating how many XP you need per level
--Currently: Linear scaling
function LuctusLevelRequiredXP(lvl)
    return (5+(lvl*5))
end

print("[luctus_levelsystem] config loaded")
