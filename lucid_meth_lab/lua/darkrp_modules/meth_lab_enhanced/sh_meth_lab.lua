TEAM_METH = DarkRP.createJob("Methcook", {
    color = Color(214, 214, 214, 255),
    model = {"models/player/hostage/hostage_04.mdl"},
    description = [[You make meth! Buyer are around the map, sell to them.]],
    weapons = {},
    command = "methcook",
    max = 2,
    salary = 300,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Gangsters"
})

DarkRP.createCategory{
    name = "Meth",
    categorises = "entities",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 255,
}

DarkRP.createEntity("Gas", {
    ent = "eml_gas",
    model = "models/props_c17/canister01a.mdl",
    price = 250,
    max = 2,
    cmd = "mGas",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Iodine", {
    ent = "eml_iodine",
    model = "models/props_lab/jar01a.mdl",
    price = 250,
    max = 2,
    cmd = "miodine",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Jar", {
    ent = "eml_jar",
    model = "models/props_lab/jar01a.mdl",
    price = 250,
    max = 2,
    cmd = "mjar",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Muriatic Acid", {
    ent = "eml_macid",
    model = "models/props_junk/garbage_plasticbottle001a.mdl",
    price = 250,
    max = 2,
    cmd = "macid",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Pot", {
    ent = "eml_pot",
    model = "models/props_c17/metalpot001a.mdl",
    price = 250,
    max = 2,
    cmd = "mpot",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Special Pot", {
    ent = "eml_spot",
    model = "models/props_c17/metalpot001a.mdl",
    price = 250,
    max = 2,
    cmd = "mspot",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Stove", {
    ent = "eml_stove",
    model = "models/props_c17/furnitureStove001a.mdl",
    price = 250,
    max = 2,
    cmd = "mstove",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Sulfur", {
    ent = "eml_sulfur",
    model = "models/props_lab/jar01a.mdl",
    price = 250,
    max = 2,
    cmd = "Sulfur",
    category = "Meth",
    allowed = {TEAM_METH}
})

DarkRP.createEntity("Water", {
    ent = "eml_water",
    model = "models/props_junk/garbage_glassbottle001a.mdl",
    price = 250,
    max = 2,
    cmd = "mwater",
    category = "Meth",
    allowed = {TEAM_METH}
})