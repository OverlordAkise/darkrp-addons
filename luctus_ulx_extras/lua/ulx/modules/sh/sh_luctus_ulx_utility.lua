--Luctus ULX Extras
--Made by OverlordAkise

local ulx_category_name = "Utility"

function ulx.give(calling_ply, target_plys, wep, bSilent)
    for k, ply in ipairs(target_plys) do
        if ply:Alive() and not ply:IsFrozen() then
            ply:Give(wep)
        end
    end
    ulx.fancyLogAdmin(calling_ply, "#A gave #T #s", target_plys, wep)
end
local give = ulx.command(ulx_category_name, "ulx give", ulx.give, "!give")
give:addParam{type = ULib.cmds.PlayersArg}
give:addParam{type = ULib.cmds.StringArg, hint="weapon class, e.g. weapon_crowbar"}
give:defaultAccess(ULib.ACCESS_ADMIN)
give:help("Give players weapons")


function ulx.maprestart(calling_ply)
    timer.Simple(1,function()
        game.ConsoleCommand("changelevel " .. tostring(game.GetMap()) .. "\n")
    end)
    ulx.fancyLogAdmin(calling_ply, "#A forced a mapchange")
end
local maprestart = ulx.command(ulx_category_name, "ulx maprestart", ulx.maprestart, "!maprestart")
maprestart:defaultAccess(ULib.ACCESS_ADMIN)
maprestart:help("Changes map to the current one")


function ulx.stopsounds(calling_ply)
    for _, v in ipairs(player.GetHumans()) do
        v:SendLua([[RunConsoleCommand("stopsound")]])
    end
    ulx.fancyLogAdmin(calling_ply, "#A used 'stopsound' for everyone")
end
local stopsounds = ulx.command(ulx_category_name, "ulx stopsounds", ulx.stopsounds, "!stopsounds")
stopsounds:defaultAccess(ULib.ACCESS_ADMIN)
stopsounds:help("Stop currently playing sounds for everyone")


function ulx.cleardecals(calling_ply)
    for k,ply in ipairs(player.GetHumans()) do
        ply:ConCommand("r_cleardecals")
    end
    ulx.fancyLogAdmin(calling_ply, "#A cleared decals for everyone")
end
local cleardecals = ulx.command(ulx_category_name, "ulx cleardecals", ulx.cleardecals, "!cleardecals")
cleardecals:defaultAccess(ULib.ACCESS_ADMIN)
cleardecals:help("Clear decals for everyone")


function ulx.resetmap(calling_ply)
    game.CleanUpMap()
    ulx.fancyLogAdmin(calling_ply, "#A reset the map")
end
local resetmap = ulx.command(ulx_category_name, "ulx resetmap", ulx.resetmap, "!resetmap")
resetmap:defaultAccess(ULib.ACCESS_SUPERADMIN)
resetmap:help("Use admin cleanup on the map")


function ulx.bot(calling_ply, number)
    timer.Create("ulx_bots",0.2,number,function()
        RunConsoleCommand("bot")
    end)
    ulx.fancyLogAdmin(calling_ply, "#A spawned #i bot(s)", number)
end
local bot = ulx.command(ulx_category_name, "ulx bot", ulx.bot, "!bot")
bot:addParam{type = ULib.cmds.NumArg, default=1}
bot:defaultAccess(ULib.ACCESS_ADMIN)
bot:help("Spawn gmod bots")


function ulx.kickbots(calling_ply)
    for _, v in ipairs(player.GetBots()) do
        v:Kick("Kicking all bots")
    end
    ulx.fancyLogAdmin(calling_ply, "#A kicked all bots")
end
local kickbots = ulx.command(ulx_category_name, "ulx kickbots", ulx.kickbots, "!kickbots")
kickbots:defaultAccess(ULib.ACCESS_ADMIN)
kickbots:help("Kick all bots")


