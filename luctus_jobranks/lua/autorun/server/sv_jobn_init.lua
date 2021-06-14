--Luctus Jobnames
--Made by OverlordAkise

luctus_jobranks = {}
hook.Add("postLoadCustomDarkRPItems", "luctus_jobranks_init", function()

  --CONFIG START HERE
  
  --Put the Job name in the square brackets
  --the curly brackets contain:
  --  The short name infront of your Player name
  --  The long name behind your Job name
  --  If the rank can up / downrank other players
  --  What weapons the rank spawns with
  -- An Example of an Officer who can de/uprank and spawns with a crowbar:
  --  [2] = {"[O]", "Officer", true, {"weapon_crowbar"}},
  
  luctus_jobranks[TEAM_MTFE6] = {
    [1] = {"[R]", "Recuit"},
    [2] = {"[PVT]", "Private"},
    [3] = {"[PFC]", "Private First Class"},
    [4] = {"[SPC]", "Specialist"},
    [5] = {"[CPL]", "Corporal"},
    [6] = {"[SGT]", "Sergeant"},
    [7] = {"[SSGT]", "Staff Sergeant"},
    [8] = {"[SFC] ", "Sergeant First Class"},
    [9] = {"[FSG]", "First Sergeant",true},
    [10] = {"[SGM]", "Sergeant Major",true},
    [11] = {"[LT]", "Lieutenant",true},
    [12] = {"[CPT]", "Captain",true},
    [13] = {"[MAJ]", "Major",true}
  }
  
  luctus_jobranks[TEAM_MTFN7] = {
    [1] = {"[SGT]", "Sergeant"},
    [2] = {"[SSGT]", "Staff Sergeant"},
    [3] = {"[SFC] ", "Sergeant First Class"},
    [4] = {"[FSG]", "First Sergeant",true},
    [5] = {"[SGM]", "Sergeant Major",true},
    [6] = {"[LT]", "Lieutenant",true},
    [7] = {"[CPT]", "Captain",true},
    [8] = {"[MAJ]", "Major",true}
  }
  
  --You can also copy ranks, but the ranks of players will NOT copy over! Only the config gets copied!
  luctus_jobranks[TEAM_MTFD5] = luctus_jobranks[TEAM_MTFN7]
  
  luctus_jobranks[TEAM_MTFA1] = {
    [1] = {"[LCOL]", "Lieutenant Colonel",true},
    [2] = {"[COL]", "Colonel",true}
  }
  
  luctus_jobranks[TEAM_SECURITY] = {
    [1] = {"[R]", "Rekrut",false,{"guthscp_keycard_lvl_2","m9k_mp5sd"}},
    [2] = {"[P]", "Private",false,{"guthscp_keycard_lvl_3","m9k_mp5sd"}},
    [3] = {"[C]", "Corporal",false,{"guthscp_keycard_lvl_3","m9k_mp5sd"}},
    [4] = {"[SGT]", "Seargent",false,{"guthscp_keycard_lvl_3","m9k_m4a1"}},
    [5] = {"[L]", "Leader",false,{"guthscp_keycard_lvl_3","m9k_m4a1"}},
    [6] = {"[WC]", "Watchcommander",true,{"guthscp_keycard_lvl_3","m9k_m16a4_acog"}},
    [7] = {"[Chief]", "Chief",true,{"guthscp_keycard_lvl_4","m9k_m16a4_acog"}}
  }
  
  luctus_jobranks[TEAM_WISSENSCHAFTLER] = {
    [1] = {"[JR]", "Junior"},
    [2] = {"[AD]", "Advanced"},
    [3] = {"[PFS]", "Professor"},
    [4] = {"[PF]", "Prof"},
    [5] = {"[SPF]", "Senior Professor"},
    [6] = {"[WH]", "Wächter"},
    [7] = {"[SWH]", "Science of Wächter",true}
  }
  
  luctus_jobranks[TEAM_ARZT] = {
    [1] = {"[S]", "Student"},
    [2] = {"[AA]", "Assistents Arzt"},
    [3] = {"[FA]", "Facharzt"},
    [4] = {"[SA]", "Stabsarzt"},
    [5] = {"[OA]", "Oberarzt"},
    [6] = {"[CA]", "Chefarzt",true},
    [7] = {"[L]", "Leitung",true}
  }
  
  
  --CONFIG END HERE
  print("[luctus_jobranks] Config loaded!")
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT )") --Safety
end)

