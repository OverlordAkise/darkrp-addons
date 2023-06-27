--Luctus Discord Notifications
--Made by OverlordAkise

--Rate limiter for discords api
local rateLimitCache = {}
function LuctusDiscordIsLimited(name,rate)
    if not rateLimitCache[name] then rateLimitCache[name] = 0 end
    if rateLimitCache[name] + rate > CurTime() then return true end
    rateLimitCache[name] = CurTime() + rate
    return false
end

--Serverstart
hook.Add("Tick","luctus_discord_start",function()
    LuctusDiscordSend("Server started")
    hook.Remove("Tick","luctus_discord_start")
end)

--Notify on lag (Tickrate)
local isCheckingTickrate = false
local tickCount = 0
function luctusDiscordTickrater() tickCount = tickCount + 1 end
timer.Create("luctus_discord_tickrate",1,0,function()
    if isCheckingTickrate then
        hook.Remove("Tick","luctus_discord")
        local tickrate = 1/engine.TickInterval()
        if tickCount > 0 and math.abs(tickrate-tickCount) > 2 and not LuctusDiscordIsLimited("tickrate",300) then
            LuctusDiscordSend("Lag detected (tickrate "..tickCount..")")
        end
        tickCount = 0
        isCheckingTickrate = false
    else
        hook.Add("Tick","luctus_discord",luctusDiscordTickrater)
        isCheckingTickrate = true
    end
end)



--Notify on ULX ban/kick and group change
hook.Add("ULibPlayerKicked","luctus_discord",function(steamid,reason,caller)
    local callerName = "<server>"
    if caller and IsValid(caller) then
        callerName = caller:Nick().."("..caller:SteamID()..")"
    end
    LuctusDiscordSend(steamid.." was kicked by "..callerName.." for "..reason)
end)
hook.Add("ULibPlayerBanned","luctus_discord",function(steamid,bandata)
    local callerName = "<server>"
    if bandata and bandata.admin then
        callerName = bandata.admin
    end
    local bantime = "permanently"
    if bandata.unban != 0 then
        bantime = "for "..ULib.secondsToStringTime(bandata.unban - bandata.time)
    end
    LuctusDiscordSend(steamid.." was banned by "..callerName.." for reason '"..bandata.reason.."' "..bantime)
end)
hook.Add("ULibUserGroupChange","luctus_discord",function(steamid,a,d,newGroup,oldGroup)
    if not oldGroup then oldGroup = "user" end
    LuctusDiscordSend("Changed ulx group for "..steamid.." from "..oldGroup.." to "..newGroup)
end)
hook.Add("ULibUserRemoved","luctus_discord",function(steamid,data)
    LuctusDiscordSend("Removed all ulx access rights from "..steamid.." (before: "..data.group..")")
end)


--Luctus Warn
hook.Add("LuctusWarnCreate","luctus_discord",function(ply,victimName,victimSID,reason)
    LuctusDiscordSend("Warn",victimName.."("..victimSID..") has been warned by "..ply:Nick().."("..ply:SteamID()..") for '"..reason.."'.")
end)
hook.Add("LuctusWarnUpdate","luctus_discord",function(ply,victimName,victimSID,shouldRemove)
    LuctusDiscordSend(ply:Nick().."("..ply:SteamID()..") has "..(shouldRemove and "removed" or "reactivated").." a warn of "..victimName.."("..victimSID..")")
    
end)
hook.Add("LuctusWarnDelete","luctus_discord",function(ply,victimName,victimSID)
    LuctusDiscordSend(ply:Nick().."("..ply:SteamID()..") has deleted a warn of "..victimName.."("..victimSID..")")
end)


--Luctus Whitelist
hook.Add("LuctusWhitelistUpdate","luctus_discord",function(ply,steamid,jtext)
    LuctusDiscordSend(ply:Nick().."("..ply:SteamID()..") changed the whitelist of "..steamid.." to "..jtext)
end)


--Luctus AC
hook.Add("LuctusAC","luctus_discord",function(name,steamid,length,message)
    LuctusDiscordSend(name.."("..steamid..") cheated and is banned for "..length.." because of "..message)
end)


--Luctus Antibanevasion
hook.Add("LuctusAbe","luctus_discord",function(ply,message)
    LuctusDiscordSend(message)
end)


--Luctus Jobranks
hook.Add("LuctusJobranks","luctus_discord",function(uprankPly,targetPly,newJobName,isUpRank)
    LuctusDiscordSend(uprankPly:Nick().."("..uprankPly:SteamID()..") "..(isUpRank and "promoted" or "demoted").." "..targetPly:Nick().."("..targetPly:SteamID()..") to "..newJobName.."("..team.GetName(targetPly:Team())..")")
end)


print("[luctus_discord] sv loaded!")