--You shouldn't ban IP addresses
--[[
function ulx.banip(calling_ply, minutes, ip)
    if not ULib.isValidIP(ip) then
        ULib.tsayError(calling_ply, "Invalid IP Address")
        return
    end
    RunConsoleCommand("addip", minutes, ip)
    RunConsoleCommand("writeip")
    ulx.fancyLogAdmin(calling_ply, true, "#A banned IP Address #s for #i minutes", ip, minutes)
    if ULib.fileExists("cfg/banned_ip.cfg") then
        ULib.execFile("cfg/banned_ip.cfg")
    end
end
local banip = ulx.command(ulx_category_name, "ulx banip", ulx.banip)
banip:addParam{type = ULib.cmds.NumArg, hint = "minutes, 0 for perma", ULib.cmds.allowTimeString, min = 0}
banip:addParam{type = ULib.cmds.StringArg, hint = "ip"}
banip:defaultAccess(ULib.ACCESS_ADMIN)
banip:help("Bans an ip address (cfg/banned_ip.cfg)")


function ulx.unbanip(calling_ply, ip)
    if not ULib.isValidIP(ip) then
        ULib.tsayError(calling_ply, "Invalid IP Address.")
        return
    end
    RunConsoleCommand("removeip", ip)
    RunConsoleCommand("writeip")
    ulx.fancyLogAdmin(calling_ply, true, "#A unbanned IP Address #s", ip)
end
local unbanip = ulx.command(ulx_category_name, "ulx unbanip", ulx.unbanip)
unbanip:addParam{type = ULib.cmds.StringArg, hint = "address"}
unbanip:defaultAccess(ULib.ACCESS_ADMIN)
unbanip:help("Unban an ip address (cfg/banned_ip.cfg)")

hook.Add("InitPostEntity", "ulx_execute_banned_ip_cfg", function ()
    if ULib.fileExists("cfg/banned_ip.cfg") then
        ULib.execFile("cfg/banned_ip.cfg")
    end
end)
--]]

function ulx.administrate(calling_ply, shouldDisable)
    if shouldDisable then
        calling_ply:GodDisable()
        ULib.invisible(calling_ply, false, 0)
        calling_ply:SetMoveType(MOVETYPE_WALK)
        ulx.fancyLogAdmin(calling_ply, true, "#A has stopped administrating")
    else
        calling_ply:GodEnable()
        ULib.invisible(calling_ply, true, 0)
        calling_ply:SetMoveType(MOVETYPE_NOCLIP)
        ulx.fancyLogAdmin(calling_ply, true, "#A is now administrating")
    end
end
local administrate = ulx.command(ulx_category_name, "ulx administrate", ulx.administrate, "!administrate", true)
administrate:addParam{type = ULib.cmds.BoolArg, invisible = true}
administrate:defaultAccess(ULib.ACCESS_SUPERADMIN)
administrate:help("Cloak + Noclip + Godmode")
administrate:setOpposite("ulx unadministrate", {_, true}, "!unadministrate", true)


function ulx.forcerespawn(calling_ply, target_plys)
    for _, v in pairs(target_plys) do
        if v:Alive() then
            v:Kill()
        end
        v:Spawn()
    end
    ulx.fancyLogAdmin(calling_ply, "#A respawned #T", target_plys)
end
local forcerespawn = ulx.command(ulx_category_name, "ulx forcerespawn", ulx.forcerespawn, "!forcerespawn")
forcerespawn:addParam{type = ULib.cmds.PlayersArg}
forcerespawn:defaultAccess(ULib.ACCESS_ADMIN)
forcerespawn:help("(kill and) force-spawn a player")


function ulx.bancheck(calling_ply, sid)
    if ULib.isValidIP(sid) then
        local file = file.Read("cfg/baned_ip.cfg", "GAME")
        if string.find(file, sid) then
            ulx.fancyLog({calling_ply}, "IP Address #s is banned!", sid)
        else
            ulx.fancyLog({calling_ply}, "IP Address #s is not banned!", sid)
        end
        return
    elseif ULib.isValidSteamID(sid) then
        if ULib.bans[sid] then
            ulx.fancyLog({calling_ply}, "SteamID #s is banned!", sid)
        else
            ulx.fancyLog({calling_ply}, "SteamID #s is not banned!", sid)
        end
    else
        ULib.tsayError(calling_ply, "Please provide either IPv4 or SteamID")
    end
end
local bancheck = ulx.command(ulx_category_name, "ulx bancheck", ulx.bancheck, "!bancheck")
bancheck:addParam{type = ULib.cmds.StringArg, hint = "string"}
bancheck:defaultAccess(ULib.ACCESS_ADMIN)
bancheck:help("Check if a steamid or ip address is banned")
