--Lucid Whitelist
--Made by OverlordAkise

hook.Add("postLoadCustomDarkRPItems", "lucid_whitelist", function()
  print("[lwhitelist] Adding detour to jobs customCheck")
  for job_index,job in pairs(RPExtraTeams) do
    print("[lwhitelist] Adding detour to "..job.name)
    if (job.lucid_customCheck == nil) then
      job.lucid_customCheck = job.customCheck or false
    end
    job.customCheck = function(ply)
      if (job.lucid_customCheck != false and job.lucid_customCheck(ply)) then return true end
      return (_G["lwhitelist_wspawn"] and _G["lwhitelist_wspawn"]:GetNWBool(job.name,false) == true) or (ply:GetNWBool(job.name,false) == true)
    end
  end
  print("[lwhitelist] Finished adding detours to jobs")
end)

print("[lwhitelist] Lucid Whitelist shared loaded!")
