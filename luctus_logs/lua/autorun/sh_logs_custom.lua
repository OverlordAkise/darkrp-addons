--Luctus Logs
--Made by OverlordAkise

--This file contains support for logging other addons
--Which means not all of this will always be executed


--Wait for every addon to have loaded
hook.Add("InitPostEntity","luctus_log_custom",function()

--AreaManager, create areas that players can enter
if Areamanager then
    if SERVER then
        hook.Add("PlayerChangedArea","luctus_log",function(ply, newArea)
            LuctusLog("AreaManager",newArea.uniquename)
        end,-2)
    else
        hook.Add("LuctusLogAddCategory","AreaManager",function()
            table.insert(lucid_log_quickfilters,"AreaManager")
        end)
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
        hook.Add("LuctusLogAddCategory","AWarn3",function()
            table.insert(lucid_log_quickfilters,"awarn3")
        end)
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
        hook.Add("LuctusLogAddCategory","chmining",function()
            table.insert(lucid_log_quickfilters,"chmining")
        end)
    end
end
if GAS and GAS.AdminSits then
    if SERVER then
        hook.Add("GAS.AdminSits.SitCreated", Sit)
        hook.Add("GAS.AdminSits.SitEnded", Sit)
        --GAS.AdminSits:AddPlayerToSit(ply, Sit) --????
    end
end

--gDeathSystem
if MedConfig then
    if SERVER then
        hook.Add("MedicSys_PlayerDeath", "lucid_log_MedicSys_PlayerDeath", function(ply,dmg)
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
            log_push("gDeathSystem",pname.."("..psteamid..") was killed by "..aname.."("..asteamid..") with "..awep)
            log_push("PlayerDeath",pname.."("..psteamid..") was killed by "..aname.."("..asteamid..") with "..awep.." (gdeath)")
        end,-2)
        hook.Add("MedicSys_Stabilized", "lucid_log_MedicSys_Stabilized", function(medicPly,downPly)
            if not IsValid(medicPly) or not IsValid(downPly) then return end
            log_push("gDeathSystem",downPly:Nick().."("..downPly:SteamID()..") was stabilized by "..medicPly:Nick().."("..medicPly:SteamID()..")")
        end,-2)
        hook.Add("MedicSys_RagdollFinish", "lucid_log_MedicSys_RagdollFinish", function(ply,dmg)
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
            log_push("gDeathSystem",pname.."("..psteamid..") was finished by "..aname.."("..asteamid..") with "..awep)
        end,-2)
        hook.Add("MedicSys_RevivePlayer", "lucid_log_MedicSys_RevivePlayer", function(medicPly,deadPly)
            if not IsValid(medicPly) or not IsValid(deadPly) then return end
            log_push("gDeathSystem",deadPly:Nick().."("..deadPly:SteamID()..") was revived by "..medicPly:Nick().."("..medicPly:SteamID()..")")
        end,-2)
    else
        hook.Add("LuctusLogAddCategory","gDeathSystem",function()
            table.insert(lucid_log_quickfilters,"gDeathSystem")
        end)
    end
end

--TBFY Handcuffs
--This guy has no global vars that show the presence of his addon, so:
if hook.GetTable()["CanPlayerEnterVehicle"] and hook.GetTable()["CanPlayerEnterVehicle"]["Cuffs PreventVehicle"] then
    if SERVER then
        hook.Add("OnHandcuffed", "lucid_log_OnHandcuffed", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuffed "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffBreak", "lucid_log_OnHandcuffBreak", function(handcuffedPly,handcuff,helperPly)
            if not IsValid(handcuffedPly) then return end
            if IsValid(helperPly) then
                log_push("cuffs",handcuffedPly:Nick().."("..handcuffedPly:SteamID()..") unhandcuffed by "..helperPly:Nick().."("..helperPly:SteamID()..")")
            else
                log_push("cuffs",handcuffedPly:Nick().."("..handcuffedPly:SteamID()..") unhandcuffed themselves")
            end
        end,-2)
        hook.Add("OnHandcuffGag", "lucid_log_OnHandcuffGag", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-gagged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnGag", "lucid_log_OnHandcuffUnGag", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-ungagged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffBlindfold", "lucid_log_OnHandcuffBlindfold", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-blindfolded "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnBlindfold", "lucid_log_OnHandcuffUnBlindfold", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-unblindfolded "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffStartDragging", "lucid_log_OnHandcuffStartDragging", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-dragged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffStopDragging", "lucid_log_OnHandcuffStopDragging", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-undragged "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffTied", "lucid_log_OnHandcuffTied", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-tied "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
        hook.Add("OnHandcuffUnTied", "lucid_log_OnHandcuffUnTied", function(ply,targetPly)
            if not IsValid(ply) or not IsValid(targetPly) then return end
            log_push("cuffs",ply:Nick().."("..ply:SteamID()..") handcuff-untied "..targetPly:Nick().."("..targetPly:SteamID()..")")
        end,-2)
    else
        hook.Add("LuctusLogAddCategory","cuffs",function()
            table.insert(lucid_log_quickfilters,"cuffs")
        end)
    end
end

--SCP, multiple jobs / things can log here
if string.StartWith(string.lower(engine.ActiveGamemode()),"scp") then
    table.insert(lucid_log_quickfilters,"scp")
end

print("[luctus_logs] custom addon support loaded")

end)

print("[luctus_logs] sh loaded")
