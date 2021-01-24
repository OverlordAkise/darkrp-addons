--Lucid Anticheat
--Made by OverlordAkise

util.AddNetworkString("lucidac_change")
util.AddNetworkString("lucidac_bestrafe")


--Disable cheating by DarkRP
hook.Add("PostGamemodeLoaded","chef_changeSVLua",function()
  RunConsoleCommand("sv_allowcslua","0")
  GAMEMODE.Config.disallowClientsideScripts = true
  timer.Simple(30,function()
    RunConsoleCommand("sv_allowcslua","0")
    GAMEMODE.Config.disallowClientsideScripts = true
  end)
end)

--bantime length = minutes
function ChefAC_Punish( ply, length, pMessage)
  if not IsValid( ply ) then return end
  if ulx then
    ULib.ban( ply, length, pMessage )
  elseif xAdmin then
    xAdmin.RegisterNewBan( ply, "CONSOLE", pMessage, length )
    ply:Kick( pMessage )
  elseif SAM then
    SAM.AddBan( ply:SteamID(), nil, length * 60, pMessage )
  else
    ply:Ban( length, false )
    ply:Kick( pMessage )
  end
  PrintMessage(HUD_PRINTTALK,"[LucidAC] "..ply:Nick().." was banned for '"..pMessage.."'!")
end

net.Receive("lucidac_change",function(len,ply)
  local conname = net.ReadString()
  local convalue = net.ReadString()
  if convalue != GetConVar(conname):GetString() then
    print("[LucidAC] "..ply:Nick().." was banned for changing convars.")
    --PrintMessage(HUD_PRINTTALK, "BANNED!")
    ChefAC_Punish(ply,0,"[LucidAC] Banned for cheating.")
  end
end)

net.Receive("lucidac_bestrafe",function(len,ply)
  local reason = net.ReadString()
  print("[LucidAC] "..ply:Nick().." was banned for '"..reason.."'.")
  --PrintMessage(HUD_PRINTTALK, "BANNED!")
  ChefAC_Punish(ply,0,"[LucidAC] Banned for cheating.")
end)

print("[LucidAC] Serverside loaded!")