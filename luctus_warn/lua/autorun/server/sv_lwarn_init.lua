--Luctus Warn
--Made by OverlordAkise

util.AddNetworkString("lw_requestwarns")
util.AddNetworkString("lw_requestwarns_user")
util.AddNetworkString("lw_warnplayer")
util.AddNetworkString("lw_updatewarn")
util.AddNetworkString("lw_deletewarn")

LuctusLog = LuctusLog or function()end

function lwCheckPunishment(steamid)
    local activeWarns = sql.Query("SELECT SUM(active) FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
    if activeWarns==false then
        error(sql.LastError())
    end
    local ply = player.GetBySteamID(steamid)
    local number = tonumber(activeWarns[1]["SUM(active)"])
    local user = sql.SQLStr(steamid)
    if number and LUCTUS_WARN_BAN_CONFIG[number] ~= nil then
        local minutes = LUCTUS_WARN_BAN_CONFIG[number]
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has been banned for "..minutes.." minutes for having "..number.." warns.")
        lwPunish(ply, minutes, "[luctus_warn] You have been banned for "..minutes.." minutes for having too many warns!")
    end
    if number and number >= LUCTUS_WARNS_TILL_KICK then
        if not ply or ply==false then return end --Cant kick an offline player
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has been kicked for having "..number.." warns.")
        ply:Kick("[luctus_warn] You have been kicked for having too many warns!")
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
    PrintMessage(HUD_PRINTTALK,"[luctus_warn] "..ply:Nick().." was banned for '"..pMessage.."'!")
end

net.Receive("lw_warnplayer", function(len,ply)
    if LUCTUS_WARN_ADMINGROUPS[ply:GetUserGroup()] ~= true then return end
    target = net.ReadString()
    reason = net.ReadString()
    local res = sql.Query("INSERT INTO lwarn_warns(time, warneeid, targetid, warntext, active) VALUES(datetime('now', 'localtime'), "..sql.SQLStr(ply:SteamID())..", "..sql.SQLStr(target)..", "..sql.SQLStr(reason)..", 1 )")
    if res==false then
        error(sql.LastError())
    end
  
    lwCheckPunishment(target)
    if LUCTUS_WARN_SHOULD_ECHO_IN_CHAT then
        PrintMessage(HUD_PRINTTALK, "[luctus_warn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
    end
    print("[luctus_warn] "..ply:Nick().." warned "..target.." for '"..reason.."'.")
    
    local tply = player.GetBySteamID(target)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",name.."("..target..") has been warned by "..ply:Nick().."("..ply:SteamID()..") for '"..reason.."'.")
    hook.Run("LuctusWarnCreate",ply,name,target,reason) --warneePly, targetName, targetSteamID, reason
end)

net.Receive("lw_requestwarns", function(len, ply)
    if LUCTUS_WARN_ADMINGROUPS[ply:GetUserGroup()] ~= true then return end
    local steamid = net.ReadString()
    local data = ""
    if steamid != "" then
        data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE targetid="..sql.SQLStr(steamid)..";")
    else
        data = sql.Query("SELECT rowid,* FROM lwarn_warns ORDER BY rowid DESC LIMIT 20")
    end
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
    if data==false then
        error(sql.LastError())
    end
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
    if data==false then
        error(sql.LastError())
    end
end)

net.Receive("lw_updatewarn", function(len, ply)
    if LUCTUS_WARN_ADMINGROUPS[ply:GetUserGroup()] ~= true then return end
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
        error(sql.LastError())
    end
    if LUCTUS_WARN_SHOULD_ECHO_IN_CHAT then
        PrintMessage(HUD_PRINTTALK, "[luctus_warn] "..ply:Nick().." "..(shouldRemove and "removed" or "reactivated").." a warn from "..target..".")
    end
    print("[luctus_warn] "..ply:Nick().." "..(shouldRemove and "removed" or "reactivated").." a warn from "..target..".") 
    
    local tply = player.GetBySteamID(target)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has "..(shouldRemove and "removed" or "reactivated").." a warn of "..name.."("..target..")")
    hook.Run("LuctusWarnUpdate",ply,name,target,shouldRemove) --warneePly, targetName, targetSteamID, shouldRemove
end)

net.Receive("lw_deletewarn", function(len, ply)
    if LUCTUS_WARN_ADMINGROUPS[ply:GetUserGroup()] ~= true then return end
    if not ply:IsAdmin() then return end
  
    local rowid = net.ReadString()
    if not tonumber(rowid) then return end
    rowid = tonumber(rowid)
    local targetSID = net.ReadString()
    local data = sql.Query("DELETE FROM lwarn_warns WHERE rowid="..rowid.." AND targetid="..sql.SQLStr(targetSID))
    if data==false then
        error(sql.LastError())
    end
    if LUCTUS_WARN_SHOULD_ECHO_IN_CHAT then
        PrintMessage(HUD_PRINTTALK, "[luctus_warn] "..ply:Nick().." deleted a warn from "..targetSID..".")
    end
    print("[luctus_warn] "..ply:Nick().." deleted a warn from "..targetSID..".")
    
    local tply = player.GetBySteamID(targetSID)
    local name = "<offline>"
    if tply and IsValid(tply) then
        name = tply:Nick()
    end
    LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has deleted a warn of "..name.."("..targetSID..")")
    hook.Run("LuctusWarnDelete",ply,name,targetSID) --warneePly, targetName, targetSteamID, shouldRemove
end)

--Check for expired warns every 2 hours
timer.Create("CheckExpirationWarns",7200,0,function()
    print("[luctus_warn] Checking for expired warns...")
    local data = sql.Query("SELECT rowid,* FROM lwarn_warns WHERE active=1 AND datetime(time) < datetime('now','-"..LUCTUS_WARN_DAYS_TILL_EXPIRE.." days');")
    if data==false then
        error(sql.LastError())
    end
    if not data then return end
    if #data > 0 then
        print("[luctus_warn] Deleting "..(#data).." expired warns!")
        for k,v in pairs(data) do
            sql.Query("UPDATE lwarn_warns SET active=0 WHERE rowid="..v["rowid"])
        end
    end
    print("[luctus_warn] Finished checking for expired warns!")
end)

hook.Add("Initialize", "lwarn_init", function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS lwarn_warns (time DATETIME, warneeid TEXT, targetid TEXT, warntext TEXT, active INTEGER)")
    if data==false then
         ErrorNoHaltWithStack(sql.LastError())
    end
end)

print("[luctus_warn] Loaded SV file!")
