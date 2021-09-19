--SCP714 Fix
--Made by OverlordAkise

hook.Add("PlayerInitialSpawn", "luctus_fix_scp714", function()

  net.Receive("Drop714", function(len, ply)
    if ply:GetNWBool("Wearing714") then
      Drop714(ply, true)
    end
  end)
  
  print("[scp914_fix] Successfully fixed!")
  hook.Remove("PlayerInitialSpawn", "luctus_fix_scp714")
end)

print("[scp914_fix] Loaded hook!")
