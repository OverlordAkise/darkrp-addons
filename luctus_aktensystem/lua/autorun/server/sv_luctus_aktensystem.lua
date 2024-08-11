--Luctus Aktensystem
--Made by OverlordAkise

util.AddNetworkString("luctus_aktensys")
util.AddNetworkString("luctus_aktensys_getply")
util.AddNetworkString("luctus_aktensys_getreport")
util.AddNetworkString("luctus_aktensys_save")
util.AddNetworkString("luctus_aktensys_edit")
util.AddNetworkString("luctus_aktensys_delete")

hook.Add("PostGamemodeLoaded","luctus_aktensystem",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_aktensys(date DATETIME, plySID TEXT, plyName TEXT, plyJobc TEXT, creatorName TEXT, creatorSID TEXT, summary TEXT, fulltext TEXT, active INT)")
    if res == false then ErrorNoHaltWithStack(sql.LastError()) end
end)

function LuctusAktensysGetReport(rowid)
    local ret = sql.QueryRow("SELECT rowid,* FROM luctus_aktensys WHERE active=1 AND rowid = "..rowid)
    if ret == false then
        ErrorNoHaltWithStack(sql.LastError())
        return {}
    end
    if ret then
        return ret
    end
    return {}
end

function LuctusAktensysGetPly(steamid,jobcommand)
    local jsql = ""
    if jobcommand and jobcommand ~= "" then
        jsql = " AND plyJobc="..sql.SQLStr(jobcommand)
    end
    local ret = sql.Query("SELECT rowid,date,plyName,plyJobc,creatorName,creatorSID,summary FROM luctus_aktensys WHERE plySID = "..sql.SQLStr(steamid)..jsql.." AND active=1 ORDER BY date DESC")
    if ret == false then
        ErrorNoHaltWithStack(sql.LastError())
        return {}
    end
    if ret then
        return ret
    end
    return {}
end

function LuctusAktensysSaveReport(creator, pSID, pName, pJob, summary, fulltext)
    local res = sql.Query("INSERT INTO luctus_aktensys VALUES( datetime('now') , "..SQLStr(pSID)..", "..SQLStr(pName)..", "..SQLStr(pJob)..", "..SQLStr(creator:Nick())..", "..SQLStr(creator:SteamID())..", "..SQLStr(summary)..", "..SQLStr(fulltext)..",1)")
    hook.Run("LuctusAktensysCreated",creator,pSID,pName,pJob,summary)
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
        return "ERROR SAVING REPORT!"
    end
    return "Successfully saved the report!"
end

function LuctusAktensysEditReport(rowid,newtext)
    local res = sql.Query("UPDATE luctus_aktensys SET fulltext=fulltext||"..sql.SQLStr(newtext).." WHERE rowid = "..rowid)
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
        return "ERROR EDITING REPORT!"
    end
    return "Successfully added to the report!"
end

function LuctusAktensysDeleteReport(rowid)
    if rowid < 1 then return end
    local res = sql.Query("UPDATE luctus_aktensys SET active = 0 WHERE rowid = "..rowid)
    hook.Run("LuctusAktensysDeleted",ply,rowid)
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
        return "ERROR DELETING REPORT!"
    end
    return "Successfully deleted report!"
end

function LuctusAktensysOwnsReport(ply,rowid)
    local res = sql.QueryValue("SELECT rowid FROM luctus_aktensys WHERE rowid="..rowid.." AND creatorSID="..sql.SQLStr(ply:SteamID()))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
        return false
    end
    if not res then return false end
    if tonumber(res) == tonumber(rowid) then
        return true
    end
    return false
end

hook.Add("PlayerSay","luctus_aktensys",function(ply,text,team)
    if text == LUCTUS_AKTENSYS_CHAT_COMMAND and LuctusAktensysHasAccess(ply) then
        if LUCTUS_AKTENSYS_PC_ONLY then
            ply:PrintMessage(HUD_PRINTTALK,"You can only open this menu by interacting with a PC!")
            return
        end
        net.Start("luctus_aktensys") net.Send(ply)
        return ""
    end
end)

net.Receive("luctus_aktensys_getply",function(len,ply)
    if not LuctusAktensysHasAccess(ply) then return end
    local steamid = net.ReadString()
    local jobcommand = net.ReadString()
    net.Start("luctus_aktensys_getply")
        local t = util.TableToJSON(LuctusAktensysGetPly(steamid,jobcommand))
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
    net.Send(ply)
    hook.Run("LuctusAktensysGetPlayer",ply,rid)
end)

net.Receive("luctus_aktensys_getreport",function(len,ply)
    if not LuctusAktensysHasAccess(ply) then return end
    local rid = net.ReadInt(32)
    net.Start("luctus_aktensys_getreport")
        local t = util.TableToJSON(LuctusAktensysGetReport(rid))
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
    net.Send(ply)
    hook.Run("LuctusAktensysGetReport",ply,rid)
end)

net.Receive("luctus_aktensys_save",function(len,ply)
    if not LuctusAktensysHasAccess(ply) then return end
    local steamid = net.ReadString()
    local name = net.ReadString()
    local jobname = net.ReadString()
    local summary = net.ReadString()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local fulltext = util.Decompress(data)
    local ret = LuctusAktensysSaveReport(ply, steamid, name, jobname, summary, fulltext)
    ply:PrintMessage(HUD_PRINTTALK, ret or "-")
end)

net.Receive("luctus_aktensys_edit",function(len,ply)
    if not LuctusAktensysHasAccess(ply) then return end
    local rowid = net.ReadInt(32)
    print("LuctusAktensysOwnsReport(ply,rowid)",LuctusAktensysOwnsReport(ply,rowid))
    if not (LuctusAktensysIsAdmin(ply) or LuctusAktensysOwnsReport(ply,rowid)) then return end
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local fulltext = util.Decompress(data)
    local addedText = "\n\n// EDIT BY "..ply:Nick().." ("..ply:SteamID()..") ON "..os.date("%Y/%m/%d %H:%M:%S").." //\n"..fulltext
    local ret = LuctusAktensysEditReport(rowid,addedText)
    ply:PrintMessage(HUD_PRINTTALK, ret or "-")
    hook.Run("LuctusAktensysEdited",ply,rowid)
end)

net.Receive("luctus_aktensys_delete",function(len,ply)
    if not LuctusAktensysHasAccess(ply) then return end
    if not LuctusAktensysIsAdmin(ply) then return end
    local rowid = net.ReadInt(32)
    local ret = LuctusAktensysDeleteReport(rowid)
    ply:PrintMessage(HUD_PRINTTALK, ret or "-")
end)

print("[luctus_aktensystem] sv loaded")
