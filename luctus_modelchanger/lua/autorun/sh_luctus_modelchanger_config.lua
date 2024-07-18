--Luctus Modelchanger
--Made by OverlordAkise

--Should the changed playermodel be set again after spawning
LUCTUS_MODELCHANGER_KEEP_MODEL_AFTER_DEATH = false

--Each cabinet can have a different config
--Example: The winter-cabinet changes a citizens model to a coat
LUCTUS_MODELCHANGER_CABINETS = {
    ["WinterClothes"] = {
        ["Citizen"] = "models/player/Group03/female_01.mdl",
        ["Hobo"] = "models/player/Group03/female_01.mdl",
    },
    ["GMan"] = {
        ["Citizen"] = "models/player/gman_high.mdl",
    }
}


print("[luctus_modelchanger] config loaded")
