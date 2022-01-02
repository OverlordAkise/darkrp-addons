--Luctus Treefeller
--Made by OverlordAkise

TEAM_WOODCUTTER = DarkRP.createJob("Woodcutter", {
    color = Color(255, 255, 255, 255),
    model = {
        "models/player/Group03/Female_01.mdl",
        "models/player/Group03/Female_02.mdl"
    },
    description = [[Find old trees and cut them down for money!]],
    weapons = {"weapon_luctus_axe"},
    command = "woodcutter",
    max = 3,
    salary = GAMEMODE.Config.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Other",
})

print("[luctus_treefeller] SH DRP Module loaded!")
