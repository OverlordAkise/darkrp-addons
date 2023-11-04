--Luctus Quests
--Made by OverlordAkise

LuctusQuestsAdd("Unlock Medic", {
    category = "Unlocks",
    description = "Die once to unlock the need to play medic and help others to not meet the same end",
    repeatDelay = 30, --repeatable after x seconds after completion,  0 = never repeatable
    progressNeeded = 1, --How many times does LuctusQuestsProgress need to be incremented before quest completion
    startfunc = function(qply) --sv function to execute when starting quest
        hook.Add("PlayerDeath","quest_medic_"..qply:SteamID(),function(ply)
            if qply == ply then
                LuctusQuestsProgress(ply,1)
            end
        end)
    end,
    endfunc = function(ply) --sv function to execute when ending quest (cancel and complete)
        hook.Remove("PlayerDeath","quest_medic_"..ply:SteamID())
    end,
    completefunc = function(ply) --sv function to execute when quest completed quest
        --Whitelist ply for medic here
        DarkRP.notify(ply,2,5,"Unlocked for medic whitelist!")
    end,
    unlockfunc = function(ply) --shared function which checks if player can start quest, can be left out / nil
        return true
    end,
})


LuctusQuestsAdd("Unlock Mafia", {
    category = "Unlocks",
    description = "Kill 3 people to be able to join the dark side",
    repeatDelay = 0,
    progressNeeded = 3,
    startfunc = function(qply)
        hook.Add("PlayerDeath","quest_mafia_"..qply:SteamID(),function(_,_,ply)
            if qply == ply then
                LuctusQuestsProgress(ply,1)
            end
        end)
    end,
    endfunc = function(ply)
        hook.Remove("PlayerDeath","quest_mafia_"..ply:SteamID())
    end,
    completefunc = function(ply)
        --Whitelist ply for mafia here
        DarkRP.notify(ply,2,5,"Unlocked for mafia whitelist!")
    end,
    unlockfunc = function(ply)
        return ply:Health() > 99
    end,
})

LuctusQuestsAdd("Kill 5 players", {
    category = "Daily",
    description = "Be the cause of death for 5 other players",
    repeatDelay = 86400,
    progressNeeded = 5,
    startfunc = function(qply)
        hook.Add("PlayerDeath","quest_dkill5_"..qply:SteamID(),function(_,_,ply)
            if qply == ply then
                LuctusQuestsProgress(ply,1)
            end
        end)
    end,
    endfunc = function(ply)
        hook.Remove("PlayerDeath","quest_dkill5_"..ply:SteamID())
    end,
    completefunc = function(ply)
        ply:addMoney(500)
    end,
    unlockfunc = function(ply)
        return true
    end,
})


print("[luctus_quests] config loaded")
