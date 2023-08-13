--Luctus Logs
--Made by OverlordAkise

--This file contains support for logging other addons
--Which means not all of this will always be executed


--billys job whitelist / gmodadminsuite jobwhitelist
--helper function for stupid accountID
local function NameForAccID(id)
    if not id then return "<NO_PLY>" end
    local name = id
    local ply = player.GetByAccountID(id)
    if ply and IsValid(ply) then
        name = ply:Nick().."("..ply:SteamID()..")"
    end
    return name
end

--Wait for every addon to have loaded
hook.Add("InitPostEntity","luctus_log_custom",function()

--Luctus AntiBanEvasion
if LUCTUS_ABE_FAMILY_SHARING then
    if SERVER then
        hook.Add("LuctusAntiBanEvasionDetection","luctus_log",function(ply,level,message)
            LuctusLog("BanEvasion",message)
        end,-2)
    else
        LuctusLogAddCategory("BanEvasion")
    end
end

--AreaManager, create areas that players can enter
if AreaManager then
    if SERVER then
        hook.Add("PlayerChangedArea","luctus_log",function(ply, newArea)
            LuctusLog("AreaManager", ply:Nick().."("..ply:SteamID()..") changed area to "..newArea.uniquename)
        end,-2)
    else
        LuctusLogAddCategory("AreaManager")
    end
end

--Awarn3, hooks taken from the discord warning module of awarn3
if AWarn then
    if SERVER then
        hook.Add("AWarnPlayerWarned","luctus_log",function(pl, aID, reason)
            local admin = AWarn:GetPlayerFromID64(aID)
            if not admin then return end
            LuctusLog("awarn3", pl:GetName().."("..pl:SteamID()..") got warned by "..admin:GetName().."("..admin:SteamID()..") for reason: "..reason)
        end,-2)

        hook.Add("AWarnPlayerIDWarned","luctus_log",function(pID, aID, reason)
            local admin = AWarn:GetPlayerFromID64( aID )
            if not admin then return end
            LuctusLog("awarn3", tostring("ID: " .. pID).." got warned by "..admin:GetName().."("..admin:SteamID()..") for reason: "..reason)
        end,-2)
    else
        LuctusLogAddCategory("awarn3")
    end
end

--CH_Mining, for mining gold with a pickaxe
if CH_Mining then
    if SERVER then
        hook.Add("CH_Mining_Hook_MineMinerals","luctus_log",function(ply, mineral, extracted_amount)
            --LuctusLog("chmining", ply:GetName().."("..ply:SteamID()..") mined "..extracted_amount.."x "..mineral)
        end,-2)
        hook.Add("CH_Mining_Hook_SellMinerals","luctus_log",function(ply, amount, mineral, mineral_worth)
            LuctusLog("chmining", ply:GetName().."("..ply:SteamID()..") sold "..amount.."x "..mineral.."("..mineral_worth.."$ each)")
        end,-2)
    else
        LuctusLogAddCategory("chmining")
    end
end


--Military Rank System (MRS), similar to jobranksystem
if MRS and MRS.Config then
    if SERVER then
        hook.Add("MRS.OnPromotion","luctus_log",function(targetPly, adminPly, rankGroup, newRankId, oldRankId, adminRankId, newRankName, oldRankName)
            local rType = "up"
            if newRankId < oldRankId then
                rType = "down"
            end
            LuctusLog("mranks",targetPly:Nick().."("..targetPly:SteamID()..") got ranked "..rType.." to "..newRankName.." by "..adminPly:Nick().."("..adminPly:SteamID()..")")
        end)
    else
        LuctusLogAddCategory("mranks")
    end
end

--gDeathSystem
if MedConfig then
    if SERVER then
        hook.Add("MedicSys_PlayerDeath", "luctus_log_MedicSys_PlayerDeath", function(ply,dmg)
            if not IsValid(ply) then return end
            local pname = ply:IsPlayer() and ply:Name() or "<N/A>"
            local psteamid = ply:IsPlayer() and ply:SteamID() or "<N/A>"
            local aname = "<N/A>"
            local asteamid = "<N/A>"
            local awep = "<N/A>"
            if dmg and dmg:GetAttacker() and IsValid(dmg:GetAttacker()) then
                aname = dmg:GetAttacker():GetClass()
                if dmg:GetAttacker():IsPlayer() then
                    aname = dmg:GetAttacker():Nick()
                    asteamid = dmg:GetAttacker():SteamID()
                    awep = dmg:GetAttacker():GetActiveWeapon():GetClass()
                end
            end
            LuctusLog("gDeathSystem",pname.."("..psteamid..") was killed by "..aname.."("..asteamid..") with "..awep)
            LuctusLog("PlayerDeath",pname.."("..psteamid..") was killed by "..aname.."("..asteamid..") with "..awep.." (gdeath)")
        end,-2)
        hook.Add("MedicSys_Stabilized", "luctus_log_MedicSys_Stabilized", function(medicPly,downPly)
            if not IsValid(medicPly) or not IsValid(downPly) then return end
            LuctusLog("gDeathSystem",downPly:Nick().."("..downPly:SteamID()..") was stabilized by "..medicPly:Nick().."("..medicPly:SteamID()..")")
        end,-2)
        hook.Add("MedicSys_RagdollFinish", "luctus_log_MedicSys_RagdollFinish", function(ply,dmg)
            if not IsValid(ply) then return end
            local pname = ply:IsPlayer() and ply:Name() or "<N/A>"
            local psteamid = ply:IsPlayer() and ply:SteamID() or "<N/A>"
            local aname = "<N/A>"
            local asteamid = "<N/A>"
            local awep = "<N/A>"
            if dmg and dmg:GetAttacker() and IsValid(dmg:GetAttacker()) then
                aname = dmg:GetAttacker():GetClass()
                if dmg:GetAttacker():IsPlayer() then
                    aname = dmg:GetAttacker():Nick()
                    asteamid = dmg:GetAttacker():SteamID()
                    awep = dmg:GetAttacker():GetActiveWeapon():GetClass()
                end
            end
            LuctusLog("gDeathSystem",pname.."("..psteamid..") was finished by "..aname.."("..asteamid..") with "..awep)
        end,-2)
        hook.Add("MedicSys_RevivePlayer", "luctus_log_MedicSys_RevivePlayer", function(medicPly,deadPly)
            if not IsValid(medicPly) or not IsValid(deadPly) then return end
            LuctusLog("gDeathSystem",deadPly:Nick().."("..deadPly:SteamID()..") was revived by "..medicPly:Nick().."("..medicPly:SteamID()..")")
        end,-2)
    else
        LuctusLogAddCategory("gDeathSystem")
    end
end

--TBFY Handcuffs
--This guy has no global vars that show the presence of his addon, so:
if hook.GetTable()["CanPlayerEnterVehicle"] and hook.GetTable()["CanPlayerEnterVehicle"]["Cuffs PreventVehicle"] then
    if SERVER then
        hook.Add("OnHandcuffed", "luctus_log_OnHandcuffed", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuffed "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffBreak", "luctus_log_OnHandcuffBreak", function(handcuffedPly,handcuff,helperPly)
            if not IsValid(handcuffedPly) then return end
            if IsValid(helperPly) then
                LuctusLog("cuffs",handcuffedPly:Nick().."("..handcuffedPly:SteamID()..") unhandcuffed by "..helperPly:Nick().."("..helperPly:SteamID()..")")
            else
                LuctusLog("cuffs",handcuffedPly:Nick().."("..handcuffedPly:SteamID()..") unhandcuffed themselves")
            end
        end,-2)
        hook.Add("OnHandcuffGag", "luctus_log_OnHandcuffGag", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-gagged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnGag", "luctus_log_OnHandcuffUnGag", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-ungagged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffBlindfold", "luctus_log_OnHandcuffBlindfold", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-blindfolded "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnBlindfold", "luctus_log_OnHandcuffUnBlindfold", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-unblindfolded "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffStartDragging", "luctus_log_OnHandcuffStartDragging", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-dragged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffStopDragging", "luctus_log_OnHandcuffStopDragging", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-undragged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffTied", "luctus_log_OnHandcuffTied", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-tied "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnTied", "luctus_log_OnHandcuffUnTied", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            LuctusLog("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-untied "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
    else
        LuctusLogAddCategory("cuffs")
    end
end

--SCP, multiple jobs / things can log here
if CLIENT and string.StartWith(string.lower(engine.ActiveGamemode()),"scp") then
    LuctusLogAddCategory("scp")
end

--GmodAdminSuite adminsits / billys admin sits
--GAS.AdminSits doesnt exist yet on clientside, so we wait with overwrite
if SERVER and GAS and GAS.AdminSits then
    --i have to overwrite functions because there exists no hook for it
    gasasapts = GAS.AdminSits.AddPlayerToSit
    gasasrempfs = GAS.AdminSits.RemovePlayerFromSit
    --gasasretpfs = GAS.AdminSits.ReturnPlayerFromSit
    gasasists = GAS.AdminSits.InviteStaffToSit
    
    function GAS.AdminSits:AddPlayerToSit(ply,Sit)
        LuctusLog("adminsit",ply:Nick().."("..ply:SteamID()..") was added to Sit "..Sit.ID)
        gasasapts(GAS.AdminSits,ply,Sit)
    end
    function GAS.AdminSits:RemovePlayerFromSit(ply, Sit)
        LuctusLog("adminsit",ply:Nick().."("..ply:SteamID()..") was removed from Sit "..Sit.ID)
        gasasrempfs(GAS.AdminSits,ply,Sit)
    end
    --function GAS.AdminSits:ReturnPlayerFromSit(ply, Sit)
        --LuctusLog("adminsit",ply:Nick().."("..ply:SteamID()..") was returned from Sit "..Sit.ID)
        --gasasretpfs(GAS.AdminSits,ply,Sit)
    --end
    function GAS.AdminSits:InviteStaffToSit(ply, Sit, inviter)
        LuctusLog("adminsit",ply:Nick().."("..ply:SteamID()..") was invited to Sit "..Sit.ID.." by "..inviter:Nick().."("..inviter:SteamID()..")")
        gasasists(GAS.AdminSits,ply,Sit,inviter)
    end
    
    hook.Add("GAS.AdminSits.SitCreated","luctus_log",function(Sit)
        LuctusLog("adminsit","Sit "..Sit.ID.." was created")
    end)
    hook.Add("GAS.AdminSits.SitEnded","luctus_log",function(Sit)
        LuctusLog("adminsit","Sit "..Sit.ID.." ended")
    end)
end

if SERVER and GAS and GAS.JobWhitelist then
    hook.Add("bWhitelist:WhitelistEnabled","luctus_log",function(jobid, adminAccountID)
        LuctusLog("bwhitelist",team.GetName(jobid).." whitelist was enabled by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:WhitelistDisabled","luctus_log",function(jobid, adminAccountID)
        LuctusLog("bwhitelist",team.GetName(jobid).." whitelist was disabled by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:BlacklistEnabled","luctus_log",function(jobid, adminAccountID)
        LuctusLog("bwhitelist",team.GetName(jobid).." blacklist was enabled by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:BlacklistDisabled","luctus_log",function(jobid, adminAccountID)
        LuctusLog("bwhitelist",team.GetName(jobid).." blacklist was disabled by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:SteamIDAddedToWhitelist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",NameForAccID(value).." was added to whitelist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:UsergroupAddedToWhitelist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",value.." grp was added to whitelist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:SteamIDAddedToBlacklist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",NameForAccID(value).." was added to blacklist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:UsergroupAddedToBlacklist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",value.." grp was added to blacklist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:SteamIDRemovedFromWhitelist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",NameForAccID(value).." was removed from whitelist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:UsergroupRemovedFromWhitelist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",value.." grp was removed from whitelist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:SteamIDRemovedFromBlacklist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",NameForAccID(value).." was removed from blacklist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
    hook.Add("bWhitelist:UsergroupRemovedFromBlacklist","luctus_log",function(value, jobid, adminAccountID)
        LuctusLog("bwhitelist",value.." grp was removed from blacklist for '"..team.GetName(jobid).."' by "..NameForAccID(adminAccountID))
    end)
end


end,2)

hook.Add("gmodadminsuite:LoadModule:jobwhitelist","luctus_log",function()
    LuctusLogAddCategory("bwhitelist")
end)

hook.Add("gmodadminsuite:LoadModule:adminsits","luctus_log",function()
    LuctusLogAddCategory("adminsit")
end)

print("[luctus_logs] sh loaded")
