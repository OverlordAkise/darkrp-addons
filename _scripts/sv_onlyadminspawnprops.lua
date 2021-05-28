--Luctus Admin-Only-Prop-Spawning Fix
--Made by OverlordAkise

--This allows admins and teammembers to spawn props, even if GAMEMODE.Config.propspawning is set to false

--To disallow players from spawning props go to:
--darkrpmodification/lua/darkrp_config/settings.lua
--and set the "propspawning" config to false
--^this must be set in order for this to work!

hook.Add("PlayerInitialSpawn", "luctus_adminonlyprops", function()
  if not GM and not GAMEMODE then
    print("[luctus_adminonlyprops] Error: Couldn't load!")
    return
  end
  
  local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
  }
  function GAMEMODE:PlayerSpawnProp(ply, model)
    if allowedRanks[ply:GetUserGroup()] then return true end
    local allowed = GAMEMODE.Config.propspawning
    if not allowed then return false end
    if ply:isArrested() then return false end
    model = string.gsub(tostring(model), "\\", "/")
    model = string.gsub(tostring(model), "//", "/")
    local jobTable = ply:getJobTable()
    if jobTable.PlayerSpawnProp then
        jobTable.PlayerSpawnProp(ply, model)
    end
    return self.Sandbox.PlayerSpawnProp(self, ply, model)
  end
  hook.Remove("PlayerInitialSpawn", "luctus_adminonlyprops")
  print("[luctus_adminonlyprops] Successfully loaded!")
end)

print("[luctus_adminonlyprops] Loaded hook!")