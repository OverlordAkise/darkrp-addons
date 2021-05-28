--Luctus Hide Door Display
--Made by OverlordAkise

--This hides the "Press F2 to enable this door to be bought again"
--popup when you look at doors as an admin

hook.Add("HUDDrawDoorData", "luctus_hide_doorinfo", function(ent)
  return true
end)