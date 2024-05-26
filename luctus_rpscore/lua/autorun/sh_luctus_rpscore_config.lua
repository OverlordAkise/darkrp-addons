--Luctus RP-Score
--Made by OverlordAkise

--Should it display rpscore in the top right center
--I highly recommend to set this to false and instead include it in your HUD
--Shared function to get rp score: ply:getRPScore()
LUCTUS_RPSCORE_HUD_DISPLAY = true

--Which SteamIDs can use the command below to add rpscore
--This is a second way to add rpscore besides the ulx commands
LUCTUS_RPSCORE_ALLOWED_STEAMIDS = {
    ["STEAM_0:0:123"] = true
}
--Command that the above steamids may use to add rpscore
--Usage:          /addrpscore <steamid> <amount>
--Usage example:  /addrpscore STEAM_0:0:12345 3
LUCTUS_RPSCORE_USER_CMD = "/addrpscore"

print("[luctus_rpscore] config loaded")
