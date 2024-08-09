
local luctus_job_cache = luctus_job_cache or {}

hook.Add("InitPostEntity","luctus_jobranks_sam_load",function()
	for k, v in pairs(RPExtraTeams) do
		luctus_job_cache[v.command] = true
	end
end)


sam.command.new("apromote")
    :SetCategory("Jobrank")
    :SetPermission("apromote", "admin")
    :Help("Promote someone via Jobranks")
    :AddArg("player", { single_target = true })
    :OnExecute(function(calling_ply, targets)
        local target_ply = targets[1]
        local jobcommand = RPExtraTeams[target_ply:Team()].command
        luctusRankup(target_ply,jobcommand,calling_ply)
        sam.player.send_message(nil, "{A} promoted {T}", {
            A = calling_ply, T = targets,
        })
    end)
:End()

sam.command.new("ademote")
    :SetCategory("Jobrank")
    :SetPermission("ademote", "admin")
    :Help("Demote someone via Jobranks")
    :AddArg("player", { single_target = true })
    :OnExecute(function(calling_ply, targets)
        local target_ply = targets[1]
        local jobcommand = RPExtraTeams[target_ply:Team()].command
        luctusRankdown(target_ply,jobcommand,calling_ply)
        sam.player.send_message(nil, "{A} demoted {T}", {
            A = calling_ply, T = targets,
        })
    end)
:End()

sam.command.new("setjobrankid")
    :SetCategory("Jobrank")
    :SetPermission("setjobrankid", "admin")
    :Help("Set an offline player's jobrank")
    :AddArg("text", {
        default = "STEAM_0:0:12345678",
        hint = "steamid",
    })
    :AddArg("text", {
        default = "dclass",
        hint = "job command",
        check = function(input, ply)
            if not luctus_job_cache[input] then
                return false
            end
            return true
        end,
    })
    :AddArg("number", {
        default = 1,
        hint = "job rank",
        min = 1,
        max = 200,
        round = true,
    })
    :OnExecute(function(calling_ply, steamid, jobcommand, rankid)
        local jobname = nil
        for k,v in pairs(RPExtraTeams) do
            if v.command == jobcommand then jobname = v.name break end
        end
        if not luctus_jobranks[jobname] then return end
        if not luctus_jobranks[jobname][rankid] then return end
        
        luctusJobranksSave(steamid,jobcommand,rankid)
        sam.player.send_message(nil, "{A} set the jobrank of {V} on job {V_2} to {V_3}", {
            A = calling_ply, V = steamid, V_2 = jobname, V_3 = rankid,
        })
    end)
:End()
