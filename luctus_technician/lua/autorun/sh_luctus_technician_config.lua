--Luctus Technician
--Made by OverlordAkise


--The name of the technician job, must be correct or the job won't work!
LUCTUS_TECHNICIAN_JOBNAME = "Technician"
--Should the technician job see broken objects through walls
LUCTUS_TECHNICIAN_SEE_BROKEN_THROUGH_WALL = false
--Delay between things breaking, in seconds
LUCTUS_TECHNICIAN_BREAK_DELAY = 120
--How much health does the entity have, if "killed" it will be broken
LUCTUS_TECHNICIAN_ENT_HEALTH = 200
--Reward (=money gained) is random between these 2 numbers:
LUCTUS_TECHNICIAN_MIN_REWARD = 1000
LUCTUS_TECHNICIAN_MAX_REWARD = 2000

--Remove this if you have the job in jobs.lua
hook.Add("loadCustomDarkRPItems", "luctus_technician_drp", function()
    TEAM_TECHNICIAN = DarkRP.createJob("Technician", {
        color = Color(214, 214, 214, 255),
        model = "models/player/odessa.mdl",
        description = [[Repair broken equipment and earn money!]],
        weapons = {},
        command = "technician",
        max = 2,
        salary = 300,
        admin = 0,
        vote = false,
        hasLicense = false,
        candemote = true,
        category = "Citizens"
    })
end)

print("[luctus_technician] config loaded")
