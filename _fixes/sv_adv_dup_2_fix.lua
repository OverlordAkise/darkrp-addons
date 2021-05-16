--Luctus Advanced Duplicator 2 Crash Fix
--Made by OverlordAkise

hook.Add( "CanTool", "luctus_AdvDupeTwoAntiCrash", function( ply, tr, tool )
  local dupetab =
  (tool == 'adv_duplicator' and ply:GetActiveWeapon():GetToolObject().Entities) or
  (tool == 'advdupe2' and ply.AdvDupe2 and ply.AdvDupe2.Entities) or
  (tool == 'duplicator' and ply.CurrentDupe and ply.CurrentDupe.Entities)
  if dupetab then
    for k, v in pairs(dupetab) do
      if !v.ModelScale then return end
      if v.ModelScale > 10 then
        print("[AdvDupe2]".. ply:Nick().. " ("..ply:SteamID()..") tried to crash the server.")
        return false --Don't spawn the prop
      end
      v.ModelScale = 1
    end
  end
end)
