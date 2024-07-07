--Luctus Charsystem
--Made by OverlordAkise

util.AddNetworkString("luctus_char_create")
util.AddNetworkString("luctus_char_play")
util.AddNetworkString("luctus_char_delete")
util.AddNetworkString("luctus_char_msg")
util.AddNetworkString("luctus_char_open")
util.AddNetworkString("ChangeNameOfChar")

--TODO: Create popup window during character creation for errors
--TODO: Add net cooldowns for sql statements

local function LuctusCharDBInit()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_char (steamid varchar(255) NOT NULL, slot INTEGER NOT NULL, name varchar(255) NOT NULL, money INTEGER NOT NULL, job INTEGER NOT NULL, cloneid INTEGER)")
end
hook.Add("DarkRPDBInitialized", "luctus_char_dbinit",LuctusCharDBInit)
hook.Add("InitPostEntity", "luctus_char_dbinit",LuctusCharDBInit)

hook.Add("postLoadCustomDarkRPItems", "luctus_char_disablejobs", function()
    function DarkRP.storeMoney(ply, amount)
        if ply.IsChoosingChar then return end
        if ply:IsBot() then return end
        sql.Query("UPDATE luctus_char SET money = "..amount.." WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..ply.charCurSlot)
    end
end)

hook.Add("PlayerInitialSpawn", "luctus_char_lockuntilchosen", function(ply)
    ply.charCooldown = 0
    timer.Simple(3, function()
        if not IsValid(ply) then return end
        if ply:IsBot() then return end --fix bot freezing and teleporting because of :Lock
        ply:Lock()
        ply.IsChoosingChar = true
        ply.charCurSlot = -1

        net.Start("luctus_char_open")
            net.WriteTable(LuctusCharGetTable(ply))
        net.Send(ply)
    end)
end)

function LuctusCharGetTableSID(sid)
    local sqlCharTable = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(sid))
    local CharTable = {}
    if not sqlCharTable then return CharTable end
    for k,v in pairs(sqlCharTable) do
        if v.name and v.slot then
            CharTable[tonumber(v.slot)] = v
        end
    end
    return CharTable
end

function LuctusCharGetTable(ply)
    local charTable = LuctusCharGetTableSID(ply:SteamID())
    if table.IsEmpty(charTable) then
        return charTable
    end
    if ply.charCurSlot and charTable[ply.charCurSlot] then
        charTable[ply.charCurSlot]["playing"] = true
    end
    return charTable
end

function LuctusGetJobFromCommand(cmd)
    for k,v in pairs(RPExtraTeams) do
        if v["command"] == cmd then
            return k
        end
    end
    return nil
end

function LuctusGetCommandFromJob(team)
    if RPExtraTeams[team] ~= nil then
        return RPExtraTeams[team]["command"]
    end
    return nil
end

--F2 = menu open
hook.Add("ShowTeam", "luctus_char_open", function(ply)
    net.Start("luctus_char_open")
        net.WriteTable(LuctusCharGetTable(ply))
    net.Send(ply)
end)

--If player changes team update his character to that one too
hook.Add("OnPlayerChangedTeam", "luctus_char_updatejob", function(ply, oldjob, newjob)
    if not ply.IsChoosingChar then
        local jobcmd = LuctusGetCommandFromJob(newjob)
        local res = sql.Query("UPDATE luctus_char SET job = "..sql.SQLStr(jobcmd).." WHERE steamid = '"..ply:SteamID().."' and slot = "..ply.charCurSlot)
        if res == false then
            error(sql.LastError())
        end
    end
end)


