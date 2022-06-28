--Luctus Levelsystem
--Made by OverlordAkise

hook.Add("postLoadCustomDarkRPItems", "luctus_level_job_restriction", function()
  print("[luctus_levelsystem] Adding level restrictions to jobs customCheck")
  for job_index,job in pairs(RPExtraTeams) do
    if (job.luctus_jobrestriction == nil) then
      job.luctus_jobrestriction = job.customCheck or false
    end
    job.customCheck = function(ply)
      if (job.luctus_jobrestriction != false and job.luctus_jobrestriction(ply)) then return true end
      if not job.level or not ply.hasLevel then 
        return true
      end
      return ply:hasLevel(job.level)
    end
  end
  print("[luctus_levelsystem] Finished adding restrictions to jobs")
end)

print("[luctus_levelsystem] sh loaded!")
