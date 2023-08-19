--Luctus Confiscation Box
--Made by OverlordAkise
--Made initially for McMange's PoliceRP

--Should only sell for police?
LUCTUS_CONFBOX_POLICEONLY = true

--Sellable entities, has priority over F4Menu
LUCTUS_CONFBOX_ITEMS = {
  ["weapon_ak472"] = 9999,
}

--Should you be able to sell items from the f4 menu
LUCTUS_CONFBOX_F4ALLOWED = true

--For what price should the items from the f4 menu sell?
LUCTUS_CONFBOX_F4RATIO = 0.90 --%



--Don't change this
hook.Add("GravGunOnPickedUp", "luctus_police_confiscation", function(ply, ent)
    ent.luctusConfiscationOwner = ply
end)