net.Receive("luctus_char_play", function(len,ply)
    if ply.charCooldown and ply.charCooldown > CurTime() then
        DarkRP.notify(ply,1,5,"You can only change your char every 10 seconds!")
        return
    end
    local Slot = net.ReadUInt(8)
    Slot = math.Clamp(Slot,1,LUCTUS_CHAR_SLOTS)
    local ProfileTable = sql.QueryRow("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." and slot = "..Slot)
    if ProfileTable == false then
        error(sql.LastError())
    end
    if not ProfileTable then return end
    
    --try to un-afk the player if he was too long inside the charselect menu
    local unAFK = hook.GetTable()["playerUnArrested"] and hook.GetTable()["playerUnArrested"]["DarkRP_AFK"]
    if unAFK then
        unAFK(ply)
    end
    
    ply:UnLock()
    if ply.IsChoosingChar then
        ply.IsChoosingChar = nil
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

net.Receive("luctus_char_create", function(len,ply)
    local SlotNumber = net.ReadUInt(8)
    local name = net.ReadString()
    SlotNumber = math.Clamp(SlotNumber,1,LUCTUS_CHAR_SLOTS)

    local CharTable = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..SlotNumber)
    if CharTable then return end
  
    local doesNameExistAlready = sql.Query("SELECT name FROM luctus_char WHERE name = "..sql.SQLStr(name))
    if doesNameExistAlready then
        DarkRP.notify(ply,1,5,"ERROR: That name is already taken!")
        return
    end
    local jobcmd = LuctusGetCommandFromJob(LUCTUS_CHAR_DEFAULT_TEAM)
    local res = sql.Query("INSERT INTO luctus_char (steamid, slot, name, money, job) VALUES ("..sql.SQLStr(ply:SteamID())..", "..SlotNumber..", "..sql.SQLStr(name)..", "..LUCTUS_CHAR_DEFAULT_MONEY..", "..sql.SQLStr(jobcmd)..")")
    if res == false then
        error(sql.LastError())
    end
    DarkRP.notify(ply,0,5,"Character successfully created!")
  
    net.Start("luctus_char_open")
        net.WriteTable(LuctusCharGetTable(ply))
    net.Send(ply)
end)

net.Receive("luctus_char_delete", function(len,ply)
    local DeletedSlot = net.ReadUInt(8)
    DeletedSlot = math.Clamp(DeletedSlot,1,LUCTUS_CHAR_SLOTS)
    
    if DeletedSlot == ply.charCurSlot then
        DarkRP.notify(ply,1,4,"Can't delete a character that you are currently playing!")
        return
    end
  
    local res = sql.Query("DELETE FROM luctus_char WHERE steamid = "..sql.SQLStr(ply:SteamID()).." AND slot = "..DeletedSlot)
    if res == false then
        error(sql.LastError())
    end
    DarkRP.notify(ply,0,4,"Character successfully deleted!")

    net.Start("luctus_char_open")
        net.WriteTable(LuctusCharGetTable(ply))
    net.Send(ply)
end)



function LuctusGetPlayerFromName(name)
    if not name then return end
    for k,v in pairs(player.GetAll()) do
        if string.find(string.lower(v:getDarkRPVar("rpname")), string.lower(name)) then
            return v
        end
    end
    return nil
end



local PLAYER = FindMetaTable("Player")
function PLAYER:ChatAddText(...)
    net.Start("luctus_char_msg")
        net.WriteTable({...})
    net.Send(self)
end


--Admin menu

util.AddNetworkString("luctus_char_adminmenu")
util.AddNetworkString("luctus_char_admin_delete")
util.AddNetworkString("luctus_char_admin_update")

net.Receive("luctus_char_admin_update", function(len, ply)
    if not LUCTUS_CHAR_ADMINS[ply:GetUserGroup()] then
        DarkRP.notify(ply,0,5, "You don't have permission!")
        return
    end
    local steamid = net.ReadString()
    local name = net.ReadString()
    local money = net.ReadString()
    local job = net.ReadString()
    local slot = net.ReadUInt(8)

    slot = math.Clamp(slot,1,LUCTUS_CHAR_SLOTS)
    money = tonumber(money)
  
    local ChangedPlayer = player.GetBySteamID(steamid)
    if IsValid(ChangedPlayer) and ChangedPlayer.charCurSlot == slot then
        DarkRP.notify(ply,0,5, "Can't update a character that is currently being played!")
        return
    end
  
    local charExists = sql.Query("SELECT * FROM luctus_char WHERE steamid = "..sql.SQLStr(steamid).." AND slot = "..slot)
    if charExists then
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

net.Receive("luctus_char_admin_delete", function(len,ply)
    if not LUCTUS_CHAR_ADMINS[ply:GetUserGroup()] then
        DarkRP.notify(ply,0,5, "You don't have permission!")
        return
    end
    local SlotID = net.ReadUInt(8)
    local steamid = net.ReadString()
    SlotID = math.Clamp(SlotID,1,LUCTUS_CHAR_SLOTS)
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


--Invite system

hook.Add("PlayerSay", "luctus_char_invitesys", function(ply, text, teamchat)
    if not LUCTUS_CHAR_INVITE_ENABLED then return end
    
    local args = string.Split(text, " ")
    local cmd = string.lower(args[1])
    
    if cmd == "!jobinvite" or cmd == "!jobkick" then
        if not LUCTUS_CHAR_INVITE_JOBS[ply:Team()] then
            ply:ChatAddText(Color(198, 0, 0), "You can't invite others!")
            return
        end

        local Target = LuctusGetPlayerFromName(text.Split(text,cmd.." ")[2])
        if not Target then
            ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
            return
        end
        
        if cmd == "!jobinvite" then
            Target.InviteTeam = LUCTUS_CHAR_INVITE_JOBS[ply:Team()]
            ply:ChatAddText("You invited "..Target:Nick().."!")
            Target:ChatAddText("You got invited to the job "..team.GetName(ply:Team()).."! Type !jobaccept to accept the invitation!")
            timer.Create("Invitation"..Target:SteamID(), 60, 1, function()
                Target.InviteTeam = nil
                Target:ChatAddText(Color(198, 0, 0), "Invitation expired!")
            end)
        elseif cmd == "!jobkick" then
            if LUCTUS_CHAR_INVITE_JOBS[ply:Team()] ~= Target:Team() then
                ply:ChatAddText(Color(198, 0, 0), "You can't kick your target from a job which you do not reign over!")
                return
            end
            Target:changeTeam(LUCTUS_CHAR_DEFAULT_TEAM,true)
            ply:ChatAddText(Color(198, 0, 0), "You kicked "..Target:Nick().." out!")
            Target:ChatAddText(Color(198, 0, 0), "You got kicked out of your job by "..ply:Nick().."!")
        end
    end
  
    if cmd == "!jobaccept" then
        if ply.InviteTeam then
            ply:changeTeam(ply.InviteTeam,true)
            ply.InviteTeam = nil
            timer.Remove("Invitation"..ply:SteamID())
            ply:ChatAddText("You successfully joined as "..team.GetName(ply:Team()).."!")
        else
            ply:ChatAddText(Color(198, 0, 0), "You don't have a pending invitation!")
        end
    end
end)

print("[luctus_char] sv loaded")
