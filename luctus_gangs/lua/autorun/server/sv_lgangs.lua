--Luctus Gangs
--Made by OverlordAkise

util.AddNetworkString("luctus_gangs")
util.AddNetworkString("luctus_gang_menu")
util.AddNetworkString("luctus_gang_members")
util.AddNetworkString("luctus_gang_create")
util.AddNetworkString("luctus_gang_motd")

luctus_gang_cache = {}

net.Receive("luctus_gangs", function(len,ply)
  local method = net.ReadString()
  if method == "create" then
    luctusCreateGang(ply,net.ReadString())
  elseif method == "delete" then
    luctusDeleteGang(ply)
  elseif method == "leave" then
    luctusLeaveGang(ply)
  elseif method == "invite" then
    luctusInviteGang(ply,net.ReadString())
  elseif method == "kick" then
    luctusKickGang(ply,net.ReadString())
  elseif method == "getmembers" then
    luctusGetGangMembers(ply)
  elseif method == "sendmoney" then
    luctusRetrieveGangMoney(ply,net.ReadString())
  elseif method == "getmoney" then
    luctusDepositGangMoney(ply,net.ReadString())
  end
end)

function luctusRetrieveGangMoney(ply,stramount)
  local amount = tonumber(stramount)
  if not amount or amount < 1 then
    DarkRP.notify(ply,1,5,"Please enter a number and more than 1!")
    return
  end
  local gangname = ply:GetNWString("gang","")
  if gangname == "" then return end
  local res = sql.QueryRow("SELECT * FROM luctus_gangs WHERE name = "..sql.SQLStr(gangname))
  if res == false then
    print("[luctus_gangs] ERROR DURING RETRIEVEGANGMONEY SQL 1/2!")
    print(sql.LastError())
    return
  end
  local availableMoney = tonumber(res.money)
  if not availableMoney or availableMoney == 0 then return end
  if amount > availableMoney then amount = availableMoney end
  ply:addMoney(amount)
  res = sql.Query("UPDATE luctus_gangs SET money = "..(availableMoney-amount).." WHERE name = "..sql.SQLStr(gangname))
  if res == false then
    print("[luctus_gangs] ERROR DURING RETRIEVEGANGMONEY SQL 2/2!")
    print("[luctus_gangs] WARNING: WHILE THIS PERSISTS PLAYERS CAN GET INFINITE MONEY!")
    print(sql.LastError())
    return
  end
  DarkRP.notify(ply,0,5,"You retrieved "..amount.."$ from your gang!")
end

function luctusDepositGangMoney(ply,stramount)
  local amount = tonumber(stramount)
  if not amount or amount < 1 then
    DarkRP.notify(ply,1,5,"Please enter a number and more than 1!")
    return
  end
  local gangname = ply:GetNWString("gang","")
  if gangname == "" then return end
  if not ply:canAfford(amount) then
    DarkRP.notify(ply,1,5,"You don't have that much money!")
    return
  end
  ply:addMoney(-1 * amount)
  res = sql.Query("UPDATE luctus_gangs SET money = money + "..amount.." WHERE name = "..sql.SQLStr(gangname))
  if res == false then
    print("[luctus_gangs] ERROR DURING DEPOSITGANGMONEY SQL 2/2!")
    print(sql.LastError())
    return
  end
  DarkRP.notify(ply,0,5,"You deposit "..amount.."$ to your gang!")
end

function luctusCreateGang(ply,name)
  local res = sql.Query("INSERT INTO luctus_gangs(createtime,creator,name,motd,money,xp,level) VALUES(datetime('now', 'localtime'), "..sql.SQLStr(ply:SteamID())..", "..sql.SQLStr(name)..",'NONE',0,0,1)")
  if res == false then
    print("[luctus_gangs] ERROR DURING CREATEGANG SQL 1/2!")
    print(sql.LastError())
    return
  end
  ress = sql.Query("INSERT INTO luctus_gangmember(gangname, steamid, jointime, plyname, rank) VALUES("..sql.SQLStr(name)..", "..sql.SQLStr(ply:SteamID())..", datetime('now', 'localtime'), "..sql.SQLStr(ply:Nick())..", 1)")
  if ress == false then
    print("[luctus_gangs] ERROR DURING CREATEGANG SQL 2/2!")
    print(sql.LastError())
    return
  end
  ply:SetNWInt("gangrank",1)
  ply:SetNWString("gang",name)
  ply:PrintMessage(HUD_PRINTTALK, "Gang successfully created!")
