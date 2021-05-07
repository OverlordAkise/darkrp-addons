util.AddNetworkString("lucid_log")

hook.Add("PostGamemodeLoaded","lucid_log",function()
  sql.Query("CREATE TABLE IF NOT EXISTS lucid_log( date DATETIME, msg TEXT )")
end)


lucid_log = {}

local function log_push(text)
  print("[LucidLog] "..sql.SQLStr(text))
  sql.Query("INSERT INTO lucid_log( date , msg ) VALUES( datetime('now') , "..SQLStr(text)..") ")
  local datetime = sql.Query("SELECT datetime()")[1]["datetime()"]
  local value = {}
  value.date = datetime
  value.msg = text
  table.insert(lucid_log,value)
  if #lucid_log > 20 then
    table.remove(lucid_log,1)
  end
end

--page=0 is the beginning? have to test
local function log_get(_filter,_page,_date_a,_date_z)
  local page = tonumber(_page)
  if not page then return nil end
  local filter = _filter
  if filter != "" then
    if string.find( filter, '[\'\\/:%*%?"<>|=]' ) ~= nil then
      return nil
    end
  end
  page = page * 20
  local ret = {}
  if _date_z != "" then
    ret = sql.Query("SELECT * FROM lucid_log WHERE msg LIKE "..sql.SQLStr(filter).." AND datetime(date) > datetime("..sql.SQLStr(_date_a)..") AND datetime(date) < datetime("..sql.SQLStr(_date_z)..") ORDER BY date DESC limit 20 offset "..page..";")
    
    if(ret==false)then
      print("[lucidlog] SQL ERROR DURING DATE FILTER!")
    end
  else
    ret = sql.Query("SELECT * FROM lucid_log WHERE msg LIKE "..sql.SQLStr(filter).." ORDER BY date DESC limit 20 offset "..page)
  end
  return ret
end
--TODO:
    --CHECK log_get FUNCTION FOR SQL INJECTION
    --Reverse Table for Client display top to bottom
    --On Client redo date to look better
    --MAKE UI
    --Make SQL Date field an BIGINT
    
    
    --SAVE TO SQL
    
--[[





PrintTable( sql.Query("SELECT * FROM my_db_table ") )


--]]
--[[
--Too much spam
hook.Add("PlayerSwitchWeapon","lucid_log_psw",function(ply, oldWeapon, newWeapon )
    if not IsValid(ply) or not IsValid(oldWeapon) or not IsValid(newWeapon) then return end
    log_push(ply:Nick().." switched from "..oldWeapon:GetClass().." to "..newWeapon:GetClass())
end)
--]]

