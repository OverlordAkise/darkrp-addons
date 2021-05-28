--Lucid Whitelist
--Made by OverlordAkise

util.AddNetworkString("lucid_whitelist_get")
util.AddNetworkString("lucid_whitelist_set")

hook.Add("PlayerInitialSpawn", "lucid_whitelist", function(ply)
  local sqlData = sql.Query("SELECT * FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  if(sqlData and sqlData != false and sqlData[1])then
    local jsonData = util.JSONToTable(sqlData[1].jsonlist)
    for k,v in pairs(jsonData) do
      ply:SetNWBool(k,v)
    end
  end
end)

hook.Add("InitPostEntity","lucid_whitelist",function()
  sql.Query("CREATE TABLE IF NOT EXISTS lucid_whitelist( steamid TEXT, jsonlist TEXT )")
  local sqlData = sql.Query("SELECT * FROM lucid_whitelist WHERE steamid = 'everyone'")
  _G["lwhitelist_wspawn"] = nil
  for k,v in pairs(ents.GetAll()) do
    if(v:GetClass() == "worldspawn")then
      _G["lwhitelist_wspawn"] = v
    end
  end
  if(sqlData and sqlData != false and sqlData[1] and _G["lwhitelist_wspawn"])then
    local jsonData = util.JSONToTable(sqlData[1].jsonlist)
    for k,v in pairs(jsonData) do
      _G["lwhitelist_wspawn"]:SetNWBool(k,v)
    end
  end
end)


net.Receive("lucid_whitelist_set", function(len,ply)
  if not ply:IsAdmin() then return end
  
  local steamid = net.ReadString()
  local lenge = net.ReadInt(17)
  local data = net.ReadData(lenge)
  local jtext = util.Decompress(data)
  local jsondata = util.JSONToTable(jtext)
  local res = sql.Query("DELETE FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(steamid))
  if(res == false)then
    print("[lwhitelist] ERROR DURING SQL SET DELETE!")
  else
    print("[lwhitelist] Successfully deleted old whitelist for user "..steamid)
  end
  res = sql.Query("INSERT INTO lucid_whitelist(steamid,jsonlist) VALUES("..sql.SQLStr(steamid)..", "..sql.SQLStr(jtext)..")")
  if(res == false)then
    print("[lwhitelist] ERROR DURING SQL SET INSERT!")
  else
    print("[lwhitelist] Successfully inserted new whitelist for user "..steamid)
  end
  
  local ent = nil
  if(steamid == "everyone")then
    ent = _G["lwhitelist_wspawn"]
  else
    for k,v in pairs(player.GetAll()) do
      if v:SteamID() == steamid then
        ent = v
        break
      end
    end
  end
  if(ent)then
    for job_index,job in pairs(RPExtraTeams) do
      if(jsondata[job.name])then
        ent:SetNWBool(job.name,true)
      else
        ent:SetNWBool(job.name,false)
      end
    end
  end
end)

net.Receive("lucid_whitelist_get", function(len,ply)
  if not ply:IsAdmin() then return end
  print("lucid_whitelist_get")
  local steamid = net.ReadString()
  
  if not (steamid:find("^STEAM_%d:%d:%d+$") or steamid == "everyone") then
    DarkRP.notify(ply, 1, 5, "[lwhitelist] You didn't send a valid ID!")
    return
  end
  
  local sqlData = sql.Query("SELECT * FROM lucid_whitelist WHERE steamid = "..sql.SQLStr(steamid))
  
  net.Start("lucid_whitelist_get")
  net.WriteString(steamid)
  if(sqlData and sqlData != false and sqlData[1])then
    print("Sending: "..sqlData[1].jsonlist)
    jsontab = sqlData[1].jsonlist
  else
    print("Sending: {}")
    jsontab = "{}"
  end
  
  local a = util.Compress(jsontab)
  net.WriteInt(#a,17)
  net.WriteData(a,#a)
  net.Send(ply)

end)

print("[lwhitelist] Lucid Whitelist server loaded!")