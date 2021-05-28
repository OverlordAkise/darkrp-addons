--Luctus Clear-Pocket-On-Job-Change
--Made by OverlordAkise

--Clears pocket contents when switching jobs
--This could be exploited by transfering weapons from police to hobo

hook.Add("OnPlayerChangedTeam", "luctus_pocket_job_fix", function(ply, beforeNum, afterNum)
  for k in pairs(ply.darkRPPocket or {}) do
    ply:removePocketItem(k)
  end
end)
