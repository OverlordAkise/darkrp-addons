--Luctus Mods-Can-Spawn-Weapons Fix
--Made by OverlordAkise

--Let's moderators and other teammembers spawn weapons

local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
  }

hook.Add("PlayerInitialSpawn", "luctus_modweapons", function()
  if not GM and not GAMEMODE then
    print("[luctus_modweapons] Error: Couldn't load!")
    return
  end
  print("[luctus_modweapons] Successfully loading!")
  local function lcanSpawnWeapon(ply)
      if allowedRanks[ply:GetUserGroup()] then
        return true
      end
      DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("cant_spawn_weapons"))
      return false
  end
  function GAMEMODE:PlayerSpawnSWEP(ply, class, info)
      return lcanSpawnWeapon(ply) and self.Sandbox.PlayerSpawnSWEP(self, ply, class, info) and not ply:isArrested()
  end
  function GAMEMODE:PlayerGiveSWEP(ply, class, info)
      return lcanSpawnWeapon(ply) and self.Sandbox.PlayerGiveSWEP(self, ply, class, info) and not ply:isArrested()
  end
  hook.Remove("PlayerInitialSpawn", "luctus_modweapons")
end)

print("[luctus_modweapons] Loaded hook!")
