--Luctus Ingame Config
--Made by OverlordAkise

LUCTUS_INGAME_CONFIG_SV = {}
LUCTUS_INGAME_CONFIG_CL = {}

--Command to open the client config
LUCTUS_INGAME_CONFIG_CMD_CL = "!clientconfig"
--Command to open the server config
LUCTUS_INGAME_CONFIG_CMD_SV = "!serverconfig"

--Define the variables you want to be able to change ingame
--Server and client have different ones ofcourse
LUCTUS_INGAME_CONFIG_SV["DarkRP"] = {
    "GAMEMODE.Config.adminnpcs",
    "nonExistinga",
}
LUCTUS_INGAME_CONFIG_SV["Addons"] = {
    "LUCTUS_DISCORD_ENABLED",
    "LUCTUS_WHITELIST_ACTIVE",
    "LUCTUS_BREACH_NEEDS_APPROVAL",
}
LUCTUS_INGAME_CONFIG_SV["Debug"] = {
    "LUCTUS_MONITOR_DEBUG",
}
---------
LUCTUS_INGAME_CONFIG_CL["Gang"] = {
    "LUCTUS_GANGS_PARTY_HUD",
}

print("[luctus_config] config loaded")
