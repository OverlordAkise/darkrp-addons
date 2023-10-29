--Luctus Dailyquests
--Made by OverlordAkise

--I highly recommend to leave it at 3
LUCTUS_DAILYQUESTS_AMOUNT = 3

--What happens if you finish a quest
hook.Add("LuctusDailyquestsFinished","default",function(ply,name)
    ply:addXP(5)
end)

--Quests

LuctusDailyquestsAddQuest("Weapon Checker",2,10)
hook.Add("playerWeaponsChecked","luctus_dailyquests",function(ply,tply,weps)
    if LuctusDailyquestsHasActive(ply,"Weapon Checker") then
        LuctusDailyquestsProgress(ply,"Weapon Checker")
    end
end)

LuctusDailyquestsAddQuest("Fistfighter",10,30)
hook.Add("PlayerShouldTakeDamage","luctus_dailyquests",function(ply, attacker)
    if attacker:IsPlayer() and LuctusDailyquestsHasActive(attacker,"Fistfighter") and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_fists" then
        LuctusDailyquestsProgress(attacker,"Fistfighter")
    end
end)

LuctusDailyquestsAddQuest("Killer",2,10)
hook.Add("PostEntityTakeDamage","luctus_dailyquests",function(ent,dmg,took)
    local ply = dmg:GetAttacker()
    if not ply:IsPlayer() or not LuctusDailyquestsHasActive(ply,"Killer") or not took
        or ent:Health() > 0 then return end
    LuctusDailyquestsProgress(ply,"Killer")
end)

LuctusDailyquestsAddQuest("Salaryman",5,15)
hook.Add("playerGetSalary","luctus_dailyquests",function(ply,amount)
    if LuctusDailyquestsHasActive(ply,"Salaryman") then
        LuctusDailyquestsProgress(ply,"Salaryman")
    end
end)

--Uncomment these if you need them

--[[
LuctusDailyquestsAddQuest("Looter",5,15)
hook.Add("luctus_lootsystem_dropped","luctus_dailyquests",function(ent,ply,loot)
    if LuctusDailyquestsHasActive(ply,"Looter") then
        LuctusDailyquestsProgress(ply,"Looter")
    end
end)

LuctusDailyquestsAddQuest("Crafter",1,4)
hook.Add("LuctusMinerCrafted","luctus_dailyquests",function(ply,stringItem)
    if LuctusDailyquestsHasActive(ply,"Crafter") then
        LuctusDailyquestsProgress(ply,"Crafter")
    end
end)

LuctusDailyquestsAddQuest("Oreseller",10,30)
hook.Add("LuctusMinerSold","luctus_dailyquests",function(ply,ore,amount)
    if LuctusDailyquestsHasActive(ply,"Oreseller") then
        LuctusDailyquestsProgress(ply,"Oreseller",amount)
    end
end)

LuctusDailyquestsAddQuest("Repairer",2,10)
hook.Add("LuctusTechnicianRepaired","luctus_dailyquests",function(ply,ent)
    if LuctusDailyquestsHasActive(ply,"Repairer") then
        LuctusDailyquestsProgress(ply,"Repairer")
    end
end)

LuctusDailyquestsAddQuest("Cleaner",10,20)
hook.Add("LuctusCleanDone","luctus_dailyquests",function(ply,ent)
    if LuctusDailyquestsHasActive(ply,"Cleaner") then
        LuctusDailyquestsProgress(ply,"Cleaner")
    end
end)
--]]

print("[luctus_dailyquests] sv custom loaded")