end

function luctusDeleteGang(ply)
  local gangname = ply:GetNWString("gang","")
  if gangname == "" then return end
  local res = sql.Query("DELETE FROM luctus_gangs WHERE name = "..sql.SQLStr(gangname))
  if res == false then
    print("[luctus_gangs] ERROR DURING DELETEGANG SQL 1/2!")
    print(sql.LastError())
    return
  end
  res = sql.Query("DELETE FROM luctus_gangmember WHERE gangname = "..sql.SQLStr(gangname))
  if res == false then
    print("[luctus_gangs] ERROR DURING DELETEGANG SQL 2/2!")
    print(sql.LastError())
    return
  end
  --Delete current members live on server
  for k,v in pairs(player.GetAll()) do
    if v:GetNWString("gang","") == gangname then
      v:SetNWString("gang","")
      v:SetNWInt("gangrank",0)
    end
  end
end

function luctusGetGangInfo(name)
  if name == "" then return {} end
  local res = sql.QueryRow("SELECT * FROM luctus_gangs WHERE name = "..sql.SQLStr(name))
  if res == false or not res then
    print("[luctus_gangs] ERROR DURING GETGANGINFO SQL!")
    print(sql.LastError())
    return
  end
  return res
end

function luctusLeaveGang(ply)
  local res = sql.Query("DELETE FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  if res == false then
    print("[luctus_gangs] ERROR DURING LEAVEGANG SQL!")
    print(sql.LastError())
    return
  end
  ply:SetNWString("gang","")
  ply:SetNWInt("gangrank",0)
end

function luctusInviteGang(invitator,steamid)
  local ply = nil
  local gang = invitator:GetNWString("gang","")
  for k,v in pairs(player.GetAll()) do
    if v:SteamID() == steamid then
      ply = v
      break
    end
  end
  if not ply then
    DarkRP.notify(invitator,1,5,"Player not found for inviting!")
    return
  end
  if ply.invitedGang then
    DarkRP.notify(invitator,1,5,"Player already has a pending gang invitation!")
    return
  end
  if ply:GetNWString("gang","") ~= "" then
    DarkRP.notify(invitator,1,5,"Player is already in a gang!")
    return
  end
  ply:PrintMessage(HUD_PRINTTALK, "You have just been invited to join the gang '"..gang.."' !")
  ply:PrintMessage(HUD_PRINTTALK, "To accept write !accept , this invitation expires in 60 seconds!")
  DarkRP.notify(ply,0,5,"You have been invited to a gang! (!accept)")
  ply.invitedGang = gang
  timer.Create("luctus_"..ply:SteamID().."_invite",60,1,function()
    if ply and IsValid(ply) then
      ply.invitedGang = nil
      DarkRP.notify(ply,1,5,"Your gang invitation has expired!")
      ply:PrintMessage(HUD_PRINTTALK, "Your gang invitation has expired!")
    end
  end)
end

function luctusJoinGang(ply,gangname)
  ply:SetNWString("gang",gangname)
  ply:SetNWInt("gangrank",1)
  local res = sql.Query("INSERT INTO luctus_gangmember(gangname, steamid, jointime, plyname, rank) VALUES("..sql.SQLStr(gangname)..", "..sql.SQLStr(ply:SteamID())..", datetime('now', 'localtime'), "..sql.SQLStr(ply:Nick())..", 1)")
  if res == false or not res then
    print("[luctus_gangs] ERROR DURING JOINGANG SQL!")
    print(sql.LastError())
    return
  end
  ply:PrintMessage(HUD_PRINTTALK, "Successfully joined the gang "..gangname.."!")
  DarkRP.notify(ply,0,5,"Successfully joined the gang "..gangname.."!")
end

function luctusKickGang(kicker,steamid)
  local ply = nil
  for k,v in pairs(player.GetAll()) do
    if v:SteamID() == steamid then
      ply = v
      break
    end
  end
  if ply == kicker then
    DarkRP.notify(kicker,1,5,"Can't kick yourself!")
    return
  end
  if ply then
    ply:SetNWString("gang","")
    ply:SetNWInt("gangrank",0)
  end
  local res = sql.Query("REMOVE FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(steamid))
  if res == false or not res then
    print("[luctus_gangs] ERROR DURING KICKGANG SQL!")
    print(sql.LastError())
    return
  end
  DarkRP.notify(kicker,0,5,"Successfully kicked player! Please refresh the list!")
end

function luctusGetGangMembers(ply)
  local gangname = ply:GetNWString("gang","")
  if gangname == "" then return end
  local res = sql.Query("SELECT * FROM luctus_gangmember WHERE gangname = "..sql.SQLStr(gangname))
  if res == false or not res then
    print("[luctus_gangs] ERROR DURING GETMEMBERS SQL!")
    print(sql.LastError())
    return
  end
  net.Start("luctus_gang_members")
    net.WriteTable(res)
  net.Send(ply)
end

--MOTD set / update
net.Receive("luctus_gang_motd",function(len,ply)
  local org = ply:GetNWString("gang","")
  if org == "" then return end
  local newMotd = net.ReadString()
  if string.len(newMotd) > 300 then 
    DarkRP.notify(ply,1,5,"MOTD can't be longer than 300 characters!")
    return
  end
  local res = sql.Query("UPDATE luctus_gangs SET motd = "..sql.SQLStr(newMotd).." WHERE name = "..sql.SQLStr(org))
  if res == false then
    print("[luctus_gangs] ERROR DURING SQL UPDATE MOTD!")
    print(sql.LastError())
  end
end)


hook.Add("Initialize", "luctus_gangs_init", function()
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_gangs (createtime DATETIME, creator TEXT, name TEXT, motd TEXT, money INT, members TEXT, xp INT, level INT)")
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_gangmember (gangname TEXT, steamid TEXT, jointime TEXT, plyname TEXT, rank INT)")
end)


hook.Add("PlayerSay", "luctus_gangs_chat", function(ply,text,team)
  if text == "!creategang" then
    --Ask for the name
    net.Start("luctus_gang_create")
    net.Send(ply)
    return ""
  end
  if text == "!accept" then
    if ply.invitedGang then
      luctusJoinGang(ply,ply.invitedGang)
      ply.invitedGang = nil
      timer.Remove("luctus_"..ply:SteamID().."_invite")
    else
      ply:PrintMessage(HUD_PRINTTALK, "You have no pending gang invites!")
    end
  end
  if text == "!gang" then
    if ply:GetNWInt("gangrank",0) ~= 0 then
      net.Start("luctus_gang_menu")
        net.WriteTable(luctusGetGangInfo(ply:GetNWString("gang","")))
      net.Send(ply)
    else
      DarkRP.notify(ply, 1, 4, "You are not in a gang! Either create one at the NPC or join one!")
    end
    return ""
  end
  --debugging
  if text == "!lg" then
    PrintTable(sql.QueryRow("SELECT rowid,* FROM luctus_gangs"))
  end
  if text == "!lm" then
    PrintTable(sql.QueryRow("SELECT rowid,* FROM luctus_gangmember"))
  end
end)


hook.Add("PlayerInitialSpawn", "luctus_gangs_plyinit", function(ply)
  local res = sql.QueryRow("SELECT * FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  if res == false then
    print("[luctus_gangs] ERROR DURING PLYINIT SQL!")
    print(sql.LastError())
    return
  end
  if res then
    ply:SetNWInt("gangrank",tonumber(res["rank"]))
    ply:SetNWString("gang",res["gangname"])
  else
    ply:SetNWInt("gangrank",0)
    ply:SetNWString("gang","")
  end
end)


print("[lucid_gangs] Loaded SV file!")
