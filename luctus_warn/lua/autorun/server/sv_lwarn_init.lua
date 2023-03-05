--Luctus Warn
--Made by OverlordAkise

util.AddNetworkString("lw_requestwarns")
util.AddNetworkString("lw_warnplayer")
util.AddNetworkString("lw_updatewarn")
util.AddNetworkString("lw_deletewarn")
util.AddNetworkString("lw_requestwarns_user")--new

LuctusLog = LuctusLog or function()end

function lwCheckPunishment(steamid)
    local activeWarns = sql.Query("SELECT SUM(active) FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
    if activeWarns==false then
        print("[lwarn] SQL ERROR DURING PUNISHMENT CHECKING!")
        return
    end
    local ply = player.GetBySteamID(steamid)
    local number = tonumber(activeWarns[1]["SUM(active)"])
    local user = sql.SQLStr(steamid)
    if number and number >= lwconfig.warnsToKick then
        if not ply or ply==false then return end --Cant kick an offline player
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has been kicked for having "..number.." warns.")
        ply:Kick("[lwarn] You have been kicked for having too many warns!")
        sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..user..' has been kicked for having '..number..' warns!") ')
    end
    if number and lwconfig.warnsToBan[number] ~= nil then
        local minutes = lwconfig.warnsToBan[number]
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has been banned for "..minutes.." minutes for having "..number.." warns.")
        lwPunish(ply, minutes, "[lwarn] You have been banned for "..minutes.." minutes for having too many warns!")
        sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..user..' has been banned for '..minutes..' minutes for having '..number..' warns!") ')
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
    if lwconfig.chatWarns then
        PrintMessage(HUD_PRINTTALK, "[lwarn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
    end
    print("[lwarn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
    
    local tply = player.GetBySteamID(target)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",name.."("..target..") has been warned by "..ply:Nick().."("..ply:SteamID()..") for '"..reason.."'.")
end)

net.Receive("lw_requestwarns", function(len, ply)
    if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
    local steamid = net.ReadString()
    local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
    net.Start("lw_requestwarns")
    if data then
        local t = util.TableToJSON(data)
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
    else
        net.WriteInt(0,17)
    end
    net.Send(ply)
end)

net.Receive("lw_requestwarns_user", function(len, ply)
    if not ply.lwarnCD then ply.lwarnCD = 0 end
    if ply.lwarnCD > CurTime() then return end
    ply.lwarnCD = CurTime()+5
    local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE targetid="..sql.SQLStr(ply:SteamID())..";")
    net.Start("lw_requestwarns_user")
    if data then
        local t = util.TableToJSON(data)
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
    else
        net.WriteInt(0,17)
    end
    net.Send(ply)
end)

net.Receive("lw_updatewarn", function(len, ply)
    if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
    local rowid = net.ReadString()
    if not tonumber(rowid) then return end
    rowid = tonumber(rowid)
    local target = net.ReadString()
    local shouldRemove = net.ReadBool()
    local active = 1
    if shouldRemove then
        active = 0
    end
    local data = sql.Query("UPDATE lwarn_warns SET active="..active.." WHERE rowid="..rowid.." AND targetid="..sql.SQLStr(target))
    if data==false then
        print("[lwarn] SQL ERROR DURING UPDATE WARN!")
    end
    if lwconfig.chatWarns then
        PrintMessage(HUD_PRINTTALK, "[lwarn] "..ply:Nick().." "..(shouldRemove and "removed" or "reactivated").." a warn from "..target..".")
    end
    print("[lwarn] "..ply:Nick().." "..(shouldRemove and "removed" or "reactivated").." a warn from "..target..".") 
    sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..sql.SQLStr(ply:SteamID()).." has updated warn #"..rowid.." from "..sql.SQLStr(target)..'") ')
    
    local tply = player.GetBySteamID(target)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has "..(shouldRemove and "removed" or "reactivated").." a warn of "..name.."("..target..")")
end)

net.Receive("lw_deletewarn", function(len, ply)
    if lwconfig.allowedGroups[ply:GetUserGroup()] ~= true then return end
    if not ply:IsAdmin() then return end
  
    local rowid = net.ReadString()
    if not tonumber(rowid) then return end
    rowid = tonumber(rowid)
    local target = net.ReadString()
    local data = sql.Query("DELETE FROM lwarn_warns WHERE rowid="..rowid.." AND targetid="..sql.SQLStr(target))
    if(data==false)then
        print("[lwarn] SQL ERROR DURING DELETE WARN!")
    end
    if lwconfig.chatWarns then
        PrintMessage(HUD_PRINTTALK, "[lwarn] "..ply:Nick().." deleted a warn from "..target..".")
    end
    print("[lwarn] "..ply:Nick().." deleted a warn from "..target..".")
    sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "'..sql.SQLStr(ply:SteamID()).." deleted warn #"..rowid.." from "..sql.SQLStr(target)..'") ')
    
    local tply = player.GetBySteamID(target)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has deleted a warn of "..name.."("..target..")")
end)

--Check for expired warns every 2 hours
timer.Create("CheckExpirationWarns",7200,0,function()
    print("[lwarn] Checking for expired warns...")
    local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE active=1 AND datetime(time) < datetime('now','-"..lwconfig.daysToExpire.." days');")
    if data==false then
        print("[lwarn] SQL ERROR DURING EXPIRATION CHECK!")
        return
    end
    if not data then return end
    if #data > 0 then
        print("[lwarn] Deleting "..(#data).." expired warns!")
        for k,v in pairs(data) do
            sql.Query("UPDATE lwarn_warns SET active=0 WHERE rowid="..v["rowid"])
            sql.Query('INSERT INTO lwarn_logs(time, log) VALUES(datetime(), "Auto-Expiration has removed warn #'..v["rowid"]..' from '..v["targetid"]..' after '..lwconfig.daysToExpire..' days")')
        end
    end
    print("[lwarn] Finished checking for expired warns!")
end)

hook.Add("Initialize", "lwarn_init", function()
    sql.Query("CREATE TABLE IF NOT EXISTS lwarn_warns (time DATETIME, warneeid TEXT, targetid TEXT, warntext TEXT, active INTEGER)")
    sql.Query("CREATE TABLE IF NOT EXISTS lwarn_logs (time DATETIME, log TEXT)")
end)

print("[luctus_warn] Loaded SV file!")
