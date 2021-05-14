--Luctus Charsystem
--Made by OverlordAkise

util.AddNetworkString("LuctusCharCreateProfile")
util.AddNetworkString("LuctusCharPlayProfile")
util.AddNetworkString("LuctusCharDeleteProfile")
util.AddNetworkString("LuctusCharAdminMenuOpen")
util.AddNetworkString("ColorMessage")
util.AddNetworkString("CharacterSystemOpenMenu")
util.AddNetworkString("ChangeNameOfChar")


hook.Add("DarkRPDBInitialized", "DBErstellen", function()
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_char (steamid varchar(255) NOT NULL, slot INTEGER NOT NULL, name varchar(255) NOT NULL, money INTEGER NOT NULL, job INTEGER NOT NULL, cloneid INTEGER)")
end)

hook.Add("postLoadCustomDarkRPItems", "luctus_char_disablejobs", function()
  --GM.Config.allowrpnames = false
  GM.Config.restrictallteams = true
  function DarkRP.storeMoney(ply, amount)
    if(ply.IsChoosingChar) then
      return
    end
    sql.Query("UPDATE luctus_char SET money = "..amount.." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..ply.charCurSlot)
  end
end)

hook.Add("PlayerInitialSpawn", "LuctusCharPlayerJoinServer", function(ply)
  ply.charCooldown = 0
  timer.Simple(3, function()
    ply:Lock() -- disable movement
    ply.IsChoosingChar = true
    ply.charCurSlot = -1

    net.Start("CharacterSystemOpenMenu")
      net.WriteTable(LuctusGetCharTable(ply))
    net.Send(ply)
  end)
end)

function LuctusGetCharTable(ply)
  local sqlCharTable = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  local CharTable = {}
  if not sqlCharTable then return CharTable end
  for k,v in pairs(sqlCharTable) do
    local CharSlot = v
    if(v.name and v.slot) then
      CharTable[tonumber(v.slot)] = v
    end
  end
  if ply.charCurSlot and CharTable[ply.charCurSlot] then
      CharTable[ply.charCurSlot]["playing"] = true
    end
  return CharTable
end

function LuctusGetJobFromCommand(cmd)
  for k,v in pairs(RPExtraTeams) do
    if (v["command"] == cmd) then
      return k
    end
  end
  return nil
end

function LuctusGetCommandFromJob(team)
  if (RPExtraTeams[team] ~= nil) then
    return RPExtraTeams[team]["command"]
  end
  return nil
end

--F2 = menu open
hook.Add("ShowTeam", "OpenLuctusCharWithF2", function(ply)
  net.Start("CharacterSystemOpenMenu")
    net.WriteTable(LuctusGetCharTable(ply))
  net.Send(ply)
end)

--If player changes team update his character to that one too
hook.Add("OnPlayerChangedTeam", "JobUpdatenLuctusChar", function(ply, oldjob, newjob)
  if(not ply.IsChoosingChar) then
    local jobcmd = LuctusGetCommandFromJob(newjob)
    local res = sql.Query("UPDATE luctus_char SET job = "..sql.SQLStr(jobcmd).." WHERE steamid = '"..ply:SteamID().."' and slot = "..ply.charCurSlot)
    if(res == false)then
      print("[luctus_char] ERROR DURING SQL UPDATE!")
      print(sql.LastError())
    end
  end
end)


net.Receive("LuctusCharPlayProfile", function(len,ply)
  if ply.charCooldown and ply.charCooldown > CurTime() then
    DarkRP.notify(ply,1,5,"You can only change your char every 10 seconds!")
    return
  end
  local Slot = net.ReadUInt(8)
  Slot = math.Clamp(Slot,1,3)
  local ProfileTable = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." and slot = "..Slot)
  if(ProfileTable == false) then
    print("[luctus_char] ERROR DURING SQL SELECT IN PLAYPROFILE!")
    print(sql.LastError())
  end
  if(not ProfileTable) then
    return
  end

  ProfileTable = ProfileTable[1]
  ply:UnLock()
  if(ply.IsChoosingChar) then  -- did the user join on the server and did not choose a profile?
    ply.IsChoosingChar = nil  -- he chose a profile
  end
  ply.charCurSlot = Slot
  local jobvar = LuctusGetJobFromCommand(ProfileTable.job)
  ply:changeTeam(jobvar, true, true)
  --ply:setRPName doesn't work here sadly
  ply:setRPName(tostring(ProfileTable.name))
  ply:setDarkRPVar("money", ProfileTable.money)
  ply:Spawn()
  ply.charCooldown = CurTime()+10
end)

net.Receive("LuctusCharCreateProfile", function(len,ply)
  local SlotNumber = net.ReadUInt(8)
  local name = net.ReadString()

  SlotNumber = math.Clamp(SlotNumber,1,3)

  local CharTable = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..SlotNumber)
  
  if not CharTable then --no char exists with that slot number for that player
    local doesNameExistAlready = sql.Query("SELECT name FROM luctus_char WHERE name = "..sql.SQLStr(name))
    if doesNameExistAlready then
      DarkRP.notify(ply,1,5,"ERROR: That name is already taken!")
      return
    end
    local jobcmd = LuctusGetCommandFromJob(LuctusChar.Config.DefaultTeam)
    local res = sql.Query("INSERT INTO luctus_char (steamid, slot, name, money, job) VALUES ("..sql.SQLStr(ply:SteamID())..", "..SlotNumber..", "..sql.SQLStr(name)..", "..LuctusChar.Config.DefaultMoney..", "..sql.SQLStr(jobcmd)..")")
    if (res == false) then
      print("[luctus_char] ERROR DURING SQL INSERT IN CREATEPROFILE")
      print(sql.LastError())
      return
    end
    DarkRP.notify(ply,0,5,"Character successfully created!")
  else
    DarkRP.notify(ply,1,5,"You can't create 2 characters on one slot!")
  end
  
  net.Start("CharacterSystemOpenMenu")
    net.WriteTable(LuctusGetCharTable(ply))
  net.Send(ply)
end)

net.Receive("LuctusCharDeleteProfile", function(len,ply)
  local DeletedSlot = net.ReadUInt(8)
  DeletedSlot = math.Clamp(DeletedSlot,1,3)
  
  if(DeletedSlot == ply.charCurSlot) then
    DarkRP.notify(ply,1,4,"Can't delete a character that you are currently playing!")
    return
  end
  
  local res = sql.Query("DELETE FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..DeletedSlot)
  if (res == false) then
    print("[luctus_char] ERROR DURING SQL DELETE IN DELETEPROFILE")
    print(sql.LastError())
    return
  end
  DarkRP.notify(ply,0,4,"Character successfully deleted!")

  net.Start("CharacterSystemOpenMenu")
    net.WriteTable(LuctusGetCharTable(ply))
  net.Send(ply)
end)



function LuctusGetPlayerFromName(name)
  if(!name) then return end
  for k,v in pairs(player.GetAll()) do
    if string.find(string.lower(v:getDarkRPVar("rpname")), string.lower(name)) then
      return v
    end
  end
  return nil
end



local PLAYER = FindMetaTable("Player")

function PLAYER:ChatAddText(...)  -- Variable number of arguments
  net.Start("ColorMessage")
  net.WriteTable({...})
  net.Send(self)
end
