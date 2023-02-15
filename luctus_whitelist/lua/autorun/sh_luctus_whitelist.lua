--Lucid Whitelist
--Made by OverlordAkise

hook.Add("postLoadCustomDarkRPItems", "lucid_whitelist", function()
    print("[luctus_whitelist] Adding whitelist check to jobs customCheck")
    for job_index,job in pairs(RPExtraTeams) do
        if job.lucid_customCheck == nil then
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
    print("[luctus_whitelist] Finished adding whitelist checks to jobs")
end)

print("[luctus_whitelist] Lucid Whitelist shared loaded!")
