--Luctus Remove-Logo
--Made by OverlordAkise

--This removes the big "Modern Gaming" Logo from the map rp_mg_area14_v6

hook.Add("DatabaseInitialized", "luctus_remove_mg", function()
  print("[luctus] TRYING TO REMOVE LOGO!")
  --local logo = ents.GetMapCreatedEntity(5586) or nil 
  --New ID from update since 27.06.2021
  local logo = ents.GetMapCreatedEntity(5767) or nil 
  if logo then
    logo:Remove()
    print("[luctus] LOGO REMOVED!")
  end
end)
