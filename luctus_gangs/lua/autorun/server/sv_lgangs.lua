--Luctus Gangs
--Made by OverlordAkise

util.AddNetworkString("luctus_gangs")
util.AddNetworkString("luctus_gang_menu")
util.AddNetworkString("luctus_gang_members")
util.AddNetworkString("luctus_gang_mhistory")

local cd = {}
timer.Create("luctus_gangs_cd_cleaner",60,0,function() cd = {} end)

net.Receive("luctus_gangs", function(len,ply)
    if not cd[ply] then cd[ply] = CurTime() end
    if cd[ply] > CurTime() then
        DarkRP.notify(ply,1,5,"[gang] Cooldown, please try again in a second")
        return
    end
    cd[ply] = CurTime()+0.3
    
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
        luctusDepositGangMoney(ply,net.ReadString())
    elseif method == "getmoney" then
        luctusRetrieveGangMoney(ply,net.ReadString())
    elseif method == "getmoneyhistory" then
        luctusGangMoneyHistory(ply)
    elseif method == "motdset" then
        luctusSetMOTD(ply,net.ReadString())
    elseif method == "updatebuffs" then
        --luctusUpdateBuffs(ply,net.ReadUInt(16),net.ReadUInt(16))
    end
end)

function LuctusGangGetTable(name)
    local res = sql.QueryRow("SELECT * FROM luctus_gangs WHERE name = "..sql.SQLStr(name))
    if res == false then
        error(sql.LastError())
    end
    if res == nil then
        return nil
    end
    return res
end

function luctusRetrieveGangMoney(ply,stramount)
    local amount = tonumber(stramount)
    if not amount or amount < 1 then
        DarkRP.notify(ply,1,5,"Please enter a number and more than 1!")
        return
    end
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    local gang = LuctusGangGetTable(gangname)
    local availableMoney = tonumber(gang.money)
    if not availableMoney or availableMoney == 0 then return end
    if amount > availableMoney then amount = availableMoney end
    ply:addMoney(amount)
    res = sql.Query("UPDATE luctus_gangs SET money = "..(availableMoney-amount).." WHERE name = "..sql.SQLStr(gangname))
    if res == false then
        error("[luctus_gangs] ERROR; WARNING: WHILE THIS PERSISTS PLAYERS CAN GET INFINITE MONEY!:")
        error(sql.LastError())
    end
    res = sql.Query("INSERT INTO luctus_gangs_moneyhistory VALUES(datetime('now','localtime'),"..sql.SQLStr(ply:GetNW2String("gang",""))..","..sql.SQLStr(ply:Nick())..","..sql.SQLStr(ply:SteamID())..",-"..amount..")")
    if res == false then
        error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"You retrieved "..amount.."$ from your gang!")
end

function luctusDepositGangMoney(ply,stramount)
    local amount = tonumber(stramount)
    if not amount or amount < 1 then
        DarkRP.notify(ply,1,5,"Please enter a number and more than 1!")
        return
    end
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    if not ply:canAfford(amount) then
        DarkRP.notify(ply,1,5,"You don't have that much money!")
        return
    end
    ply:addMoney(-1 * amount)
    local res = sql.Query("UPDATE luctus_gangs SET money = money + "..amount.." WHERE name = "..sql.SQLStr(gangname))
    if res == false then
        error(sql.LastError())
    end
    res = sql.Query("INSERT INTO luctus_gangs_moneyhistory VALUES(datetime('now','localtime'),"..sql.SQLStr(ply:GetNW2String("gang",""))..","..sql.SQLStr(ply:Nick())..","..sql.SQLStr(ply:SteamID())..","..amount..")")
    if res == false then
        error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"You deposit "..amount.."$ to your gang!")
end

function luctusCreateGang(ply,name)
    local res = sql.Query("INSERT INTO luctus_gangs(createtime,creator,name,motd,money,xp,level) VALUES(datetime('now', 'localtime'), "..sql.SQLStr(ply:SteamID())..", "..sql.SQLStr(name)..",'NONE',0,0,1)")
    if res == false then
        error(sql.LastError())
    end
    ress = sql.Query("INSERT INTO luctus_gangmember(gangname, steamid, jointime, plyname, rank) VALUES("..sql.SQLStr(name)..", "..sql.SQLStr(ply:SteamID())..", datetime('now', 'localtime'), "..sql.SQLStr(ply:Nick())..", 1)")
    if ress == false then
        error(sql.LastError())
    end
    ply:SetNW2Int("gangrank",1)
    ply:SetNW2String("gang",name)
    ply:PrintMessage(HUD_PRINTTALK, "Gang successfully created!")
end

function luctusDeleteGang(ply)
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    local res = sql.Query("DELETE FROM luctus_gangs WHERE name = "..sql.SQLStr(gangname))
    if res == false then
        error(sql.LastError())
    end
    res = sql.Query("DELETE FROM luctus_gangmember WHERE gangname = "..sql.SQLStr(gangname))
    if res == false then
        error(sql.LastError())
    end
    --Delete current members live on server
    for k,v in pairs(player.GetAll()) do
        if v:GetNW2String("gang","") == gangname then
            v:SetNW2String("gang","")
            v:SetNW2Int("gangrank",0)
        end
    end
