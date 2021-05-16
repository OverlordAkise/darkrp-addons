--Luctus Thirdperson Wallhack Fix
--Made by OverlordAkise

hook.Add("PlayerInitialSpawn", "luctus_fix_thirdperson", function(ply)
  RunConsoleCommand("simple_thirdperson_forcecollide",1)
  hook.Remove("PlayerInitialSpawn", "luctus_fix_thirdperson")
end)
