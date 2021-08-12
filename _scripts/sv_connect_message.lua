--Chef's Announcements
--Module of chefs-utilities
--Made by OverlordAkise

hook.Add("PlayerConnect","chef_aplayerconnected", function(name, ip )
  PrintMessage(HUD_PRINTTALK, name.." verbindet sich!")
end)

hook.Add("PlayerInitialSpawn", "chef_aplayerjoined", function(ply)
  --Still on "Starting Lua" here, from gmod lua wiki to circumvent:
  hook.Add("SetupMove", ply, function(self, ply, _, cmd)
      if self == ply and not cmd:IsForced() then 
        PrintMessage(HUD_PRINTTALK, ply:Nick().." ist dem Server beigetreten!")
        hook.Remove("SetupMove", self)
      end
  end)
end)

hook.Add("PlayerDisconnected", "chef_aplayerdisconnected", function(ply)
  PrintMessage(HUD_PRINTTALK, ply:Nick().." hat den Server verlassen! ("..ply:SteamID()..")")
end)