end

function luctusLeaveGang(ply)
    local res = sql.Query("DELETE FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    ply:SetNW2String("gang","")
    ply:SetNW2Int("gangrank",0)
end

function luctusInviteGang(invitator,steamid)
    local ply = nil
    local gang = invitator:GetNW2String("gang","")
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
    if ply:GetNW2String("gang","") ~= "" then
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
    ply:SetNW2String("gang",gangname)
    ply:SetNW2Int("gangrank",1)
    local res = sql.Query("INSERT INTO luctus_gangmember(gangname, steamid, jointime, plyname, rank) VALUES("..sql.SQLStr(gangname)..", "..sql.SQLStr(ply:SteamID())..", datetime('now', 'localtime'), "..sql.SQLStr(ply:Nick())..", 1)")
    if res == false or not res then
        error(sql.LastError())
    end
    ply:PrintMessage(HUD_PRINTTALK, "Successfully joined the gang "..gangname.."!")
    DarkRP.notify(ply,0,5,"Successfully joined the gang "..gangname.."!")
end

function luctusKickGang(kicker,steamid)
    local ply = nil
    for k,v in ipairs(player.GetAll()) do
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
        ply:SetNW2String("gang","")
        ply:SetNW2Int("gangrank",0)
    end
    local res = sql.Query("REMOVE FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(steamid))
    if res == false or not res then
        error(sql.LastError())
    end
    DarkRP.notify(kicker,0,5,"Successfully kicked player! Please refresh the list!")
end

function luctusGetGangMembers(ply)
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    local res = sql.Query("SELECT * FROM luctus_gangmember WHERE gangname = "..sql.SQLStr(gangname))
    if res == false or not res then
        error(sql.LastError())
    end
    net.Start("luctus_gang_members")
        net.WriteTable(res)
    net.Send(ply)
end

function luctusGangMoneyHistory(ply)
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    local res = sql.Query("SELECT * FROM luctus_gangs_moneyhistory WHERE gang="..sql.SQLStr(gangname).." ORDER BY rowid DESC LIMIT 30")
    if res == false then
        error(sql.LastError())
    end
    if not res then
        DarkRP.notify(ply,1,3,"There are no transactions yet!")
        return
    end
    net.Start("luctus_gang_mhistory")
        net.WriteTable(res)
    net.Send(ply)
end

function luctusSetMOTD(ply,newMotd)
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    if string.len(newMotd) > 300 then 
        DarkRP.notify(ply,1,5,"MOTD can't be longer than 300 characters!")
        return
    end
    local res = sql.Query("UPDATE luctus_gangs SET motd = "..sql.SQLStr(newMotd).." WHERE name = "..sql.SQLStr(gangname))
    if res == false then
        error(sql.LastError())
    end
end

function luctusUpdateBuffs(ply,xp,money)
    if not xp or not money then return end
    if xp > LUCTUS_GANGS_BUFF_MAX_XP then return end
    if money > LUCTUS_GANGS_BUFF_MAX_MONEY then return end
    local gangname = ply:GetNW2String("gang","")
    if gangname == "" then return end
    local gang = LuctusGangGetTable(gangname)
    if not gang then return end
    if (xp+money) > (gang.level/LUCTUS_GANGS_BUFF_LEVELS) then return end
    local res = sql.Query("UPDATE luctus_gangs SET xpbuff = "..xp.." AND moneybuff = "..money.." WHERE name = "..sql.SQLStr(gangname))
    if res == false then
        error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"[gang] Buffs saved successfully")
end

hook.Add("Initialize", "luctus_gangs_init", function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_gangs (createtime DATETIME, creator TEXT, name TEXT, motd TEXT, money INT, members TEXT, xp INT, level INT, xpbuff INT, moneybuff INT)")
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_gangmember (gangname TEXT, steamid TEXT, jointime TEXT, plyname TEXT, rank INT)")
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_gangs_moneyhistory (ts DATETIME, gang TEXT, name TEXT, steamid TEXT, amount INT)")
end)


hook.Add("PlayerSay", "luctus_gangs_chat", function(ply,text,team)
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
        if ply:GetNW2Int("gangrank",0) ~= 0 then
            net.Start("luctus_gang_menu")
                net.WriteTable(LuctusGangGetTable(ply:GetNW2String("gang","")) or {})
            net.Send(ply)
        else
            DarkRP.notify(ply, 1, 4, "You are not in a gang! Either create one with '!creategang' or join one!")
        end
        return ""
    end
end)


hook.Add("PlayerInitialSpawn", "luctus_gangs_plyinit", function(ply)
    local res = sql.QueryRow("SELECT * FROM luctus_gangmember WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if res then
        ply:SetNW2Int("gangrank",tonumber(res["rank"]))
        ply:SetNW2String("gang",res["gangname"])
    else
        ply:SetNW2Int("gangrank",0)
        ply:SetNW2String("gang","")
    end
end)

print("[lucid_gangs] sv loaded")
