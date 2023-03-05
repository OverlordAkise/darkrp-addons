--Luctus Research
--Made by OverlordAkise

--Current limits:
--  Only Admins can edit and delete papers

--CONFIG START
lucidResearchChatCommand = "!research"
lucidResearchAllowedJobs = {
  ["Citizen"] = true,
  ["Researcher"] = true,
  ["Wissenschaftler"] = true,
}
--CONFIG END

util.AddNetworkString("luctus_research_getall")
util.AddNetworkString("luctus_research_getid")
util.AddNetworkString("luctus_research_save")
util.AddNetworkString("luctus_research_editid")
util.AddNetworkString("luctus_research_deleteid")

LuctusLog = LuctusLog or function()end

hook.Add("PostGamemodeLoaded","lucid_log",function()
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_research(date DATETIME, researcher TEXT, summary TEXT, fulltext TEXT, active INT)")
end)


local function luctusGetPaper(_rowid)
  local rowid = tonumber(_rowid)
  if not rowid then return {} end
  local ret = sql.Query("SELECT rowid,* FROM luctus_research WHERE rowid = "..rowid)
  if ret == false then
    ErrorNoHaltWithStack(sql.LastError())
    return {}
  end
  if ret and ret[1] then
    return ret[1]
  end
  return {}
end

local function luctusGetPapers(_page,_category,_filter)
  local page = tonumber(_page)
  if not page then return {} end
  local filter = _filter or ""
  if filter != "" then
    if string.find( filter, '[\'\\/%*%?"<>|=]' ) ~= nil then
      return {}
    end
    filter = "%"..filter.."%"
  else
    filter = "%"
  end
  local category = "summary"
  if _category then
    category = _category
  end
  page = page * 24
  local ret = sql.Query("SELECT rowid,date,researcher,summary FROM luctus_research WHERE "..category.." LIKE "..sql.SQLStr(filter).." AND active = 1 ORDER BY date DESC limit 24 offset "..page)
  if(ret==false)then
    ErrorNoHaltWithStack(sql.LastError())
    return {}
  end
  if ret and ret ~= nil then
    return ret
  end
  return {}
end

local function luctusSavePaper(researcher,summary,fulltext)
  local res = sql.Query("INSERT INTO luctus_research VALUES( datetime('now') , "..SQLStr(researcher)..", "..SQLStr(summary)..", "..SQLStr(fulltext)..",1)")
  if res == false then
    ErrorNoHaltWithStack(sql.LastError())
    return "ERROR SAVING PAPER!"
  end
  return "Successfully saved the paper!"
end

local function luctusEditPaper(_rowid,researcher,summary,fulltext)
  local rowid = tonumber(_rowid)
  if not rowid then return "ERROR SAVING PAPER; ROWID WAS NOT A NUMBER!" end
  
  local res = sql.Query("UPDATE luctus_research SET date = datetime('now'), researcher = "..SQLStr(researcher)..", summary = "..SQLStr(summary)..", fulltext = "..SQLStr(fulltext)..", active = 1 WHERE rowid = "..rowid)
  if res == false then
    ErrorNoHaltWithStack(sql.LastError())
    return "ERROR EDITING PAPER!"
  end
  return "Successfully edited the paper!"
end

hook.Add("PlayerSay","luctus_research",function(ply,text,team)
  if text == lucidResearchChatCommand and lucidResearchAllowedJobs[ply:getJobTable().name] then
    net.Start("luctus_research_getall")
    local t = util.TableToJSON(luctusGetPapers(0))
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
    net.Send(ply)
  end
end)

local categories = {
  [1] = "summary",
  [2] = "researcher",
}

net.Receive("luctus_research_getall",function(len,ply)
  if not lucidResearchAllowedJobs[ply:getJobTable().name] then return end
  local page = net.ReadInt(32)
  local category = net.ReadInt(4)
  local filter = net.ReadString()
  if category ~= 0 and not categories[category] then return end
  net.Start("luctus_research_getall")
    local t = util.TableToJSON(luctusGetPapers(page,categories[category],filter))
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
  net.Send(ply)
  LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") requested all papers")
end)

net.Receive("luctus_research_getid",function(len,ply)
  if not lucidResearchAllowedJobs[ply:getJobTable().name] then return end
  local rid = net.ReadInt(32)
  local edit = net.ReadBool()
  local paper = luctusGetPaper(rid)
  paper.edit = edit
  net.Start("luctus_research_getid")
    local t = util.TableToJSON(paper)
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
  net.Send(ply)
  LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") requested paper #"..rid)
end)

net.Receive("luctus_research_save",function(len,ply)
  if not lucidResearchAllowedJobs[ply:getJobTable().name] then return end
  local summary = net.ReadString()
  local researcher = net.ReadString()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local fulltext = util.Decompress(data)
  local ret = luctusSavePaper(researcher,summary,fulltext)
  ply:PrintMessage(HUD_PRINTTALK, ret)
  LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") created new paper")
end)

net.Receive("luctus_research_editid",function(len,ply)
  if not lucidResearchAllowedJobs[ply:getJobTable().name] then return end
  if not ply:IsAdmin() then return end
  local rowid = net.ReadInt(32)
  local summary = net.ReadString()
  local researcher = net.ReadString()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local fulltext = util.Decompress(data)
  local ret = luctusEditPaper(rowid,researcher,summary,fulltext)
  ply:PrintMessage(HUD_PRINTTALK, ret)
  LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") edited paper #"..rowid)
end)

net.Receive("luctus_research_deleteid",function(len,ply)
  if not lucidResearchAllowedJobs[ply:getJobTable().name] then return end
  if not ply:IsAdmin() then return end
  local _rowid = net.ReadInt(32)
  if not tonumber(_rowid) then return end
  local rowid = tonumber(_rowid)
  if rowid < 1 then return end
  local res = sql.Query("UPDATE luctus_research SET active = 0 WHERE rowid = "..rowid)
  if res == false then
    error(sql.LastError())
  end
  ply:PrintMessage(HUD_PRINTTALK, "Successfully deleted paper!")
  LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") deleted paper #"..rowid)
end)

print("[luctus_research] Loaded SV!")
