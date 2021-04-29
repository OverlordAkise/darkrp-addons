--Lucid Confiscation Box
--Made by OverlordAkise
--Made for McMange's PoliceRP

--Should only sell for police?
LUCID_CONFBOX_POLICEONLY = true

--Should you be able to sell items from the f4 menu
LUCID_CONFBOX_AUTO = true
--For what price should the items from the f4 menu sell?
LUCID_CONFBOX_AUTOPRICE = 0.90 --%

--Custom prices for specific entities/weapons
LUCID_CONFBOX_ITEMS = {
  ["weapon_ak472"] = 9999,
}




--Don't change this
hook.Add("GravGunOnPickedUp", "lucid_confiscation", function(ply, ent)
  ent.lucidConfiscationOwner = ply
end)
