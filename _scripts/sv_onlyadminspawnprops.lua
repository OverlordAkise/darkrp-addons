--Luctus Admin-Only-Prop-Spawning Fix
--Made by OverlordAkise

--This allows admins to spawn props, even if GAMEMODE.Config.propspawning is set to false
--To disallow players from spawning props go to:
--darkrpmodification/lua/darkrp_config/settings.lua
--and set the "propspawning" config to false

hook.Add("DarkRPFinishedLoading", "luctus_adminonlyprops", function()
  if not GM then --GM should exist here
    print("[luctus_adminonlyprops] Error: Couldn't load!")
    return
  end
  print("[luctus_adminonlyprops] Successfully loading!")
  function GM:PlayerSpawnProp(ply, model)
    local allowed = GAMEMODE.Config.propspawning
    if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
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
end)