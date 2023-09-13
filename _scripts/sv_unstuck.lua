--Luctus Unstuck
--Made by OverlordAkise

--This doesn't need a cooldown because it only works if you are really stuck

hook.Add("PlayerSay", "luctus_unstuck", function(ply, text)
    if text == "!unstuck" then
        if ply:GetPhysicsObject():IsPenetrating() then
            ply:Spawn()
            ply:PrintMessage(HUD_PRINTTALK, "[unstuck] We respawned you to get unstuck.")
        else
            ply:PrintMessage(HUD_PRINTTALK, "[unstuck] You aren't stuck!")
        end
    end
end)

print("[luctus_unstuck] sv loaded")
