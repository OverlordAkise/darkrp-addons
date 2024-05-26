--Luctus Streetrobber
--Made by OverlordAkise

--how much money to rob, set to 0.5 to rob 50% of all the players money
LUCTUS_STREETROBBER_AMOUNT = 5000
--How fast to rob, this is per tick. e.g. 1 with 33ticks = robbed in 3s
LUCTUS_STREETROBBER_SPEED = 1
--How long to not press E for the progress to reset, in seconds
LUCTUS_STREETROBBER_RESET_DELAY = 0.3
--How long between getting robbed, in seconds
LUCTUS_STREETROBBER_VICTIM_COOLDOWN = 300
--How long between being able to rob others, in seconds
LUCTUS_STREETROBBER_ROBBER_COOLDOWN = 120
--Which jobs can rob others
LUCTUS_STREETROBBER_ROBBER_JOBS = {
    ["Citizen"] = true,
}
--Which jobs can not be robbed
LUCTUS_STREETROBBER_UNROBBABLE_JOBS = {
    ["Team on duty"] = true,
}

--Config end

function LuctusCanBeStreetRobbed(robber,victim)
    local victimTeam = team.GetName(victim:Team())
    local robberTeam = team.GetName(robber:Team())
    if LUCTUS_STREETROBBER_UNROBBABLE_JOBS[victimTeam] then return false end
    if not LUCTUS_STREETROBBER_ROBBER_JOBS[robberTeam] then return false end
    --local wep = ply:GetActiveWeapon()
    --if not Isvalid(wep) or not string.StartsWith(wep:GetClass(), "m9k_") then return false end
    return true
end

print("[luctus_streetrobber] config loaded")
