--Luctus Trashbin
--Made by OverlordAkise

--Should the list of entities be a whitelist or blacklist?
--Whitelist = only those on the list can be discarded
--Blacklist = all entities except this list can be discarded
LUCTUS_TRASHBIN_WHITELIST = false

--Classname of entities
--right click and "copy to clipboard" in the spawnmenu to get those
LUCTUS_TRASHBIN_LIST = {
  ["prop_ragdoll"] = true, --dont remove this one
  ["m9k_m3"] = true,
}

--Current setting means: Nothing except the Benelli M3 shotgun can be thrown away in the trash
print("[luctus_trashbin] SH Config loaded!")