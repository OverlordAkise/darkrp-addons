--Luctus Don't-Drop-SCP-Weapons Fix
--Made by OverlordAkise

--This disables SCP weapons from being dropped when killed
--It searches for "scp" in your weapon name and if found it disables the drop

hook.Add("DarkRPFinishedLoading", "luctus_adminonlyprops", function()
  hook.Add("canDropWeapon", "luctus_disallow_scpswepdrops",function(ply, weapon)
    if weapon and weapon.GetClass and string.find(weapon:GetClass(),"scp") then
      return false
    end
  end)
end)
