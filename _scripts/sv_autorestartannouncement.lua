--Luctus AutoRestartAnnouncements
--Made by OverlordAkise

--Announce to your players when the server will be automatically restarting
--Example config for a 4am server restart: announce it at 3:45am every 3 minutes

--What chat message should be printed in chat?
LUCTUS_AUTORESTARTANNOUNCE_MSG = "Server will be restarting at 4am!"
--When should the announcements start?
LUCTUS_AUTORESTARTANNOUNCE_TIME = "03:45:00"
--What timezone is the server in? (UTC=0 , germany-summertime=2)
LUCTUS_AUTORESTARTANNOUNCE_TZ = 2
--How often (every x minutes) should it announce the message?
LUCTUS_AUTORESTARTANNOUNCE_MSG_DELAY = 3
--Should the message be printed in chat?
LUCTUS_AUTORESTARTANNOUNCE_CHAT_PRINT = true
--Should the message be shown as a darkrp notification?
LUCTUS_AUTORESTARTANNOUNCE_DARKRP_NOTIFICATION = true

function LuctusAutoRestartAnnounceWaitUntil()
    if not string.match(LUCTUS_AUTORESTARTANNOUNCE_TIME, "^[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$") then
        ErrorNoHaltWithStack("ERROR: Input announce-start-time is in a wrong format!")
        print("Expected format (24h): 14:32:56 , Got:",LUCTUS_AUTORESTARTANNOUNCE_TIME)
        return
    end
    
    local t = string.Split(LUCTUS_AUTORESTARTANNOUNCE_TIME,":")
    local restartTimeInSeconds = tonumber(t[1])*60*60 + tonumber(t[2])*60 + tonumber(t[3])
    local curTimeWithTimezone = (os.time()+2*60*60)%86400
    local waitSeconds = 0
    if curTimeWithTimezone > restartTimeInSeconds then
        waitSeconds = 86400 - curTimeWithTimezone + restartTimeInSeconds
    else
        waitSeconds = restartTimeInSeconds-curTimeWithTimezone
    end
    print("[luctus_autorestartannounce] Sleeping for (s)",waitSeconds)
    timer.Simple(waitSeconds,LuctusAutoRestartAnnounceCreateTimer)
end

function LuctusAutoRestartAnnounceDo()
    if LUCTUS_AUTORESTARTANNOUNCE_CHAT_PRINT then
        PrintMessage(HUD_PRINTTALK,LUCTUS_AUTORESTARTANNOUNCE_MSG)
    end
    if LUCTUS_AUTORESTARTANNOUNCE_DARKRP_NOTIFICATION then
        DarkRP.notify(player.GetAll(),0,5,LUCTUS_AUTORESTARTANNOUNCE_MSG)
    end
end

function LuctusAutoRestartAnnounceCreateTimer()
    print("[luctus_autorestartannounce] starting to announce")
    LuctusAutoRestartAnnounceDo()
    timer.Create("luctus_autorestartannounce",LUCTUS_AUTORESTARTANNOUNCE_MSG_DELAY*60,0,function()
        LuctusAutoRestartAnnounceDo()
    end)
end

LuctusAutoRestartAnnounceWaitUntil()

print("[luctus_autorestartannounce] sv loaded")
