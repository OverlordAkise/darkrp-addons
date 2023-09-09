--Luctus ULX Extras
--Made by OverlordAkise

local CATEGORY_NAME = "DarkRP"

local IdToJob = {}
local JobToId = {}
local function cacheJobs()
    for k, v in pairs(RPExtraTeams) do
        IdToJob[k] = v.command
        JobToId[v.command] = k
    end
end
--Lua refresh
if hook and hook.GetTable() and hook.GetTable()["InitPostEntity"] and hook.GetTable()["InitPostEntity"]["luctus_char_ulx_load_jobs"] then
    cacheJobs()
end
hook.Add("InitPostEntity","luctus_char_ulx_load_jobs",cacheJobs)

function ulx.addmoney(calling_ply, target_ply, amount)
    target_ply:addMoney(amount)
    ulx.fancyLogAdmin(calling_ply, "#A gave #T #s$", target_ply, DarkRP.formatMoney(amount))
end
local addmoney = ulx.command( CATEGORY_NAME, "ulx addmoney", ulx.addmoney, "!addmoney" )
addmoney:addParam{ type=ULib.cmds.PlayerArg }
addmoney:addParam{ type=ULib.cmds.NumArg, default=1000}
addmoney:defaultAccess( ULib.ACCESS_SUPERADMIN )
addmoney:help("Gives target player money")


function ulx.setname(calling_ply, target_ply, name)
    target_ply:setRPName(name)
    ulx.fancyLogAdmin(calling_ply, "#A set #T's name to #s", target_ply, name)
end
local setname = ulx.command( CATEGORY_NAME, "ulx setname", ulx.setname, "!setname" )
setname:addParam{ type=ULib.cmds.PlayerArg }
setname:addParam{ type=ULib.cmds.StringArg, ULib.cmds.takeRestOfLine }
setname:defaultAccess( ULib.ACCESS_ADMIN )
setname:help( "Sets target's RPName." )


function ulx.setjob(calling_ply, target_ply, newjob)
    local jobid = JobToId[newjob]
    if not jobid then
        ULib.tsayError(calling_ply, "Job doesn't exist?", true)
        return
    end
    target_ply:changeTeam(jobid, true)
    ulx.fancyLogAdmin(calling_ply, "#A set #T's job to #s", target_ply, newjob)
end
local setjob = ulx.command( CATEGORY_NAME, "ulx setjob", ulx.setjob, "!setjob" )
setjob:addParam{ type=ULib.cmds.PlayerArg }
setjob:addParam{ type=ULib.cmds.StringArg, completes=IdToJob, ULib.cmds.restrictToCompletes }
setjob:defaultAccess( ULib.ACCESS_ADMIN )
setjob:help("Set a players job")


function ulx.jobkick(calling_ply, target_ply, job, duration)
    local jobid = JobToId[job]
    if not jobid then
        ULib.tsayError(calling_ply, "Job doesn't exist?", true)
        return
    end
    target_ply:teamBan(jobid, duration)
    if target_ply:Team() == jobid then
        target_ply:changeTeam(GAMEMODE.DefaultTeam,true)
    end
    ulx.fancyLogAdmin(calling_ply, "#A has kicked #T for #s from job #s", target_ply, string.NiceTime(duration), job)
end
local jobkick = ulx.command( CATEGORY_NAME, "ulx jobkick", ulx.jobkick, "!jobkick" )
jobkick:addParam{ type=ULib.cmds.PlayerArg }
jobkick:addParam{ type=ULib.cmds.StringArg, completes=IdToJob, ULib.cmds.restrictToCompletes }
jobkick:addParam{ type=ULib.cmds.NumArg, min=0, max=360000, default=0, hint="time in seconds (0 = forever)", ULib.cmds.round, ULib.cmds.optional }
jobkick:defaultAccess( ULib.ACCESS_ADMIN )
jobkick:help("Kick player from job for x seconds")


function ulx.jobunkick(calling_ply, target_ply, job)
    local jobid = JobToId[job]
    if not jobid then
        ULib.tsayError(calling_ply, "Job doesn't exist?", true)
        return
    end
    target_ply:teamUnBan(jobid)
    ulx.fancyLogAdmin( calling_ply, "#A has unkicked #T from job #s", target_ply, job)
end
local jobunkick = ulx.command( CATEGORY_NAME, "ulx jobunkick", ulx.jobunkick, "!jobunkick" )
jobunkick:addParam{ type=ULib.cmds.PlayerArg }
jobunkick:addParam{ type=ULib.cmds.StringArg, completes=IdToJob, ULib.cmds.restrictToCompletes }
jobunkick:defaultAccess( ULib.ACCESS_ADMIN )
jobunkick:help("Un-Kick player from job")


function ulx.rplockdown(calling_ply)
    for _, v in ipairs(player.GetAll()) do
        v:ConCommand("play " .. GAMEMODE.Config.lockdownsound .. "\n")
    end
    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_started"))
    SetGlobalBool("DarkRP_LockDown", true)
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_started"))
    hook.Run("lockdownStarted", calling_ply)
    ulx.fancyLogAdmin(calling_ply, "#A force-started the lockdown")
end
local rplockdown = ulx.command( CATEGORY_NAME, "ulx rplockdown", ulx.rplockdown, "!rplockdown" )
rplockdown:defaultAccess( ULib.ACCESS_ADMIN )
rplockdown:help("Start a lockdown")


function ulx.rpunlockdown(calling_ply)
    DarkRP.printMessageAll(HUD_PRINTTALK, DarkRP.getPhrase("lockdown_ended"))
    DarkRP.notifyAll(0, 3, DarkRP.getPhrase("lockdown_ended"))
    SetGlobalBool("DarkRP_LockDown", false)
    hook.Run("lockdownEnded", calling_ply)
    ulx.fancyLogAdmin(calling_ply, "#A force-stopped the lockdown")
end
local rpunlockdown = ulx.command( CATEGORY_NAME, "ulx rpunlockdown", ulx.rpunlockdown, "!rpunlockdown" )
rpunlockdown:defaultAccess( ULib.ACCESS_ADMIN )
rpunlockdown:help("Stop a lockdown")


function ulx.rpadmintell(calling_ply, message)
    RunConsoleCommand("darkrp", "admintellall", message)
    ulx.fancyLogAdmin(calling_ply, "#A used rpadmintell: #s",message)
end
local rpadmintell = ulx.command( CATEGORY_NAME, "ulx rpadmintell", ulx.rpadmintell, "!rpadmintell" )
rpadmintell:addParam{ type=ULib.cmds.StringArg, hint="message" }
rpadmintell:defaultAccess( ULib.ACCESS_ADMIN )
rpadmintell:help("Show a message in the middle of the screen for everyone")


function ulx.stoprpvote(calling_ply)
    DarkRP.destroyLastVote()
    ulx.fancyLogAdmin(calling_ply, "#A stopped the vote")
end
local stoprpvote = ulx.command( CATEGORY_NAME, "ulx stoprpvote", ulx.stoprpvote, "!stoprpvote" )
stoprpvote:defaultAccess( ULib.ACCESS_ADMIN )
stoprpvote:help("Stop the current vote")


function ulx.resetlaws(calling_ply)
    DarkRP.resetLaws()
    ulx.fancyLogAdmin(calling_ply, "#A has reset the laws")
end
local resetlaws = ulx.command( CATEGORY_NAME, "ulx resetlaws", ulx.resetlaws, "!resetlaws" )
resetlaws:defaultAccess( ULib.ACCESS_ADMIN )
resetlaws:help("Reset the current laws")
