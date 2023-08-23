
luctus_char_job_cache = luctus_char_job_cache or {}
luctus_char_job_cache_reverse = luctus_char_job_cache_reverse or {}

hook.Add("InitPostEntity","luctus_char_ulx_load_jobs",function()
    for k, v in pairs(RPExtraTeams) do
        luctus_char_job_cache[k] = v.command
        luctus_char_job_cache_reverse[v.command] = k
    end
end)


function ulx.charname(calling_ply, target_ply, charID, newName)
    sql.Query("UPDATE luctus_char SET name = "..sql.SQLStr(newName).." WHERE steamid = "..sql.SQLStr(target_ply:SteamID()).." AND slot = "..charID)
    if target_ply.charCurSlot == charID then
        target_ply:setDarkRPVar("rpname", newName)
    end
    ulx.fancyLogAdmin(calling_ply, "#A changed the name of #T on char #s to #s",target_ply,charID,newName)
end
local charname = ulx.command("CharacterSystem", "ulx charname", ulx.charname, "!charname" )
charname:addParam{ type=ULib.cmds.PlayerArg }
charname:addParam{ type=ULib.cmds.NumArg, default=1, min=1, max=3, hint="CharacterID", ULib.cmds.round }
charname:addParam{ type=ULib.cmds.StringArg, hint="New name" }
charname:defaultAccess(ULib.ACCESS_ADMIN)
charname:help("Rename someones character")

function ulx.charjob(calling_ply, target_ply, charID, newJob)
    if target_ply.charCurSlot == charID then
        if not luctus_char_job_cache_reverse[newJob] then return end
        local jobid = luctus_char_job_cache_reverse[newJob]
        target_ply:changeTeam(jobid, true, true)
    else
        sql.Query("UPDATE luctus_char SET job = "..sql.SQLStr(newJob).." WHERE steamid = '"..target_ply:SteamID().."' and slot = "..charID)
    end
    ulx.fancyLogAdmin(calling_ply, "#A changed the job of #T on char #s to #s",target_ply,charID,newJob)
end
local charjob = ulx.command("CharacterSystem", "ulx charjob", ulx.charjob, "!charjob" )
charjob:addParam{ type=ULib.cmds.PlayerArg }
charjob:addParam{ type=ULib.cmds.NumArg, default=1, min=1, max=3, hint="CharacterID", ULib.cmds.round }
charjob:addParam{ type=ULib.cmds.StringArg, completes=luctus_char_job_cache, ULib.cmds.restrictToCompletes }
charjob:defaultAccess(ULib.ACCESS_ADMIN)
charjob:help("Rename someones character")

function ulx.charedit(calling_ply, target_ply)
    local CharInfoTable = LuctusCharGetTable(target_ply)
    if CharInfoTable then
        net.Start("luctus_char_adminmenu")
            net.WriteTable(CharInfoTable)
            net.WriteString(target_ply:SteamID())
        net.Send(calling_ply)
    else
        calling_ply:PrintMessage(Color(198, 0, 0), "No characters for player!")
    end
    ulx.fancyLogAdmin(calling_ply, "#A edits the characters of #T",target_ply)
end
local charedit = ulx.command("CharacterSystem", "ulx charedit", ulx.charedit, "!charedit" )
charedit:addParam{ type=ULib.cmds.PlayerArg }
charedit:defaultAccess(ULib.ACCESS_ADMIN)
charedit:help("Edit a players characters")

function ulx.chareditoffline(calling_ply, steamid)
    local CharInfoTable = LuctusCharGetTableSID(steamid)
    if CharInfoTable then
        net.Start("luctus_char_adminmenu")
            net.WriteTable(CharInfoTable)
            net.WriteString(steamid)
        net.Send(calling_ply)
    else
        calling_ply:PrintMessage(Color(198, 0, 0), "No characters for player!")
    end
    ulx.fancyLogAdmin(calling_ply, "#A edits the characters of #s",steamid)
end
local chareditoffline = ulx.command("CharacterSystem", "ulx chareditoffline", ulx.chareditoffline, "!chareditoffline" )
chareditoffline:addParam{ type=ULib.cmds.StringArg }
chareditoffline:defaultAccess(ULib.ACCESS_ADMIN)
chareditoffline:help("Edit a players characters via SteamID")