hook.Add("playerAdverted","lucid_log_playerAdverted",function(ply, arguments, entity)
    if not IsValid(ply) then return end 
    log_push(ply:Nick().." created a lawboard with text: "..arguments)
end)
hook.Add("playerArrested","lucid_log_playerArrested",function(criminal, time, actor)
    if not IsValid(criminal) or not IsValid(actor) then return end 
    log_push(actor:Nick().." arrested "..criminal:Nick().." for "..time.."s")
end)
hook.Add("playerUnArrested","lucid_log_playerUnArrested",function(criminal, actor)
    if not IsValid(criminal) or not IsValid(actor) then return end
    log_push(actor:Nick().." unarrested "..criminal:Nick())
end)
hook.Add("onDoorRamUsed","lucid_log_onDoorRamUsed",function(successBool, ply, traceTable)
    if not IsValid(successBool) or not IsValid(ply) then return end
    if successBool and IsValid(traceTable.Entity:GetDoorOwner()) then
        log_push(ply:Nick().." used a DoorRam on "..traceTable.Entity:GetDoorOwner():Nick().."'s door")
    else
        log_push(ply:Nick().." used a DoorRam on an unknown door")
    end
end)
hook.Add("playerDroppedCheque","lucid_log_playerDroppedCheque",function(plySender, plyReceiver, amount, ent)
    if not IsValid(plySender) or not IsValid(plyReceiver) then return end
    log_push(plySender:Nick().." created a "..amount.."$ cheque for "..plyReceiver:Nick())
end)
hook.Add("playerPickedUpCheque","lucid_log_playerPickedUpCheque",function(plyPickup, plyReceiver, amount, successBool, ent)
    if not IsValid(plyPickup) or not IsValid(plyReceiver) then return end
    if successBool then
        log_push(plyPickup:Nick().." picked up a "..amount.."$ cheque. (Created for "..plyReceiver:Nick()..")")
    end
end)
hook.Add("playerToreUpCheque","lucid_log_playerToreUpCheque",function(plyTore, plyReceiver, amount, ent)
    if not IsValid(plyTore) or not IsValid(plyReceiver) then return end
    log_push(plyTore:Nick().." tore up a "..amount.."$ cheque. (Created for "..plyReceiver:Nick()..")")
end)
hook.Add("playerBoughtDoor","lucid_log_playerBoughtDoor",function(ply, ent, cost)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." bought a door for "..cost)
end)
hook.Add("playerPickedUpMoney","lucid_log_playerPickedUpMoney",function(ply, amount, entity)
    if not IsValid(ply) or not IsValid(entity) then return end
    log_push(ply:Nick().." picked up "..amount.." money")
end)
hook.Add("playerGaveMoney","lucid_log_playerGaveMoney",function(ply, plyReceiver, amount)
    if not IsValid(ply) or not IsValid(plyReceiver) then return end
    log_push(ply:Nick().." gave "..plyReceiver:Nick().." "..amount.."$")
end)
hook.Add("playerDroppedMoney","lucid_log_playerDroppedMoney",function(ply, amount, entity)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." dropped "..amount.."$")
end)
hook.Add("playerSetAFK","lucid_log_playerSetAFK",function(ply, nowAfkBool)
    if not IsValid(ply) then return end
    if nowAfkBool then
        log_push(ply:Nick().." is now AFK")
    else
        log_push(ply:Nick().." is back from AFK")
    end
end)
hook.Add("playerWeaponsChecked","lucid_log_playerWeaponsChecked",function(checker, target, weapons)
    if not IsValid(checker) or not IsValid(target) or not IsValid(weapons) then return end
    log_push(checker:Nick().." checked "..target:Nick().."'s weapons")
    --weapons = table
    --TODO
end)
hook.Add("playerWeaponsConfiscated","lucid_log_playerWeaponsConfiscated",function(checker, target, weapons)
    if not IsValid(checker) or not IsValid(target) or not IsValid(weapons) then return end
    log_push(checker:Nick().." confiscated "..target:Nick().."'s weapons")
    --weapons = table
    --TODO
end)
hook.Add("lockdownEnded","lucid_log_lockdownEnded",function(ply)
    if not IsValid(ply) then return end
    --ply can be world entity, so stupid fix:
    if ply:IsPlayer() then
        log_push(ply:Nick().." has ended the lockdown")
    else
        log_push("Lockdown was ended by server")
    end
end)
hook.Add("lockdownStarted","lucid_log_lockdownStarted",function(ply)
    if not IsValid(ply) then return end
    --ply can be world entity, so stupid fix:
    if ply:IsPlayer() then
        log_push(ply:Nick().." has started a lockdown")
    else
        log_push("Lockdown was started by server")
    end
end)
hook.Add("onHitFailed","lucid_log_onHitFailed",function(hitman, target, reason)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push(hitman:Nick().." failed hit on "..target:Nick().." (reason: "..reason..")")
end)
hook.Add("onHitCompleted","lucid_log_onHitCompleted",function(hitman, target, customer)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push(hitman:Nick().." completed hit on "..target:Nick().." (customer: "..customer:Nick()..")")
end)
hook.Add("onHitAccepted","lucid_log_onHitAccepted",function(hitman, target, customer)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push(hitman:Nick().." accepted hit on "..target:Nick().." (customer: "..customer:Nick()..")")
end)
hook.Add("onFoodItemRemoved","lucid_log_onFoodItemRemoved",function(num, itemTable)
    --TODO
end)
hook.Add("onEntityRemoved","lucid_log_onEntityRemoved",function(num, itemTable)
    --TODO
end)
hook.Add("OnPlayerChangedTeam","lucid_log_OnPlayerChangedTeam",function(ply, before, after)
    if not IsValid(ply) then return end
    --ply,num,num
    log_push(ply:Nick().." changed job from "..team.GetName(before).." to "..team.GetName(after))
end)
--[[
--Not enough information, only what entity was locked
hook.Add("onKeysLocked","lucid_log_onKeysLocked",function(ent)
    if not IsValid(ent) then return end
end)
hook.Add("onKeysUnlocked","lucid_log_onKeysUnlocked",function(ent)
    if not IsValid(ent) then return end
end)--]]
hook.Add("onLockpickCompleted","lucid_log_onLockpickCompleted",function(ply, success, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    --Stupid inconsistent hook information
    if success then
        if ent:IsVehicle() then
            if IsValid(ent:getDoorOwner()) then
                log_push(ply:Nick().." lockpicked the vehicle of "..ent:getDoorOwner():Nick())
            else
                log_push(ply:Nick().." lockpicked the vehicle of unknown")
            end
        else
            if IsValid(ent:getDoorOwner()) then
                log_push(ply:Nick().." lockpicked the door of "..ent:getDoorOwner():Nick())
            else
                log_push(ply:Nick().." lockpicked the door of unknown")
            end
        end
    end
end)
hook.Add("lockpickStarted","lucid_log_lockpickStarted",function(ply, ent, trace)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." started to lockpick")
    --TODO
end)
hook.Add("onPocketItemAdded","lucid_log_onPocketItemAdded",function(ply, ent, serializedTable)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." put "..ent:GetClass().." into his pocket")
end)
hook.Add("onPocketItemDropped","lucid_log_onPocketItemDropped",function(ply, ent, item, id)
    if not IsValid(ply) or not IsValid(ent) then return end
    --item=number,id=number
    log_push(ply:Nick().." dropped "..ent:GetClass().." out of his pocket")
end)
--[[
--Gets called by onPocketItemDropped, but with less details so fuck it
hook.Add("onPocketItemRemoved","lucid_log_onPocketItemRemoved",function(Player ply, number item)
    if not IsValid(ply) or not IsValid(ent) then return end
end)--]]
hook.Add("onPlayerDemoted","lucid_log_onPlayerDemoted",function(ply, target, reason)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." demoted "..target:Nick().." (reason: "..reason..")")
end)
hook.Add("onPlayerChangedName","lucid_log_onPlayerChangedName",function(ply, oldName, newName)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." changed name from "..oldName.." to "..newName.."")
end)
hook.Add("playerWanted","lucid_log_playerWanted",function(criminal, wanter, reason)
    if not IsValid(criminal) or not IsValid(wanter) then return end
    log_push(wanter:Nick().." wanted "..criminal:Nick().." (reason: "..reason..")")
end)
hook.Add("playerUnWanted","lucid_log_playerUnWanted",function(excriminal, wanter)
    if not IsValid(excriminal) or not IsValid(wanter) then return end
    log_push(wanter:Nick().. "unwanted "..excriminal:Nick())
end)
hook.Add("playerUnWarranted","lucid_log_playerUnWarranted",function(excriminal, wanter)
    if not IsValid(excriminal) or not IsValid(wanter) then return end
    log_push(wanter:Nick().. "unwarranted "..excriminal:Nick())
end)
hook.Add("playerWarranted","lucid_log_playerWarranted",function(criminal, wanter, reason)
    if not IsValid(criminal) or not IsValid(wanter) then return end
    log_push(wanter:Nick().." warranted "..criminal:Nick().." (reason: "..reason..")")
end)
hook.Add("playerBoughtVehicle","lucid_log_playerBoughtVehicle",function(ply, ent, cost)
    if not IsValid(ply) or not IsValid(ent) then return end
    --cost=number
    log_push(ply:Nick().." bought car "..ent:GetClass().." for "..cost.."$")
end)
hook.Add("playerBoughtCustomVehicle","lucid_log_playerBoughtCustomVehicle",function(ply, vehicleTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." bought car "..ent:GetClass().." for "..price.."$")
end)
hook.Add("playerBoughtAmmo","lucid_log_playerBoughtAmmo",function(ply, ammoTable, wep, price)
    if not IsValid(ply) or not IsValid(wep) then return end
    log_push(ply:Nick().." bought ammo "..ammoTable.name.." for "..price.."$")
end)
hook.Add("playerBoughtShipment","lucid_log_playerBoughtShipment",function(ply, shipmentTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." bought ammo "..shipmentTable.name.." for "..price.."$")
end)
hook.Add("playerBoughtCustomEntity","lucid_log_playerBoughtCustomEntity",function(ply, entityTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push(ply:Nick().." bought entity "..ent:GetClass().." for "..price.."$")
end)
hook.Add("playerBoughtPistol","lucid_log_playerBoughtPistol",function(ply, weaponTable, wep, price)
    if not IsValid(ply) or not IsValid(wep) then return end
    log_push(ply:Nick().." bought pistol "..weaponTable.name.." for "..price.."$")
end)
hook.Add("playerBoughtFood","lucid_log_playerBoughtFood",function(ply, foodTable, spawnedfoodEnt, cost)
    if not IsValid(ply) or not IsValid(spawnedfoodEnt) then return end
    log_push(ply:Nick().." bought food "..spawnedfoodEnt:GetClass().." for "..cost.."$")
end)
hook.Add("playerKeysSold","lucid_log_playerKeysSold",function(ply, ent, GiveMoneyBack)
    if not IsValid(ply) or not IsValid(ent) then return end
    --GiveMoneyBack = number
    if ent:IsVehicle() then
        log_push(ply:Nick().." sold a vehicle for "..GiveMoneyBack.."$")
    else
        log_push(ply:Nick().." sold a door for "..GiveMoneyBack.."$")
    end
end)
hook.Add("onDarkRPWeaponDropped","lucid_log_onDarkRPWeaponDropped",function(ply, spawned_weapon, original_weapon)
    if not IsValid(ply) or not IsValid(spawned_weapon) or not IsValid(original_weapon) then return end
    --spawned_weapon = entity, original_weapon = weapon
    log_push(ply:Nick().." dropped weapon "..original_weapon:GetClass())
end)
hook.Add("PlayerPickupDarkRPWeapon","lucid_log_PlayerPickupDarkRPWeapon",function(ply, spawned_weapon, real_weapon)
    if not IsValid(ply) or not IsValid(spawned_weapon) or not IsValid(real_weapon) then return end
    --spawned_weapon = entity, real_weapon = weapon
    log_push(ply:Nick().." picked up weapon "..real_weapon:GetClass())
end)
hook.Add("onAgendaRemoved","lucid_log_onAgendaRemoved",function(name, itemTable)
    if not IsValid(name) then return end
    --TODO
end)
--[[
--Too general, is done by other hooks too
hook.Add("agendaUpdated","lucid_log_agendaUpdated",function(ply, agendaTable, text)
    if not IsValid(ply) or not IsValid(agendaTable) or not IsValid(text) then return end
    --TODO: Check if onAgendaRemoved calls this hook or vice versa
end)
--]]
hook.Add("resetLaws","lucid_log_resetLaws",function(ply)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." reset the laws")
end)
hook.Add("addLaw","lucid_log_addLaw",function(indexNum, lawString, ply)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." added the law "..lawString)
end)
hook.Add("removeLaw","lucid_log_removeLaw",function(indexNum, lawString, ply)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." removed the law "..lawString)
end)
hook.Add("PlayerSpawnProp","lucid_log_PlayerSpawnProp",function(ply, model)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned prop "..model)
end)
hook.Add("PlayerSpawnNPC","lucid_log_PlayerSpawnNPC",function(ply, npc_typeString, weaponString)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned npc "..npc_typeString)
end)
hook.Add("PlayerSpawnEffect","lucid_log_PlayerSpawnEffect",function(ply, model)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned effect "..model)
end)
--[[Covered by all the other PlayerSpawn things
hook.Add("PlayerSpawnObject","lucid_log_PlayerSpawnObject",function(ply, model, skinNum)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned object "..model)
end)
--]]
hook.Add("PlayerSpawnRagdoll","lucid_log_PlayerSpawnRagdoll",function(ply, model)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned ragdoll "..model)
end)
hook.Add("PlayerSpawnSENT","lucid_log_PlayerSpawnSENT",function(ply, classString)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned SENT "..classString)
end)
hook.Add("PlayerSpawnSWEP","lucid_log_PlayerSpawnSWEP",function(ply, weaponString, swepTable)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned weapon "..weaponString)
end)
hook.Add("PlayerSpawnVehicle","lucid_log_PlayerSpawnVehicle",function(ply, model, name, table)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned vehicle "..model.." (name: "..name..")")
end)
hook.Add("PlayerEnteredVehicle","lucid_log_PlayerEnteredVehicle",function(ply, vehicle, roleNum)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." entered vehicle "..vehicle:GetClass().."")
end)
hook.Add("PlayerLeaveVehicle","lucid_log_PlayerLeaveVehicle",function(ply, vehicle)
    if not IsValid(ply) or not IsValid(vehicle) then return end
    log_push(ply:Nick().." left vehicle "..vehicle:GetClass())
end)
hook.Add("CanTool","lucid_log_CanTool",function(ply, traceTable, toolName )
    if not IsValid(ply) then return end
    log_push(ply:Nick().." used toolgun "..toolName.." on entity "..traceTable.Entity:GetClass())
end)

