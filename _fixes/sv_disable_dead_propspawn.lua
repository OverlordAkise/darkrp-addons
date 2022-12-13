--Disable propspawning while dead
--Made by OverlordAkise

hook.Add("PlayerSpawnProp", "luctus_fixes_nodead", function(ply, model)
    if not ply:Alive() then return false end
end)

print("[nodeadpropspawn_fix] Loaded hook!")
