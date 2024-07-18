--Luctus Autohostname
--Made by OverlordAkise

--This changes your servername periodically to adjust the amount of players on the server

--The hostname, the 2 %d will be replaced with playercount and maxplayercount
--The second %d can be omitted
LUCTUS_AUTOHOSTNAME_TEXT = "Luctus' Server | TESTING | %d/%d players"
--Every x seconds the hostname will be changed
LUCTUS_AUTOHOSTNAME_DELAY = 3
--Should bots be counted towards the player count?
LUCTUS_AUTOHOSTNAME_COUNT_BOTS = true


timer.Create("luctus_autohostname", LUCTUS_AUTOHOSTNAME_DELAY, 0, function() 
    local plyCount = player.GetCount()
    if not LUCTUS_AUTOHOSTNAME_COUNT_BOTS then
        plyCount = plyCount - #player.GetBots()
    end
    RunConsoleCommand("hostname", string.format(LUCTUS_AUTOHOSTNAME_TEXT,plyCount,game.MaxPlayers()))
end)


print("[luctus_autohostname] sv loaded")
