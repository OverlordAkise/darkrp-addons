--Luctus Anti Ban Evasion
--Made by OverlordAkise

--Set the Levels of severity for failed checks
-- 0 = nothing, 1 = kick, 2 = ban

--User played on the server with a different steamid before now
LUCTUS_ABE_SECOND_ACCOUNT = 1
--If the user is a family-shared steam user
LUCTUS_ABE_FAMILY_SHARING = 0
--Player didn't send valid steamid
LUCTUS_ABE_NO_CHECK_SENT = 0
--User's family-shared owner account is banned
LUCTUS_ABE_FAMILY_SHARING_BAN = 2
--User joined with an IP that belonged to a different steamid
LUCTUS_ABE_IP_DIFFERENT_SID = 0
--User has an IP outside of OK countries
LUCTUS_ABE_IP_FOREIGN_COUNTRY = 0
--User has an IP of a TOR / Mullvad server
LUCTUS_ABE_IP_IS_PROXY = 1

--List of Countries that are OK
LUCTUS_ABE_IP_OK_COUNTRIES = {
    ["Germany"] = true,
    ["Switzerland"] = true,
    ["Austria"] = true,
}

--Usergroups who will be notified about messages
LUCTUS_ABE_NOTIFGROUPS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}

--Which SteamIDs are immune to this addon
--The users in this list will never be punished by this addon
LUCTUS_ABE_IMMUNE_IDS = {
    ["STEAM_0:0:55735858"] = true,
}

print("[luctus_antibanevasion] config loaded")