hook.Add("PlayerSpawn","lucid_log_PlayerSpawn",function(ply, transition)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned")
end)
hook.Add("PlayerSay","lucid_log_PlayerSpawn",function(ply, text, team)
  if not IsValid(ply) then return end
  log_push(ply:Nick().." said "..text..""..(team and " in Teamchat" or ""))
end)
hook.Add("PlayerInitialSpawn","lucid_log_PlayerInitialSpawn",function(ply, transition)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned (initial, steamid: "..ply:SteamID()..")")
end)
hook.Add("PlayerDeath", "lucid_log_PlayerDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) or not IsValid(inflictor) or not IsValid(attacker) then return end
    if ( victim == attacker ) then
      log_push(victim:Nick().." committed suicide")
    else
      if(attacker.Nick)then
        log_push(victim:Nick().." was killed by " .. attacker:Nick())
      else
        log_push(victim:Nick().." was killed by " .. attacker:GetClass())
      end
    end
end)
hook.Add("PlayerSilentDeath", "lucid_log_PlayerDeath", function(ply)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." died silently")
end)
hook.Add("PlayerConnect", "lucid_log_PlayerDisconnected", function(name, ip)
    log_push(name.." is joining the server (ip: "..ip..")")
end)
hook.Add("PlayerDisconnected", "lucid_log_PlayerDisconnected", function(ply)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." has left the server (steamid: "..ply:SteamID()..")")
end)
hook.Add("EntityTakeDamage","lucid_log_EntityTakeDamage",function(target, dmg)
    if not IsValid(target) then return end
    if not dmg:GetAttacker():IsPlayer() then return end
    local name = target:GetClass()
    if target:IsPlayer() then
      name = target:Nick()
    end
    log_push(dmg:GetAttacker():Nick().." damaged "..name.." for "..math.Round(dmg:GetDamage(),2).." with "..dmg:GetAttacker():GetActiveWeapon():GetClass())
end)



