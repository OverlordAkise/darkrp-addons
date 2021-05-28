--Luctus Mods-Can-Spawn-Entities Fix
--Made by OverlordAkise

--Let's moderators and other teammembers spawn entities

local allowedRanks = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
}

hook.Add("PlayerInitialSpawn", "luctus_modentities", function()
  if not GM and not GAMEMODE then
    print("[luctus_modentities] Error: Couldn't load!")
    return
  end
  print("[luctus_modentities] Successfully loading!")
  local function lcheckAdminSpawn(ply, configVar, errorStr)
    if allowedRanks[ply:GetUserGroup()] then
      return true
    end
    DarkRP.notify(ply, 1, 5, DarkRP.getPhrase("need_admin", DarkRP.getPhrase(errorStr) or errorStr))
    return false
  end

  function GAMEMODE:PlayerSpawnSENT(ply, class)
      return lcheckAdminSpawn(ply, "adminsents", "gm_spawnsent") and self.Sandbox.PlayerSpawnSENT(self, ply, class) and not ply:isArrested()
  end
  hook.Remove("PlayerInitialSpawn", "luctus_modentities")
end)

print("[luctus_modentities] Loaded hook!")
