--Luctus Charsystem
--Made by OverlordAkise

util.AddNetworkString("AdminMenuDeleteChar")
util.AddNetworkString("AdminMenuUpdateChar")

net.Receive("AdminMenuUpdateChar", function(len, ply)
  if not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
    DarkRP.notify(ply,0,5, LuctusChar.Config.NoPermissions)
    return
  end
  local steamid = net.ReadString()
  local name = net.ReadString()
  local money = net.ReadString()
  local job = net.ReadString()
  local slot = net.ReadUInt(8)
  
  slot = math.Clamp(slot,1,3)
  money = tonumber(money)
  
  local ChangedPlayer = player.GetBySteamID(steamid)
  if IsValid(ChangedPlayer) and ChangedPlayer.charCurSlot == slot then
    DarkRP.notify(ply,0,5, "Can't update a character that is currently being played!")
    return
  end
  
  local charExists = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(steamid).." AND slot = "..slot)
  if(charExists) then
    local res = sql.Query("UPDATE luctus_char SET job = "..sql.SQLStr(job)..", name = "..sql.SQLStr(name)..", money = "..money.." WHERE steamid = "..sql.SQLStr(steamid).." AND slot = "..slot)
    if res == false then
      error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"Successfully updated character!")
  else
    local res = sql.Query("INSERT INTO luctus_char(steamid,slot,job,name,money) VALUES("..sql.SQLStr(steamid)..", "..slot..", "..sql.SQLStr(job)..", "..sql.SQLStr(name)..", "..sql.SQLStr(money)..")")
    if res == false then
      error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"Successfully inserted new character!")
  end
end)

net.Receive("AdminMenuDeleteChar", function(len,ply)
  if not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
    DarkRP.notify(ply,0,5, LuctusChar.Config.NoPermissions)
    return
  end
  local SlotID = net.ReadUInt(8)
  local steamid = net.ReadString()
  SlotID = math.Clamp(SlotID,1,3)
  local DeletedPlayer = player.GetBySteamID(steamid)
  if(IsValid(DeletedPlayer) and DeletedPlayer.charCurSlot == SlotID) then
    DarkRP.notify(ply,0,5,"Can't delete a character that is currently being played!")
    return
  end
  local res = sql.Query("DELETE FROM luctus_char WHERE steamid = "..sql.SQLStr(steamid).." AND slot = "..SlotID)
  if res == false then
    error(sql.LastError())
  end
  DarkRP.notify(ply,0,5,"Successfully deleted that character!")
end)