local ulx_noLogCommands = {
  --["ulx noclip"] = true,
  --["ulx luarun"] = true,
  --["ulx rcon"] = true,
  ["ulx menu"] = true,
  ["ulx votebanMinvotes"] = true,
  ["ulx votebanSuccessratio"] = true,
  ["ulx votekickMinvotes"] = true,
  ["ulx votekickSuccessratio"] = true,
  ["ulx votemap2Minvotes"] = true,
  ["ulx votemap2Successratio"] = true,
  ["ulx voteEcho"] = true,
  ["ulx votemapMapmode"] = true,
  ["ulx votemapVetotime"] = true,
  ["ulx votemapMinvotes"] = true,
  ["ulx votemapWaittime"] = true,
  ["ulx votemapMintime"] = true,
  ["ulx votemapEnabled"] = true,
  ["ulx rslotsVisible"] = true,
  ["ulx rslots"] = true,
  ["ulx rslotsMode"] = true,
  ["ulx logEchoColorMisc"] = true,
  ["ulx logEchoColorPlayer"] = true,
  ["ulx logEchoColorPlayerAsGroup"] = true,
  ["ulx logEchoColorEveryone"] = true,
  ["ulx logEchoColorSelf"] = true,
  ["ulx logEchoColorConsole"] = true,
  ["ulx logEchoColorDefault"] = true,
  ["ulx logEchoColors"] = true,
  ["ulx logEcho"] = true,
  ["ulx logDir"] = true,
  ["ulx logJoinLeaveEcho"] = true,
  ["ulx logSpawnsEcho"] = true,
  ["ulx votemapSuccessratio"] = true,
  ["ulx logSpawns"] = true,
  ["ulx logChat"] = true,
  ["ulx logEvents"] = true,
  ["ulx logFile"] = true,
  ["ulx welcomemessage"] = true,
  ["ulx meChatEnabled"] = true,
  ["ulx chattime"] = true,
  ["ulx motdurl"] = true,
  ["ulx motdfile"] = true,
  ["ulx showMotd"] = true,
}