hook.Add("PostGamemodeLoaded","luctus_jobranks_dbinit",function()
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_jobranks( steamid TEXT, jobcmd TEXT, rankid INT )")
end)

local function luctusGetPlayer(name)
  local ret = nil
  for k,v in pairs(player.GetAll()) do
    if string.find( string.lower(v:Nick()), string.lower(name) ) then
      if ret ~= nil then
        return nil
      end
      ret = v
    end
  end
  return ret
end



function luctusGetRankID(team,rankShort)
  if not luctus_jobranks[team] then return nil end
  local count = 1
  for k,v in pairs(luctus_jobranks[team]) do
    if v[1] == rankShort then
      return k
    end
  end
  return nil
end



function luctusRankup(ply,teamcmd,executor)
  local newId = 0
  local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
  if res == false then
    print("[luctus_jobranks] ERROR DURING SQL SELECT RANKUP!")
    print(sql.LastError())
    return
  end
  if res and res[1] then
    newId = math.min(tonumber(res[1].rankid) + 1,#luctus_jobranks[ply:Team()])
    --print(newId)
    local ires = sql.Query("UPDATE luctus_jobranks SET rankid = "..(newId).." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
    if ires == false then
      print("[luctus_jobranks] ERROR DURING SQL UPDATE RANKUP!")
      print(sql.LastError())
      return
    end
    DarkRP.notify(ply,0,5,"Du wurdest befördert!")
    ply:PrintMessage(HUD_PRINTTALK, "Du wurdest befördert!")
    ply:SetNWString("l_nametag", luctus_jobranks[ply:Team()][newId][1])
    ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[ply:Team()][newId][2]..")")
    ply.lrankID = newId
  else
    print("[luctus_jobranks] ERROR DURING SQL SELECT RANKUP!")
  end
end



function luctusRankdown(ply,teamcmd,executor)
  local newId = 0
  local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
  if res == false then
    print("[luctus_jobranks] ERROR DURING SQL SELECT RANKDOWN!")
    print(sql.LastError())
    return
  end
  if res and res[1] then
    newId = math.max(tonumber(res[1].rankid) - 1,1)
    local ires = sql.Query("UPDATE luctus_jobranks SET rankid = "..(newId).." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(teamcmd))
    if ires == false then
      print("[luctus_jobranks] ERROR DURING SQL UPDATE RANKDOWN!")
      print(sql.LastError())
      return
    end
    DarkRP.notify(ply,0,5,"Du wurdest degradiert!")
    ply:PrintMessage(HUD_PRINTTALK, "Du wurdest degradiert!")
    ply:SetNWString("l_nametag", luctus_jobranks[ply:Team()][newId][1])
    ply:updateJob(ply:getJobTable().name.." ("..luctus_jobranks[ply:Team()][newId][2]..")")
    ply.lrankID = newId
  end
end



hook.Add("PlayerSay", "luctus_jobranks_promote", function(ply,text,team)
  if string.Split(text," ")[1] == "!promote" then
    local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
    if rankID and luctus_jobranks[ply:Team()][rankID][3] then
      local tPly = luctusGetPlayer(string.Split(text," ")[2])
      if not tPly then
        ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
        return
      end
      if ply:Team() ~= tPly:Team() then
        ply:PrintMessage(HUD_PRINTTALK, "Du kannst keine anderen Jobs promoten!")
        return
      end
      local tRankID = luctusGetRankID(tPly:Team(),tPly:GetNWString("l_nametag",""))
      if tRankID and rankID > tRankID+1 then
        luctusRankup(tPly,RPExtraTeams[tPly:Team()].command,executor)
      else
        ply:PrintMessage(HUD_PRINTTALK, "Du kannst nicht auf deinen Rang hochpromoten!")
      end
    else
      ply:PrintMessage(HUD_PRINTTALK, "Du hast keine Berechtigung für !promote!")
      return ""
    end
  end
  if string.Split(text," ")[1] == "!demote" then
    local rankID = luctusGetRankID(ply:Team(),ply:GetNWString("l_nametag",""))
    if rankID and luctus_jobranks[ply:Team()][rankID][3] then
      local tPly = luctusGetPlayer(string.Split(text," ")[2])
      if not tPly then
        ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
        return
      end
      if ply:Team() ~= tPly:Team() then
        ply:PrintMessage(HUD_PRINTTALK, "Du kannst keine anderen Jobs demoten!")
        return
      end
      local tRankID = luctusGetRankID(tPly:Team(),tPly:GetNWString("l_nametag",""))
      if tRankID and rankID > tRankID then
        luctusRankdown(tPly,RPExtraTeams[tPly:Team()].command,executor)
      else
        ply:PrintMessage(HUD_PRINTTALK, "Du kannst diesen Spieler nicht demoten!")
      end
    else
      ply:PrintMessage(HUD_PRINTTALK, "Du hast keine Berechtigung für !demote!")
      return ""
    end
  end
  if string.Split(text," ")[1] == "!apromote" then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local tPly = luctusGetPlayer(string.Split(text," ")[2])
      if not tPly then
        ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
        return ""
      end
      luctusRankup(tPly,RPExtraTeams[tPly:Team()].command,executor)
      return ""
    else
      ply:PrintMessage(HUD_PRINTTALK, "Du hast keinen Zugang zu diesem Befehl!")
    end
  end
  if string.Split(text," ")[1] == "!ademote" then
    if ply:IsAdmin() or ply:IsSuperAdmin() then
      local tPly = luctusGetPlayer(string.Split(text," ")[2])
      if not tPly then
        ply:PrintMessage(HUD_PRINTTALK, "Ziel-Spieler nicht gefunden!")
        return ""
      end
      luctusRankdown(tPly,RPExtraTeams[tPly:Team()].command,executor)
      return ""
    else
      ply:PrintMessage(HUD_PRINTTALK, "Du hast keinen Zugang zu diesem Befehl!")
    end
  end
end)


hook.Add("PlayerSpawn", "luctus_nametags", function(ply)
  if ply.lrankID and tonumber(ply.lrankID) and luctus_jobranks[ply:Team()] and luctus_jobranks[ply:Team()][ply.lrankID] then
    if luctus_jobranks[ply:Team()][ply.lrankID][4] then
      for k,v in pairs(luctus_jobranks[ply:Team()][ply.lrankID][4]) do
        ply:Give(v)
      end
    end
  end
end)



hook.Add("OnPlayerChangedTeam", "luctus_nametags", function(ply, beforeNum, afterNum)

  --switch from X
  if beforeNum == TEAM_DKLASSE then
    ply:SetNWString("l_nametag","")
  end
  if luctus_jobranks[beforeNum] then
    ply:SetNWString("l_nametag","")
    ply.lrankID = nil
  end
  if beforeNum == TEAM_RAT then
    ply:SetNWString("l_nametag","")
  end
  
  --switch to D-Klasse
  if afterNum == TEAM_DKLASSE then
    ply:SetNWString("l_nametag","[D-"..math.random(1000,9999).."]")
  end
  --switch to O5 Rat
  if afterNum == TEAM_RAT then
    local rats = 0
    for k,v in pairs(player.GetAll()) do
      if v:Team() == TEAM_RAT then rats = rats + 1 end
    end
    ply:SetNWString("l_nametag", "[O5-"..(rats).."]") 
  end
  --Jobranks
  if luctus_jobranks[afterNum] then
    local res = sql.Query("SELECT * FROM luctus_jobranks WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND jobcmd = "..sql.SQLStr(RPExtraTeams[afterNum].command))
    if res == false then
      print("[luctus_jobranks] ERROR DURING SQL SELECT JOBRANKS!")
      print(sql.LastError())
      return
    end
    if res and res[1] then
      local rankid = res[1].rankid
      if not tonumber(rankid) then
        print("[luctus_jobranks] ERROR SELECT RANKID WAS NOT A NUMBER!")
        return
      end
      rankid = tonumber(rankid)
      ply:SetNWString("l_nametag",luctus_jobranks[afterNum][rankid][1])
      ply:updateJob(ply:getDarkRPVar("job").." ("..luctus_jobranks[afterNum][rankid][2]..")")
      ply.lrankID = rankid
    else
      local inres = sql.Query("INSERT INTO luctus_jobranks(steamid,jobcmd,rankid) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(RPExtraTeams[afterNum].command)..",1)")
      if inres == false then
        print("[luctus_jobranks] ERROR DURING SQL INSERT NEW JOBRANKS!")
        print(sql.LastError())
        return
      end
      if inres == nil then
        print("[luctus_jobranks] New player successfully inserted!")
      end
      ply:SetNWString("l_nametag", luctus_jobranks[afterNum][1][1])
      ply:updateJob(ply:getDarkRPVar("job").." ("..luctus_jobranks[afterNum][1][2]..")")
      ply.lrankID = 1
    end
  end
    
end)
