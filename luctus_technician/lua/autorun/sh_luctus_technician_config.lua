--Luctus Technician
--Made by OverlordAkise


--The name of the technician job, must be correct or the job won't work!
LUCTUS_TECHNICIAN_JOBNAME = "Technician"
--Delay between things breaking
LUCTUS_TECHNICIAN_BREAK_DELAY = 120
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