if ulx then
  hook.Add(ULib.HOOK_COMMAND_CALLED or "ULibCommandCalled", "lucid_log", function(_ply,cmd,_args)
    if (not _args) then return end
    if ((#_args > 0 and ulx_noLogCommands[cmd .. " " .. _args[1]]) or ulx_noLogCommands[cmd]) then return end
    local ply = ""
    if (not IsValid(_ply)) then
      ply = "console"
        else
            ply = _ply:Nick()
        end
    local argss = ""
    if (#_args > 0) then
      argss = " " .. table.concat(_args, " ")
        end
        log_push(ply.." used ulx command "..cmd..argss)
  end)
end


hook.Add("PlayerSay","lucid_log_display",function(ply,text,team)
    if text == "!llogs" and ply:IsAdmin() then
        net.Start("lucid_log")
        local t = util.TableToJSON(table.Reverse(lucid_log))
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
        net.Send(ply)
    end
end)

net.Receive("lucid_log",function(len,ply)
  if not ply:IsAdmin() then return end
  local aa = net.ReadString()
  local bb = net.ReadString()
  local ta = net.ReadString()
  local tz = net.ReadString()
  local logs = log_get(aa,bb,ta,tz)
  if not logs then logs = {} end
  net.Start("lucid_log")
  local t = util.TableToJSON(logs)
  local a = util.Compress(t)
  --print("Size: "..#a)
  net.WriteInt(#a,17)
  net.WriteData(a,#a)
  net.Send(ply)
end)