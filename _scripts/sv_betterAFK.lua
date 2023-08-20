--Luctus Non-abuseable AFK
--Made by OverlordAkise

--This addon forces you to stand still for 5seconds before getting set AFK
--This helps prevent abuse of instant-afk'ing in an RP situation

hook.Add("DarkRPPreLoadModules","luctus_enableAFK",function(GM)
    DarkRP.disabledDefaults["modules"]["afk"] = false
end)

hook.Add("PostGamemodeLoaded","luctus_betterAFK",function()
if DarkRP then

local function AFKDemote(ply)
    local shouldDemote, demoteTeam, suppressMsg, msg = hook.Call("playerAFKDemoted", nil, ply)
    demoteTeam = demoteTeam or GAMEMODE.DefaultTeam

    if ply:Team() ~= demoteTeam and shouldDemote ~= false then
        local rpname = ply:getDarkRPVar("rpname")
        ply:changeTeam(demoteTeam, true)
        if not suppressMsg then DarkRP.notifyAll(0, 5, msg or DarkRP.getPhrase("hes_afk_demoted", rpname)) end
    end
    ply:setSelfDarkRPVar("AFKDemoted", true)
    ply:setDarkRPVar("job", "AFK")
end

local function SetAFK(ply)
    local rpname = ply:getDarkRPVar("rpname")
    ply:setSelfDarkRPVar("AFK", not ply:getDarkRPVar("AFK"))

    SendUserMessage("blackScreen", ply, ply:getDarkRPVar("AFK"))

    if ply:getDarkRPVar("AFK") then
        DarkRP.retrieveSalary(ply, function(amount) ply.OldSalary = amount end)
        ply.OldJob = ply:getDarkRPVar("job")
        ply.lastHealth = ply:Health()
        DarkRP.notifyAll(0, 5, DarkRP.getPhrase("player_now_afk", rpname))

        ply.AFKDemote = math.huge

        ply:KillSilent()
        ply:Lock()
    else
        ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
        DarkRP.notifyAll(1, 5, DarkRP.getPhrase("player_no_longer_afk", rpname))
        DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("salary_restored"))
        ply:Spawn()
        ply:UnLock()

        ply:SetHealth(ply.lastHealth and ply.lastHealth > 0 and ply.lastHealth or 100)
        ply.lastHealth = nil
    end
    ply:setDarkRPVar("job", ply:getDarkRPVar("AFK") and "AFK" or ply:getDarkRPVar("AFKDemoted") and team.GetName(ply:Team()) or ply.OldJob)
    ply:setSelfDarkRPVar("salary", ply:getDarkRPVar("AFK") and 0 or ply.OldSalary or 0)

    hook.Run("playerSetAFK", ply, ply:getDarkRPVar("AFK"))
end

DarkRP.removeChatCommand("afk")
DarkRP.defineChatCommand("afk", function(ply)
    if ply.DarkRPLastAFK and not ply:getDarkRPVar("AFK") and ply.DarkRPLastAFK > CurTime() - GAMEMODE.Config.AFKDelay then
        DarkRP.notify(ply, 0, 5, DarkRP.getPhrase("unable_afk_spam_prevention"))
        return ""
    end

    local canAFK = hook.Run("canGoAFK", ply, not ply:getDarkRPVar("AFK"))

    if canAFK == false then return "" end

    if not ply:getDarkRPVar("AFK") then
        ply:PrintMessage(HUD_PRINTTALK, "[AFK] Please stand still for 5s to be moved AFK!")
        DarkRP.notify(ply,1,5,"[AFK] Please stand still for 5s to be moved AFK!")
        ply.cAFKPos = ply:GetPos()
        timer.Simple(5,function()
            if not IsValid(ply) then return end
            if ply.cAFKPos == ply:GetPos() then
                ply.DarkRPLastAFK = CurTime()
                SetAFK(ply)
            else
                ply:PrintMessage(HUD_PRINTTALK, "[AFK] Error: You moved!")
                DarkRP.notify(ply,1,5,"[AFK] Error: You moved!")
            end
        end)
    else
        ply.DarkRPLastAFK = CurTime()
        SetAFK(ply)
    end

    return ""
end)

hook.Add("PlayerInitialSpawn", "StartAFKOnPlayer", function(ply)
    ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
end)

hook.Add("KeyPress", "DarkRPKeyReleasedCheck",function(ply, key)
    ply.AFKDemote = CurTime() + GAMEMODE.Config.afkdemotetime
    if ply:getDarkRPVar("AFKDemoted") then
        ply:setDarkRPVar("job", team.GetName(ply:Team()))
        timer.Simple(3, function() if IsValid(ply) then ply:setSelfDarkRPVar("AFKDemoted", nil) end end)
    end
end)

timer.Create("DarkRPKeyPressedCheck", 1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if ply.AFKDemote and CurTime() > ply.AFKDemote and not ply:getDarkRPVar("AFK") then
            SetAFK(ply)
            AFKDemote(ply)
            ply.AFKDemote = math.huge
        end
    end
end)

hook.Add("playerCanChangeTeam", "AFKCanChangeTeam", function(ply, t, force)
    if ply:getDarkRPVar("AFK") and (not force or t ~= GAMEMODE.DefaultTeam) then
        local TEAM = RPExtraTeams[t]
        if TEAM then DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("unable", GAMEMODE.Config.chatCommandPrefix .. TEAM.command, DarkRP.getPhrase("afk_mode"))) end
        return false
    end
end)

-- Freeze AFK player's salary
hook.Add("playerGetSalary", "AFKGetSalary", function(ply, amount)
    if ply:getDarkRPVar("AFK") then
        return true, "", 0
    end
end)

-- For when a player's team is changed by force
hook.Add("OnPlayerChangedTeam", "AFKCanChangeTeam", function(ply)
    if not ply:getDarkRPVar("AFK") then return end

    ply.OldSalary = ply:getDarkRPVar("salary")
    ply.OldJob = nil
    ply:setSelfDarkRPVar("salary", 0)
end)

local function unAFKPlayer(ply)
    if ply:getDarkRPVar("AFK") then
        SetAFK(ply)
    end
end

hook.Add("playerArrested", "DarkRP_AFK", unAFKPlayer)
hook.Add("playerUnArrested", "DarkRP_AFK", unAFKPlayer)

end
end)