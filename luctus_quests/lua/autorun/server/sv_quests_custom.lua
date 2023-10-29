--Luctus Dailyquests
--Made by OverlordAkise

--I highly recommend to leave it at 3
LUCTUS_DAILYQUESTS_AMOUNT = 3

--What happens if you finish a quest
hook.Add("LuctusDailyquestsFinished","default",function(ply,name)
    ply:addXP(5)
end)

--Quests

LuctusQuestsAddQuest("Weapon Checker",2,10)
hook.Add("playerWeaponsChecked","luctus_dailyquests",function(ply,tply,weps)
    if LuctusQuestsHasActive(ply,"Weapon Checker") then
        LuctusQuestsProgress(ply,"Weapon Checker")
    end
end)

LuctusQuestsAddQuest("Fistfighter",10,30)
hook.Add("PlayerShouldTakeDamage","luctus_dailyquests",function(ply, attacker)
    if attacker:IsPlayer() and LuctusQuestsHasActive(attacker,"Fistfighter") and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_fists" then
        LuctusQuestsProgress(attacker,"Fistfighter")
    end
end)

LuctusQuestsAddQuest("Killer",2,10)
hook.Add("PostEntityTakeDamage","luctus_dailyquests",function(ent,dmg,took)
    local ply = dmg:GetAttacker()
    if not ply:IsPlayer() or not LuctusQuestsHasActive(ply,"Killer") or not took
        or ent:Health() > 0 then return end
    LuctusQuestsProgress(ply,"Killer")
end)

LuctusQuestsAddQuest("Salaryman",5,15)
hook.Add("playerGetSalary","luctus_dailyquests",function(ply,amount)
    if LuctusQuestsHasActive(ply,"Salaryman") then
        LuctusQuestsProgress(ply,"Salaryman")
    end
end)

--Uncomment these if you need them

--[[
LuctusQuestsAddQuest("Looter",5,15)
hook.Add("luctus_lootsystem_dropped","luctus_dailyquests",function(ent,ply,loot)
    if LuctusQuestsHasActive(ply,"Looter") then
        LuctusQuestsProgress(ply,"Looter")
    end
end)

LuctusQuestsAddQuest("Crafter",1,4)
hook.Add("LuctusMinerCrafted","luctus_dailyquests",function(ply,stringItem)
    if LuctusQuestsHasActive(ply,"Crafter") then
        LuctusQuestsProgress(ply,"Crafter")
    end
end)

LuctusQuestsAddQuest("Oreseller",10,30)
hook.Add("LuctusMinerSold","luctus_dailyquests",function(ply,ore,amount)
    if LuctusQuestsHasActive(ply,"Oreseller") then
        LuctusQuestsProgress(ply,"Oreseller",amount)
    end
end)

LuctusQuestsAddQuest("Repairer",2,10)
hook.Add("LuctusTechnicianRepaired","luctus_dailyquests",function(ply,ent)
    if LuctusQuestsHasActive(ply,"Repairer") then
        LuctusQuestsProgress(ply,"Repairer")
    end
end)

LuctusQuestsAddQuest("Cleaner",10,20)
hook.Add("LuctusCleanDone","luctus_dailyquests",function(ply,ent)
    if LuctusQuestsHasActive(ply,"Cleaner") then
        LuctusQuestsProgress(ply,"Cleaner")
    end
end)
--]]

print("[luctus_dailyquests] sv custom loaded")
