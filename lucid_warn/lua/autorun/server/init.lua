--LucidWarn
--by OverlordAkise

util.AddNetworkString("lw_requestwarns")
util.AddNetworkString("lw_warnplayer")
util.AddNetworkString("lw_removewarn")

function lwCheckPunishment(steamid)
  local activeWarns = sql.Query("SELECT SUM(active) FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
	if(activeWarns==false)then
    print("[lwarn] SQL ERROR DURING PUNISHMENT CHECKING!")
    return
  end
  local ply = player.GetBySteamID(steamid)
  local number = tonumber(activeWarns[1]["SUM(active)"])
  local user = sql.SQLStr(steamid)
  if(number == lwconfig.warnsToKick)then
    if(ply==false)then return end --Cant kick an offline player
    ply:Kick("[lwarn] You have been kicked for having too many warns!")
    sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..user..' has been kicked for having '..number..' warns!") ')
  end
  if(lwconfig.warnsToBan[number] ~= nil)then
    local minutes = lwconfig.warnsToBan[number]
    lwPunish(ply, minutes, "[lwarn] You have been banned for "..minutes.." minutes for having too many warns!")
    sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..user..' has been banned for '..minutes..' minutes for having '..number..' warns!") ')
    --print
  end
end

--bantime length = minutes
function lwPunish( ply, length, pMessage )
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
  PrintMessage(HUD_PRINTTALK,"[lwarn] "..ply:Nick().." was banned for '"..pMessage.."'!")
end

net.Receive("lw_warnplayer", function(len,ply)
  if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
	target = net.ReadString()
	reason = net.ReadString()
  sql.Query("INSERT INTO lwarn_warns(time, warneeid, targetid, warntext, active) VALUES(datetime('now', 'localtime'), "..sql.SQLStr(ply:SteamID())..", "..sql.SQLStr(target)..", "..sql.SQLStr(reason)..", 1 )")
  
  sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..sql.SQLStr(target)..' has been warned by '..ply:SteamID()..' for reason '..sql.SQLStr(reason)..'") ')
  
  lwCheckPunishment(target)
  if(lwconfig.chatWarns)then
    PrintMessage(HUD_PRINTTALK, "[lwarn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
  else
    print("[lwarn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
  end
end)

net.Receive("lw_requestwarns", function(len, ply)
	if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
  local steamid = net.ReadString()
	local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
  net.Start("lw_requestwarns")
  if(data)then
    local t = util.TableToJSON(data)
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
  else
    net.WriteInt(0,17)
  end
  net.Send(ply)
end)

net.Receive("lw_removewarn", function(len, ply)
	if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
	rowid = net.ReadString()
  target = net.ReadString()
  local data = sql.Query("UPDATE lwarn_warns SET active=0 WHERE rowid="..sql.SQLStr(rowid)..";")
  if(data==false)then
    print("[lwarn] SQL ERROR DURING REMOVE WARN!")
  end
  if(lwconfig.chatWarns)then
    PrintMessage(HUD_PRINTTALK, "[lwarn] "..ply:Nick().." removed a warn from "..target..".")
  else
    print("[lwarn] "..ply:Nick().." removed a warn from "..target..".")
  end 
  sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..sql.SQLStr(ply:SteamID()).." has removed warn #"..rowid.." from "..sql.SQLStr(target)..'") ')
end)

--Check for expired warns every 2 hours
timer.Create("CheckExpirationWarns",7200,0,function()
  print("[lwarn] Checking for expired warns...")
  local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE active=1 AND datetime(time) < datetime('now','-"..lwconfig.daysToExpire.." days');")
  if(data==false)then
    print("[lwarn] SQL ERROR DURING EXPIRATION CHECK!")
    return
  end
  if(data)then
    for k,v in pairs(data) do
      sql.Query("UPDATE lwarn_warns SET active=0 WHERE rowid="..v["rowid"]..";")
      sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "Auto-Expiration has removed warn #'..v["rowid"]..' from '..v["targetid"]..' after '..lwconfig.daysToExpire..' days") ')
    end
  end
  print("[lwarn] Finished checking for expired warns!")
end)

hook.Add("Initialize", "lwarn_init", function()
  sql.Query("CREATE TABLE IF NOT EXISTS lwarn_warns (time DATETIME, warneeid TEXT, targetid TEXT, warntext TEXT, active INTEGER)")
  sql.Query("CREATE TABLE IF NOT EXISTS lwarn_logs (time DATETIME, log TEXT)")
end)