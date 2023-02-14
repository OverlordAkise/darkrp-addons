--Lucid Whitelist
--Made by OverlordAkise

hook.Add("postLoadCustomDarkRPItems", "lucid_whitelist", function()
    print("[lwhitelist] Adding whitelist check to jobs customCheck")
    for job_index,job in pairs(RPExtraTeams) do
        if (job.lucid_customCheck == nil) then
            job.lucid_customCheck = job.customCheck or false
        end
        job.customCheck = function(ply)
            if job.lucid_customCheck != false then 
                if not job.lucid_customCheck(ply) then
                    return false
                end
            end
            return GetGlobalBool(job.name,false) or ply:GetNWBool(job.name,false)
        end
    end
    print("[lwhitelist] Finished adding whitelist checks to jobs")
end)

print("[lwhitelist] Lucid Whitelist shared loaded!")
