--Luctus Hide Voice Icons Overhead
--Made by OverlordAkise

--This mainly exists to remind me how to do it

hook.Add("PlayerInitialSpawn", "luctus_voice_icon_remove", function(ply)
    RunConsoleCommand("mp_show_voice_icons",0)
    hook.Remove("PlayerInitialSpawn", "luctus_voice_icon_remove")
end)
