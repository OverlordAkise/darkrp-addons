--Luctus Logs
--Made by OverlordAkise

--CONFIG START

--Chat command to open logs
LuctusLogChatCommand = "!logs"
--Ranks that are allowed to browse logs
LuctusLogAllowedRanks = {
    ["superadmin"] = true,
    ["owner"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
}
--How many days to keep logs for
LuctusLogRetainLogs = 3
--Should logs be sent to a webserver?
LuctusLogSendLogsToWeb = false
--URL for the web logs
LuctusLogWebUrl = "http://example.com:3100/loki/api/v1/push"
--How many loglines until we send to webserver
LuctusLogWebSendAmount = 100
--Send logs in format for Grafana Loki , tested with loki-2.8.0
LuctusLogLokiFormat = false

--CONFIG END

util.AddNetworkString("luctus_log")

hook.Add("PostGamemodeLoaded","luctus_log",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_log( date DATETIME, cat TEXT, msg TEXT )")
    print("[luctus_logs] Database initialized!")
end)

LUCTUS_MONITOR_SERVER_ID = LUCTUS_MONITOR_SERVER_ID or ""
if LUCTUS_MONITOR_SERVER_ID == "" and file.Exists("data/luctus_monitor.txt","GAME") then
    print("[luctus_logs] Found server ID, loading...")
    LUCTUS_MONITOR_SERVER_ID = file.Read("data/luctus_monitor.txt","GAME")
end
luctus_weblogcache = {}
local function log_push(cat,text)
    print("[luctus_logs] "..sql.SQLStr(text))
    local res = sql.Query("INSERT INTO luctus_log( date, cat, msg ) VALUES( datetime('now') , "..sql.SQLStr(cat).." , "..sql.SQLStr(text)..") ")
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
        return
    end
    
    if not LuctusLogSendLogsToWeb then return end
    
    if LuctusLogLokiFormat then
        table.insert(luctus_weblogcache,{os.time().."000000000", text})
    else
        local value = {}
        value.date = sql.Query("SELECT datetime()")[1]["datetime()"]
        value.msg = text
        value.cat = cat
        table.insert(luctus_weblogcache,value)
    end
    
    if #luctus_weblogcache >= LuctusLogWebSendAmount then
        local data = ""
        if LuctusLogLokiFormat then
            local tab = {["streams"] = {}}
            table.insert(tab["streams"],{["stream"] = {["serverid"] = LUCTUS_MONITOR_SERVER_ID}, ["values"] = luctus_weblogcache})
            data = util.TableToJSON(tab)
        else
            data = util.TableToJSON({logs=luctus_weblogcache,serverid=LUCTUS_MONITOR_SERVER_ID})
        end
        local didsend = HTTP({
            failed = function(failMessage)
                print("[luctus_logs] ERRROR ; FAILED TO POST STATS!")
                print("[luctus_logs]",os.date("%H:%M:%S - %d/%m/%Y",os.time()))
                ErrorNoHaltWithStack(failMessage)
            end,
            success = function(httpcode,body,headers)
                print("[luctus_logs] Websync successfull!")
                --print(httpcode)
                --print(body)
                --print(headers)
            end, 
            method = "POST",
            url = LuctusLogWebUrl,
            body = data,
            type = "application/json",
            timeout = 10,
        })
        luctus_weblogcache = {}
    end
end

--public function
function LuctusLog(cat,text)
    log_push(cat,text)
end

local function log_get(_filter,_page,_date_a,_date_z,_cat)
    local page = tonumber(_page)
    if not page then return nil end
    local filter = _filter
    if filter != "" then
        if string.find( filter, '[\'\\/%*%?"<>|=]' ) ~= nil then
            return nil
        end
    end
    local cat = ""
    if _cat != "" then
        if string.find( _cat, '[\'\\%*%?"<>|=]' ) ~= nil then
            return nil
        end
        cat = " AND cat = "..sql.SQLStr(_cat)
    end
    page = page * 24
    local ret = {}
    if _date_z != "" then
        ret = sql.Query("SELECT * FROM luctus_log WHERE msg LIKE "..sql.SQLStr("%"..filter.."%")..cat.." AND datetime(date) > datetime("..sql.SQLStr(_date_a)..") AND datetime(date) < datetime("..sql.SQLStr(_date_z)..") ORDER BY rowid DESC limit 24 offset "..page)
    
        if(ret==false)then
            print("[luctus_logs] SQL ERROR DURING DATE FILTER!")
            ErrorNoHaltWithStack(sql.LastError())
            return nil
        end
    else
        ret = sql.Query("SELECT * FROM luctus_log WHERE msg LIKE "..sql.SQLStr("%"..filter.."%")..cat.." ORDER BY rowid DESC limit 24 offset "..page)
    end
    return ret
end


----------------------------
-- Logging Hooks - DarkRP --
----------------------------

--[[
--Too much spam
hook.Add("PlayerSwitchWeapon","luctus_log_psw",function(ply, oldWeapon, newWeapon )
    if not IsValid(ply) or not IsValid(oldWeapon) or not IsValid(newWeapon) then return end
    log_push(ply:Nick().." switched from "..oldWeapon:GetClass().." to "..newWeapon:GetClass())
end)
--]]

hook.Add("playerAdverted","luctus_log_playerAdverted",function(ply, arguments, entity)
    if not IsValid(ply) then return end 
    log_push("PlayerSay",ply:Nick().."("..ply:SteamID()..") created a lawboard with text: "..arguments)
end,-2)
hook.Add("playerArrested","luctus_log_playerArrested",function(criminal, time, actor)
    if not IsValid(criminal) or not IsValid(actor) then return end 
    log_push("UnArrests",actor:Nick().."("..actor:SteamID()..") arrested "..criminal:Nick().."("..criminal:SteamID()..") for "..time.."s")
end,-2)
hook.Add("playerUnArrested","luctus_log_playerUnArrested",function(criminal, actor)
    if not IsValid(criminal) or not IsValid(actor) then return end
    log_push("UnArrests",actor:Nick().."("..actor:SteamID()..") unarrested "..criminal:Nick().."("..criminal:SteamID()..")")
end,-2)
hook.Add("onDoorRamUsed","luctus_log_onDoorRamUsed",function(successBool, ply, traceTable)
    if not IsValid(ply) then return end
    if successBool and IsValid(traceTable.Entity) and traceTable.Entity.GetDoorOwner and IsValid(traceTable.Entity:GetDoorOwner()) then
        log_push("DoorRam",ply:Nick().."("..ply:SteamID()..") used a DoorRam on "..traceTable.Entity:GetDoorOwner():Nick().."'s door")
    else
        log_push("DoorRam",ply:Nick().."("..ply:SteamID()..") used a DoorRam on an unknown door")
    end
end,-2)
hook.Add("playerDroppedCheque","luctus_log_playerDroppedCheque",function(plySender, plyReceiver, amount, ent)
    if not IsValid(plySender) or not IsValid(plyReceiver) then return end
    log_push("Cheques",plySender:Nick().."("..plySender:SteamID()..") created a "..amount.."$ cheque for "..plyReceiver:Nick().."("..plyReceiver:SteamID()..")")
end,-2)
hook.Add("playerPickedUpCheque","luctus_log_playerPickedUpCheque",function(plyPickup, plyReceiver, amount, successBool, ent)
    if not IsValid(plyPickup) then return end
    local mText = plyPickup:Nick().."("..plyPickup:SteamID()..") picked up a "..amount.."$ cheque"
    if IsValid(plyReceiver) then
      mText = mText + " written for "..plyReceiver:Nick().."("..plyReceiver:SteamID()..")"
    end
    if successBool then
        log_push("Cheques",mText)
    end
end,-2)
hook.Add("playerWalletChanged","luctus_log_playerwalletchanged",function(ply,amount,wallet)
    if not IsValid(ply) then return end
    log_push("Money",ply:Nick().."("..ply:SteamID()..") gained "..amount.."$ money")
end,-2)
hook.Add("playerToreUpCheque","luctus_log_playerToreUpCheque",function(plyTore, plyReceiver, amount, ent)
    if not IsValid(plyTore) then return end
    log_push("Cheques",plyTore:Nick().."("..plyTore:SteamID()..") tore up a "..amount.."$ cheque.")
end,-2)
hook.Add("playerBoughtDoor","luctus_log_playerBoughtDoor",function(ply, ent, cost)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Doors",ply:Nick().."("..ply:SteamID()..") bought a door for "..cost.."$")
end,-2)
hook.Add("playerPickedUpMoney","luctus_log_playerPickedUpMoney",function(ply, amount, entity)
    if not IsValid(ply) or not IsValid(entity) then return end
    log_push("Money",ply:Nick().."("..ply:SteamID()..") picked up "..amount.."$ money")
end,-2)
hook.Add("playerGaveMoney","luctus_log_playerGaveMoney",function(ply, plyReceiver, amount)
    if not IsValid(ply) or not IsValid(plyReceiver) then return end
    log_push("Money",ply:Nick().."("..ply:SteamID()..") gave "..plyReceiver:Nick().."("..plyReceiver:SteamID()..") "..amount.."$")
end,-2)
hook.Add("playerDroppedMoney","luctus_log_playerDroppedMoney",function(ply, amount, entity)
    if not IsValid(ply) then return end
    log_push("Money",ply:Nick().."("..ply:SteamID()..") dropped "..amount.."$ money")
end,-2)
hook.Add("playerSetAFK","luctus_log_playerSetAFK",function(ply, nowAfkBool)
    if not IsValid(ply) then return end
    if nowAfkBool then
        log_push("AFKs",ply:Nick().."("..ply:SteamID()..") is now AFK")
    else
        log_push("AFKs",ply:Nick().."("..ply:SteamID()..") is back from AFK")
    end
end,-2)
hook.Add("playerWeaponsChecked","luctus_log_playerWeaponsChecked",function(checker, target, weapons)
    if not IsValid(checker) or not IsValid(target) or not IsValid(weapons) then return end
    log_push("WeaponChecker",checker:Nick().."("..checker:SteamID()..") weaponchecked "..target:Nick().."'s("..target:SteamID()..") weapons")
    --weapons = table
    --TODO
end,-2)
hook.Add("playerWeaponsConfiscated","luctus_log_playerWeaponsConfiscated",function(checker, target, weapons)
    if not IsValid(checker) or not IsValid(target) or not IsValid(weapons) then return end
    log_push("WeaponChecker",checker:Nick().."("..checker:SteamID()..") confiscated "..target:Nick().."'s("..target:SteamID()..") weapons")
    --weapons = table
    --TODO
end,-2)
hook.Add("lockdownEnded","luctus_log_lockdownEnded",function(ply)
    if not IsValid(ply) then return end
    --ply can be world entity, so stupid fix:
    if ply:IsPlayer() then
        log_push("Lockdowns",ply:Nick().."("..ply:SteamID()..") has ended the lockdown")
    else
        log_push("Lockdowns","Lockdown was ended by server")
    end
end,-2)
hook.Add("lockdownStarted","luctus_log_lockdownStarted",function(ply)
    if not IsValid(ply) then return end
    --ply can be world entity, so stupid fix:
    if ply:IsPlayer() then
        log_push("Lockdowns",ply:Nick().."("..ply:SteamID()..") has started a lockdown")
    else
        log_push("Lockdowns","Lockdown was started by server")
    end
end,-2)
hook.Add("onHitFailed","luctus_log_onHitFailed",function(hitman, target, reason)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push("Hitman",hitman:Nick().."("..hitman:SteamID()..") failed hit on "..target:Nick().."("..target:SteamID()..") (reason: "..reason..")")
end,-2)
hook.Add("onHitCompleted","luctus_log_onHitCompleted",function(hitman, target, customer)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push("Hitman",hitman:Nick().."("..hitman:SteamID()..") completed hit on "..target:Nick().."("..target:SteamID()..") (customer: "..customer:Nick().."("..customer:SteamID().."))")
end,-2)
hook.Add("onHitAccepted","luctus_log_onHitAccepted",function(hitman, target, customer)
    if not IsValid(hitman) or not IsValid(target) then return end
    log_push("Hitman",hitman:Nick().."("..hitman:SteamID()..") accepted hit on "..target:Nick().."("..target:SteamID()..") (customer: "..customer:Nick().."("..customer:SteamID().."))")
end,-2)
hook.Add("onFoodItemRemoved","luctus_log_onFoodItemRemoved",function(num, itemTable)
    --TODO
end,-2)
hook.Add("onEntityRemoved","luctus_log_onEntityRemoved",function(num, itemTable)
    --TODO
end,-2)
hook.Add("OnPlayerChangedTeam","luctus_log_OnPlayerChangedTeam",function(ply, before, after)
    if not IsValid(ply) then return end
    --ply,num,num
    log_push("ChangeJob",ply:Nick().."("..ply:SteamID()..") changed job from "..team.GetName(before).." to "..team.GetName(after))
end,-2)
--[[
--Not enough information, only what entity was locked
hook.Add("onKeysLocked","luctus_log_onKeysLocked",function(ent)
    if not IsValid(ent) then return end
end)
hook.Add("onKeysUnlocked","luctus_log_onKeysUnlocked",function(ent)
    if not IsValid(ent) then return end
end)--]]
hook.Add("onLockpickCompleted","luctus_log_onLockpickCompleted",function(ply, success, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    --Stupid inconsistent hook information
    if success then
        if ent:IsVehicle() then
            if IsValid(ent:getDoorOwner()) and ent:getDoorOwner():IsPlayer() then
                log_push("Lockpicks",ply:Nick().."("..ply:SteamID()..") lockpicked the vehicle of "..ent:getDoorOwner():Nick().."("..ent:getDoorOwner():SteamID()..")")
            else
                log_push("Lockpicks",ply:Nick().."("..ply:SteamID()..") lockpicked the vehicle of unknown")
            end
        else
            if IsValid(ent:getDoorOwner()) and ent:getDoorOwner():IsPlayer() then
                log_push("Lockpicks",ply:Nick().."("..ply:SteamID()..") lockpicked the door of "..ent:getDoorOwner():Nick().."("..ent:getDoorOwner():SteamID()..")")
            else
                log_push("Lockpicks",ply:Nick().."("..ply:SteamID()..") lockpicked the door of unknown")
            end
        end
    end
end,-2)
hook.Add("lockpickStarted","luctus_log_lockpickStarted",function(ply, ent, trace)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Lockpicks",ply:Nick().."("..ply:SteamID()..") started to lockpick")
    --TODO
end,-2)
hook.Add("onPocketItemAdded","luctus_log_onPocketItemAdded",function(ply, ent, serializedTable)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Pocket",ply:Nick().."("..ply:SteamID()..") put "..ent:GetClass().." into his pocket")
end,-2)
hook.Add("onPocketItemDropped","luctus_log_onPocketItemDropped",function(ply, ent, item, id)
    if not IsValid(ply) or not IsValid(ent) then return end
    --item=number,id=number
    log_push("Pocket",ply:Nick().."("..ply:SteamID()..") dropped "..ent:GetClass().." out of his pocket")
end,-2)
--[[
--Gets called by onPocketItemDropped, but with less details so removed it
hook.Add("onPocketItemRemoved","luctus_log_onPocketItemRemoved",function(Player ply, number item)
    if not IsValid(ply) or not IsValid(ent) then return end
end)--]]
hook.Add("onPlayerDemoted","luctus_log_onPlayerDemoted",function(ply, target, reason)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Demotes",ply:Nick().."("..ply:SteamID()..") demoted "..target:Nick().."("..target:SteamID()..") (reason: "..reason..")")
end,-2)
hook.Add("onPlayerChangedName","luctus_log_onPlayerChangedName",function(ply, oldName, newName)
    if not IsValid(ply) then return end
    log_push("Namechange",ply:Nick().."("..ply:SteamID()..") changed name from "..oldName.." to "..newName.."")
end,-2)
hook.Add("playerWanted","luctus_log_playerWanted",function(criminal, wanter, reason)
    if not IsValid(criminal) or not IsValid(wanter) then return end
    log_push("Warrant/Wants",wanter:Nick().."("..wanter:SteamID()..") wanted "..criminal:Nick().."("..criminal:SteamID()..") (reason: "..reason..")")
end,-2)
hook.Add("playerUnWanted","luctus_log_playerUnWanted",function(excriminal, wanter)
    if not IsValid(excriminal) or not IsValid(wanter) then return end
    log_push("Warrant/Wants",wanter:Nick().."("..wanter:SteamID()..") unwanted "..excriminal:Nick().."("..excriminal:SteamID()..")")
end,-2)
hook.Add("playerUnWarranted","luctus_log_playerUnWarranted",function(excriminal, wanter)
    if not IsValid(excriminal) or not IsValid(wanter) then return end
    log_push("Warrant/Wants",wanter:Nick().."("..wanter:SteamID()..") unwarranted "..excriminal:Nick().."("..excriminal:SteamID()..")")
end,-2)
hook.Add("playerWarranted","luctus_log_playerWarranted",function(criminal, wanter, reason)
    if not IsValid(criminal) or not IsValid(wanter) then return end
    log_push("Warrant/Wants",wanter:Nick().."("..wanter:SteamID()..") warranted "..criminal:Nick().."("..criminal:SteamID()..") (reason: "..reason..")")
end,-2)
hook.Add("playerBoughtVehicle","luctus_log_playerBoughtVehicle",function(ply, ent, cost)
    if not IsValid(ply) or not IsValid(ent) then return end
    --cost=number
    log_push("Vehicles",ply:Nick().."("..ply:SteamID()..") bought car "..ent:GetClass().." for "..cost.."$")
end,-2)
hook.Add("playerBoughtCustomVehicle","luctus_log_playerBoughtCustomVehicle",function(ply, vehicleTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Vehicles",ply:Nick().."("..ply:SteamID()..") bought car "..ent:GetClass().." for "..price.."$")
end,-2)
hook.Add("playerBoughtAmmo","luctus_log_playerBoughtAmmo",function(ply, ammoTable, wep, price)
    if not IsValid(ply) or not IsValid(wep) then return end
    log_push("Bought",ply:Nick().."("..ply:SteamID()..") bought ammo "..ammoTable.name.." for "..price.."$")
end,-2)
hook.Add("playerBoughtShipment","luctus_log_playerBoughtShipment",function(ply, shipmentTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Bought",ply:Nick().."("..ply:SteamID()..") bought ammo "..shipmentTable.name.." for "..price.."$")
end,-2)
hook.Add("playerBoughtCustomEntity","luctus_log_playerBoughtCustomEntity",function(ply, entityTable, ent, price)
    if not IsValid(ply) or not IsValid(ent) then return end
    log_push("Bought",ply:Nick().."("..ply:SteamID()..") bought entity "..ent:GetClass().." for "..price.."$")
end,-2)
hook.Add("playerBoughtPistol","luctus_log_playerBoughtPistol",function(ply, weaponTable, wep, price)
    if not IsValid(ply) or not IsValid(wep) then return end
    log_push("Bought",ply:Nick().."("..ply:SteamID()..") bought pistol "..weaponTable.name.." for "..price.."$")
end,-2)
hook.Add("playerBoughtFood","luctus_log_playerBoughtFood",function(ply, foodTable, spawnedfoodEnt, cost)
    if not IsValid(ply) or not IsValid(spawnedfoodEnt) then return end
    log_push("Bought",ply:Nick().."("..ply:SteamID()..") bought food "..spawnedfoodEnt:GetClass().." for "..cost.."$")
end,-2)
hook.Add("playerKeysSold","luctus_log_playerKeysSold",function(ply, ent, GiveMoneyBack)
    if not IsValid(ply) or not IsValid(ent) then return end
    --GiveMoneyBack = number
    if ent:IsVehicle() then
        log_push("Bought",ply:Nick().."("..ply:SteamID()..") sold a vehicle for "..GiveMoneyBack.."$")
    else
        log_push("Bought",ply:Nick().."("..ply:SteamID()..") sold a door for "..GiveMoneyBack.."$")
    end
end,-2)
hook.Add("onDarkRPWeaponDropped","luctus_log_onDarkRPWeaponDropped",function(ply, spawned_weapon, original_weapon)
    if not IsValid(ply) or not IsValid(spawned_weapon) or not IsValid(original_weapon) then return end
    --spawned_weapon = entity, original_weapon = weapon
    log_push("Weapons",ply:Nick().."("..ply:SteamID()..") dropped weapon "..original_weapon:GetClass())
end,-2)
hook.Add("PlayerPickupDarkRPWeapon","luctus_log_PlayerPickupDarkRPWeapon",function(ply, spawned_weapon, real_weapon)
    if not IsValid(ply) or not IsValid(spawned_weapon) or not IsValid(real_weapon) then return end
    --spawned_weapon = entity, real_weapon = weapon
    log_push("Weapons",ply:Nick().."("..ply:SteamID()..") picked up weapon "..real_weapon:GetClass())
end,-2)
hook.Add("onAgendaRemoved","luctus_log_onAgendaRemoved",function(name, itemTable)
    if not IsValid(name) then return end
    --TODO
end,-2)
--[[
--Too general, is done by other hooks too
hook.Add("agendaUpdated","luctus_log_agendaUpdated",function(ply, agendaTable, text)
    if not IsValid(ply) or not IsValid(agendaTable) or not IsValid(text) then return end
    --TODO: Check if onAgendaRemoved calls this hook or vice versa
end)
--]]
hook.Add("resetLaws","luctus_log_resetLaws",function(ply)
    if not IsValid(ply) then return end
    log_push("Laws",ply:Nick().."("..ply:SteamID()..") reset the laws")
end,-2)
hook.Add("addLaw","luctus_log_addLaw",function(indexNum, lawString, ply)
    if not IsValid(ply) then return end
    log_push("Laws",ply:Nick().."("..ply:SteamID()..") added the law "..lawString)
end,-2)
hook.Add("removeLaw","luctus_log_removeLaw",function(indexNum, lawString, ply)
    if not IsValid(ply) then return end
    log_push("Laws",ply:Nick().."("..ply:SteamID()..") removed the law "..lawString)
end,-2)
hook.Add("PlayerSpawnProp","luctus_log_PlayerSpawnProp",function(ply, model)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned prop "..model)
end,-2)
hook.Add("PlayerSpawnNPC","luctus_log_PlayerSpawnNPC",function(ply, npc_typeString, weaponString)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned npc "..npc_typeString)
end,-2)
hook.Add("PlayerSpawnEffect","luctus_log_PlayerSpawnEffect",function(ply, model)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned effect "..model)
end,-2)
hook.Add("WeaponEquip", "luctus_log_PlayerGiveSWEP", function(wep, owner)
    if not IsValid(wep) or not IsValid(owner) then return end
    log_push("Weapons",owner:Nick().."("..owner:SteamID()..") picked up weapon "..wep:GetClass())
end,-2)
--[[Covered by all the other PlayerSpawn things
hook.Add("PlayerSpawnObject","luctus_log_PlayerSpawnObject",function(ply, model, skinNum)
    if not IsValid(ply) then return end
    log_push(ply:Nick().." spawned object "..model)
end)
--]]
hook.Add("PlayerSpawnRagdoll","luctus_log_PlayerSpawnRagdoll",function(ply, model)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned ragdoll "..model)
end,-2)
hook.Add("PlayerSpawnSENT","luctus_log_PlayerSpawnSENT",function(ply, classString)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned SENT "..classString)
end,-2)
hook.Add("PlayerSpawnSWEP","luctus_log_PlayerSpawnSWEP",function(ply, weaponString, swepTable)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned weapon "..weaponString)
end,-2)
hook.Add("PlayerSpawnVehicle","luctus_log_PlayerSpawnVehicle",function(ply, model, name, table)
    if not IsValid(ply) then return end
    log_push("Spawned",ply:Nick().."("..ply:SteamID()..") spawned vehicle "..model.." (name: "..name..")")
end,-2)
hook.Add("PlayerEnteredVehicle","luctus_log_PlayerEnteredVehicle",function(ply, vehicle, roleNum)
    if not IsValid(ply) then return end
    log_push("Vehicles",ply:Nick().."("..ply:SteamID()..") entered vehicle "..vehicle:GetClass().."")
end,-2)
hook.Add("PlayerLeaveVehicle","luctus_log_PlayerLeaveVehicle",function(ply, vehicle)
    if not IsValid(ply) or not IsValid(vehicle) then return end
    log_push("Vehicles",ply:Nick().."("..ply:SteamID()..") left vehicle "..vehicle:GetClass())
end,-2)
hook.Add("CanTool","luctus_log_CanTool",function(ply, traceTable, toolName )
    if not IsValid(ply) then return end
    log_push("Toolgun",ply:Nick().."("..ply:SteamID()..") used toolgun "..toolName.." on entity "..traceTable.Entity:GetClass())
end,-2)

hook.Add("PlayerSpawn","luctus_log_PlayerSpawn",function(ply, transition)
    if not IsValid(ply) then return end
    log_push("PlayerSpawn",ply:Nick().."("..ply:SteamID()..") spawned")
end,-2)
hook.Add("PlayerSay","luctus_log_PlayerSpawn",function(ply, text, team)
    if not IsValid(ply) then return end
    log_push("PlayerSay",ply:Nick().."("..ply:SteamID()..") said "..text..""..(team and " in Teamchat" or ""))
end,-2)
hook.Add("PlayerDeath", "luctus_log_PlayerDeath", function(victim, inflictor, attacker)
    if not IsValid(victim) or not IsValid(inflictor) or not IsValid(attacker) then return end
    local aname = attacker:IsPlayer() and attacker:Name() or attacker:GetClass()
    local asteamID = attacker:IsPlayer() and attacker:SteamID() or "NULL"
    if ( victim == attacker ) then
        log_push("PlayerDeath",victim:Nick().."("..victim:SteamID()..") was killed by him-/herself")
    else
        log_push("PlayerDeath",victim:Nick().."("..victim:SteamID()..") was killed by "..aname.."("..asteamID..") with "..inflictor:GetClass())
    end
end,-2)
hook.Add("PlayerSilentDeath", "luctus_log_PlayerDeath", function(ply)
    if not IsValid(ply) then return end
    log_push("PlayerDeath",ply:Nick().."("..ply:SteamID()..") was killed silently")
end,-2)
hook.Add("PlayerConnect", "luctus_log_PlayerConnected", function(name, ip)
    log_push("PlayerConnect",name.." is connecting (ip: "..ip..")")
end,-2)
hook.Add("PlayerInitialSpawn","luctus_log_PlayerInitialSpawn",function(ply, transition)
    if not IsValid(ply) then return end
    log_push("PlayerSpawn",ply:Nick().."("..ply:SteamID()..") spawned on server (initial, connected, steamid: "..ply:SteamID()..")")
end,-2)
hook.Add("PlayerDisconnected", "luctus_log_PlayerDisconnected", function(ply)
    if not IsValid(ply) then return end
    log_push("PlayerConnect",ply:Nick().."("..ply:SteamID()..") disconnected")
end,-2)
hook.Add("EntityTakeDamage","luctus_log_EntityTakeDamage",function(target, dmg)
    if not IsValid(target) then return end
    if not dmg:GetAttacker():IsPlayer() then return end
    local name = target:GetClass()
    if target:IsPlayer() then
        name = target:Nick().."("..target:SteamID()..")"
    end
    local weapon = "UNKNOWN"
    if IsValid(dmg:GetInflictor()) then
        weapon = dmg:GetInflictor():GetClass()
    end
    if IsValid(dmg:GetAttacker():GetActiveWeapon()) then
        weapon = dmg:GetAttacker():GetActiveWeapon():GetClass()
    end
    log_push("Damage",dmg:GetAttacker():Nick().."("..dmg:GetAttacker():SteamID()..") damaged "..name.." for "..math.Round(dmg:GetDamage(),2).." with "..weapon)
end,-2)


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
    hook.Add(ULib.HOOK_COMMAND_CALLED or "ULibCommandCalled", "luctus_log", function(_ply,cmd,_args)
        if (not _args) then return end
        if ((#_args > 0 and ulx_noLogCommands[cmd .. " " .. _args[1]]) or ulx_noLogCommands[cmd]) then return end
        local ply = ""
        local steamid = ""
        if (not IsValid(_ply)) then
            ply = "console"
            steamid = "console"
        else
            ply = _ply:Nick()
            steamid = _ply:SteamID()
        end
        local argss = ""
        if (#_args > 0) then
            argss = " " .. table.concat(_args, " ")
        end
        log_push("ulx",ply.."("..steamid..") used ulx command '"..cmd..argss.."'")
    end)
end


hook.Add("PlayerSay","luctus_log_display",function(ply,text,team)
    if text == LuctusLogChatCommand and LuctusLogAllowedRanks[ply:GetUserGroup()] then
        local logs = log_get("",0,"","","")
        if not logs then logs = {} end
        net.Start("luctus_log")
        local t = util.TableToJSON(logs)
        local a = util.Compress(t)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
        net.Send(ply)
    end
end)

net.Receive("luctus_log",function(len,ply)
    if not LuctusLogAllowedRanks[ply:GetUserGroup()] then return end
    local aa = net.ReadString()
    local bb = net.ReadString()
    local ta = net.ReadString()
    local tz = net.ReadString()
    local cat = net.ReadString()
    local logs = log_get(aa,bb,ta,tz,cat)
    if not logs then logs = {} end
    net.Start("luctus_log")
    local t = util.TableToJSON(logs)
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
    net.Send(ply)
end)

hook.Add("PlayerInitialSpawn","luctus_log_delete_old",function(ply)
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_log( date DATETIME, cat TEXT, msg TEXT )")
    print("[luctus_logs] Database (backup) initialized!")

    local deleteTable = sql.Query("SELECT rowid FROM luctus_log WHERE datetime(date) < datetime('now','-"..LuctusLogRetainLogs.." days');")
    if deleteTable == false then
        print("[luctus_logs] ERROR DURING OLD LOG DELETION!")
        error(sql.LastError())
    end
    if not deleteTable then return end
    if #deleteTable > 0 then
        print("[luctus_logs] Deleting "..(#deleteTable).." logs that are over "..LuctusLogRetainLogs.." days old!")
        sql.Begin()
        for k,v in pairs(deleteTable) do
            if not tonumber(v.rowid) then continue end
            sql.Query("DELETE FROM luctus_log WHERE rowid = "..v.rowid)
        end
        sql.Commit()
        print("[luctus_logs] Deleted old logs!")
    end
    hook.Remove("PlayerInitialSpawn","luctus_log_delete_old")
end)

--Make it not error on serverside if used in shared:
function LuctusLogAddCategory() end

print("[luctus_logs] Loaded SV file!")
