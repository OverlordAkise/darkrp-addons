--Made by ThatCatGuy
--https://github.com/ThatCatGuy
--https://steamcommunity.com/sharedfiles/filedetails/?id=2195413561
--Stupidly rewritten by OverlordAkise (has alzheimers)

TEAM_CHOCMAKER = DarkRP.createJob("Chocolate Maker", {
    color = Color(255, 255, 255, 255),
    model = {
        "models/player/Group03/Female_01.mdl",
        "models/player/Group03/Female_02.mdl"
    },
    description = [[Create chocolate and sell it to WillyWonka! But be aware: If someone kills you he will steal all of your chocolate bars!]],
    weapons = {},
    command = "chocmaker",
    max = 5,
    salary = GAMEMODE.Config.normalsalary,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Other",
})

DarkRP.createCategory{
	name = "Chocolate Maker",
	categorises = "entities",
	startExpanded = true,
	color = Color(0, 107, 0, 255),
	canSee = function(ply) return ply:Team() == TEAM_CHOCMAKER end,
	sortOrder = 100,
}

DarkRP.createEntity("Chocolate Stove", {
    ent = "lucid_choc_stove",
    model = "models/props_c17/furnitureStove001a.mdl",
    price = 1000,
    max = 2,
    cmd = "buychocstove",

    -- The following fields are OPTIONAL. If you do not need them, or do not need to change them from their defaults, REMOVE them.
    allowed = {TEAM_CHOCMAKER},
    category = "Chocolate Maker",
})


DarkRP.createEntity("Cocoa", {
    ent = "lucid_choc_cocoa",
    model = "models/props_junk/garbage_glassbottle001a.mdl",
    price = 500,
    max = 2,
    cmd = "buychoccocoa",

    -- The following fields are OPTIONAL. If you do not need them, or do not need to change them from their defaults, REMOVE them.
    allowed = {TEAM_CHOCMAKER},
    category = "Chocolate Maker",
})

DarkRP.createEntity("Milk", {
    ent = "lucid_choc_milk",
    model = "models/props_junk/garbage_milkcarton002a.mdl",
    price = 500,
    max = 2,
    cmd = "buychocmilk",

    -- The following fields are OPTIONAL. If you do not need them, or do not need to change them from their defaults, REMOVE them.
    allowed = {TEAM_CHOCMAKER},
    category = "Chocolate Maker",
})

DarkRP.createEntity("Sugar", {
    ent = "lucid_choc_sugar",
    model = "models/props_junk/garbage_milkcarton001a.mdl",
    price = 500,
    max = 2,
    cmd = "buychocsugar",

    -- The following fields are OPTIONAL. If you do not need them, or do not need to change them from their defaults, REMOVE them.
    allowed = {TEAM_CHOCMAKER},
    category = "Chocolate Maker",
})
