--Luctus Logs
--Made by OverlordAkise

--This file contains support for logging other addons
--Which means not all of this will always be executed

util.AddNetworkString("luctus_log_cats")

luctus_log_categories = luctus_log_categories or {}

net.Receive("luctus_log_cats",function(len,ply)
    if ply.luctusLogCats then return end
    ply.luctusLogCats = true
    net.Start("luctus_log_cats")
        net.WriteTable(luctus_log_categories)
    net.Send(ply)
end)


--Make it not error on serverside if used in shared:
function LuctusLogAddCategory(name)
    table.insert(luctus_log_categories,name)
end

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


--SCP, multiple jobs / things can log here
if string.StartWith(string.lower(engine.ActiveGamemode()),"scp") then
    LuctusLogAddCategory("scp")
end

--LuctusAC
if LuctusAC_Punish then
    hook.Add("LuctusAC","luctus_log",function(nick,steamid,length,msg)
        LuctusLog("ac",nick.."("..steamid..") cheated: "..msg)
    end)
    hook.Add("LuctusACNetDetected","luctus_log",function(ply,msg)
        LuctusLog("ac",ply:Nick().."("..ply:SteamID()..") tried to exploit "..msg)
    end)
    LuctusLogAddCategory("ac")
end

--Luctus AntiBanEvasion
if LUCTUS_ABE_FAMILY_SHARING then
    hook.Add("LuctusAntiBanEvasionDetection","luctus_log",function(ply,level,message)
        LuctusLog("BanEvasion",message)
    end,-2)
    LuctusLogAddCategory("BanEvasion")
end

--Luctus Config
if LUCTUS_INGAME_CONFIG then
    hook.Add("LuctusConfigChanged","luctus_log",function(ply,variable,typedValue,message)
        LuctusLog("Config",message)
    end,-2)
    LuctusLogAddCategory("Config")
end

--Luctus Amnestics
if LUCTUS_AMNESTICS_LEVELS then
    hook.Add("LuctusAmnestics","luctus_log",function(sending_ply,target_ply,amnestic_type)
        LuctusLog("scp",string.format("%s(%s) has given amnestic type %s to %s(%s)",sending_ply:Nick(),sending_ply:SteamID(),amnestic_type,target_ply:Nick(),target_ply:SteamID()))
    end,-2)
end

--Luctus SCP096
if LUCTUS_SCP096_IMMUNE_JOBS then
    hook.Add("LuctusSCP096UpdateHunted","luctus_log",function(ply,isHunted)
        if isHunted then
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") is being hunted by SCP096.")
        else
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") is not being hunted by SCP096 anymore.")
        end
    end,-2)
    hook.Add("LuctusSCP096UpdateRage","luctus_log",function(ply,isTriggered)
        if isTriggered then
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") enraged SCP096.")
        else
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") ended rage of SCP096.")
            --LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") died as SCP096, rage ended.")
        end
    end,-2)
    hook.Add("LuctusSCP096Recontain","luctus_log",function(ply,isRecontained)
        if isRecontained then
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") recontained SCP096 with a bag.")
        else
            LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") removed the bag from SCP096.")
        end
    end,-2)
end

--Luctus Popups
if LuctusPopupCreate then
    hook.Add("LuctusPopupCreated","luctus_log",function(ply,text)
        LuctusLog("Tickets",ply:Nick().."("..ply:SteamID()..") created a ticket: "..text)
    end,-2)
    hook.Add("LuctusPopupClaimed","luctus_log",function(ply,admin)
        LuctusLog("Tickets",admin:Nick().."("..admin:SteamID()..") claimed the ticket of "..ply:Nick().."("..ply:SteamID()..")")
    end,-2)
    hook.Add("LuctusPopupClosed","luctus_log",function(ply,admin)
        local extraText = "automatically"
        if not admin or not IsValid(admin) then
            extraText = "by "..ply:Nick().."("..ply:SteamID()..")"
        end
        LuctusLog("Tickets",ply:Nick().."("..ply:SteamID()..") ticket was closed "..extraText)
    end,-2)
    LuctusLogAddCategory("Tickets")
end

--Luctus SCP026DE
if LUCTUS_SCP026DE_INFECTED then
    hook.Add("LuctusSCP026DEAdded","luctus_log",function(ply)
        LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") has been infected by SCP-026-DE")
    end,-2)
    hook.Add("LuctusSCP026DERemoved","luctus_log",function(ply)
        --LuctusLog("scp",ply:Nick().."("..ply:SteamID()..") has been freed from SCP-026-DE")
    end,-2)
    hook.Add("LuctusSCP026DEKilled","luctus_log",function(ply,targetply)
        LuctusLog("scp",targetply:Nick().."("..targetply:SteamID()..") has been killed by SCP-026-DE / "..ply:Nick().."("..ply:SteamID()..")")
    end,-2)
    hook.Add("LuctusSCP026DESpared","luctus_log",function(ply,targetply)
        LuctusLog("scp",targetply:Nick().."("..targetply:SteamID()..") has been spared by SCP-026-DE / "..ply:Nick().."("..ply:SteamID()..")")
    end,-2)
end

--Luctus Code
if LUCTUS_SCP_CODES then
    hook.Add("LuctusCodeChanged","luctus_log",function(ply,code)
        if IsValid(ply) then
            LuctusLog("CodeSystem",ply:Nick().."("..ply:SteamID()..") changed the code to "..code)
        else
            LuctusLog("CodeSystem","Server changed the code to "..code)
        end
    end,-2)
    LuctusLogAddCategory("CodeSystem")
end

--Luctus SNLR
if LUCTUS_NLR_TIME then
    hook.Add("LuctusNLRStart","luctus_log",function(ply,ntime,etime)
        if not IsValid(ply) then return end
        LuctusLog("NLR",ply:Nick().."("..ply:SteamID()..") NLR started ("..ntime.."s), ends at "..os.date("%H:%M:%S %d.%m.%Y" ,os.time()+ntime))
    end,-2)
    hook.Add("LuctusNLREnd","luctus_log",function(ply)
        if not IsValid(ply) then return end
        LuctusLog("NLR",ply:Nick().."("..ply:SteamID()..") NLR ended")
    end,-2)
    LuctusLogAddCategory("NLR")
end

--Luctus Disguise
if LUCTUS_DISGUISE_ALLOWED_JOBS then
    hook.Add("LuctusDisguiseDisguised","luctus_log",function(ply,jobname,model)
        if not IsValid(ply) then return end
        LuctusLog("Disguise",ply:Nick().."("..ply:SteamID()..") disguised to job "..jobname.." ("..model..")")
    end,-2)
    LuctusLogAddCategory("Disguise")
end

--Luctus Weaponcabinet
if LUCTUS_WEAPONCABINET then
    hook.Add("LuctusWeaponCabinetGet","luctus_log",function(ply,wep)
        if not IsValid(ply) then return end
        LuctusLog("Weaponcabinet",ply:Nick().."("..ply:SteamID()..") took out an "..wep)
    end,-2)
    hook.Add("LuctusWeaponCabinetReturn","luctus_log",function(ply,wep)
        if not IsValid(ply) then return end
        LuctusLog("Weaponcabinet",ply:Nick().."("..ply:SteamID()..") returned an "..wep)
    end,-2)
    
    LuctusLogAddCategory("Weaponcabinet")
end

--Luctus SCP Management
if LUCTUS_SCP_MGMT_COMMAND then
    hook.Add("LuctusSGPMGMTEmergencyCall","luctus_log",function(ply,groupName)
        if not IsValid(ply) then return end
        LuctusLog("SCPMGMT",ply:Nick().."("..ply:SteamID()..") called for an "..groupName.."-Emergency.")
    end,-2)
    hook.Add("LuctusSGPMGMTEmergencyStop","luctus_log",function(ply,groupName)
        if not IsValid(ply) then return end
        LuctusLog("SCPMGMT",ply:Nick().."("..ply:SteamID()..") stopped an "..groupName.."-Emergency.")
    end,-2)
    hook.Add("LuctusSGPMGMTDemoteStart","luctus_log",function(adminPly,ply)
        if not IsValid(ply) or not IsValid(adminPly) then return end
        LuctusLog("SCPMGMT",adminPly:Nick().."("..adminPly:SteamID()..") demoted "..ply:Nick().."("..ply:SteamID()..") via MGMT.")
    end,-2)
    hook.Add("LuctusSGPMGMTDemoteStop","luctus_log",function(adminPly,ply)
        if not IsValid(ply) or not IsValid(adminPly) then return end
        LuctusLog("SCPMGMT",adminPly:Nick().."("..adminPly:SteamID()..") stopped the demoted of "..ply:Nick().."("..ply:SteamID()..") via MGMT.")
    end,-2)
    
    LuctusLogAddCategory("SCPMGMT")
end

--Luctus Research, CRUD makes me proud
if LUCTUS_RESEARCH_ALLOWED_JOBS then
    hook.Add("LuctusResearchGetID","luctus_log",function(ply,rid)
        if not IsValid(ply) then return end
        LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") requested paper #"..rid)
    end,-2)
    hook.Add("LuctusResearchCreate","luctus_log",function(ply,summary)
        if not IsValid(ply) then return end
        LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") created paper: "..summary)
    end,-2)
    hook.Add("LuctusResearchEdit","luctus_log",function(ply,rid)
        if not IsValid(ply) then return end
        LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") edited paper #"..rid)
    end,-2)
    hook.Add("LuctusResearchDelete","luctus_log",function(ply,rid)
        if not IsValid(ply) then return end
        LuctusLog("Research",ply:Nick().."("..ply:SteamID()..") deleted paper #"..rid)
    end,-2)
    LuctusLogAddCategory("Research")
end

--Luctus Breach
if LUCTUS_BREACH_DELAY then
    hook.Add("LuctusBreachOpen","luctus_log",function(ply)
        if not IsValid(ply) then return end
        LuctusLog("Breach",ply:Nick().."("..ply:SteamID()..") just breached as "..team.GetName(ply:Team()))
    end,-2)
    hook.Add("LuctusBreachRequested","luctus_log",function(ply)
        if not IsValid(ply) then return end
        LuctusLog("Breach",ply:Nick().."("..ply:SteamID()..") requested to breach as "..team.GetName(ply:Team()))
    end,-2)
    hook.Add("LuctusBreachApproved","luctus_log",function(adminPly,ply)
        if not IsValid(ply) or not IsValid(adminPly) then return end
        LuctusLog("Breach",adminPly:Nick().."("..adminPly:SteamID()..") approved breach request of "..ply:Nick().."("..ply:SteamID()..") as "..team.GetName(ply:Team()))
    end,-2)
    hook.Add("LuctusBreachDenied","luctus_log",function(adminPly,ply)
        if not IsValid(ply) or not IsValid(adminPly) then return end
        LuctusLog("Breach",adminPly:Nick().."("..adminPly:SteamID()..") denied breach request of "..ply:Nick().."("..ply:SteamID()..") as "..team.GetName(ply:Team()))
    end,-2)
    LuctusLogAddCategory("Breach")
end

--Luctus Whitelist
if LUCTUS_WHITELIST_CHATCMD then
    hook.Add("LuctusWhitelistUpdate","luctus_log",function(adminPly,ply,steamid,jtext)
        local name = steamid
        if ply and IsValid(ply) then
            name = ply:Nick().."("..ply:SteamID()..")"
        end
        LuctusLog("Whitelist",adminPly:Nick().."("..adminPly:SteamID()..") changed the whitelist of "..name)
    end,-2)
    LuctusLogAddCategory("Whitelist")
end

--Luctus Warn
if LUCTUS_WARN_BAN_CONFIG then
    hook.Add("LuctusWarnCreate","luctus_log",function(adminPly,ply,steamid,reason,message)
        LuctusLog("Warn",message)
    end,-2)
    hook.Add("LuctusWarnUpdate","luctus_log",function(ply,name,target,shouldRemove)
        if not IsValid(ply) then return end
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has "..(shouldRemove and "removed" or "reactivated").." a warn of "..name.."("..target..")")
    end,-2)
    hook.Add("LuctusWarnDelete","luctus_log",function(ply,targetName,targetID)
        if not IsValid(ply) then return end
        LuctusLog("Warn",ply:Nick().."("..ply:SteamID()..") has deleted a warn of "..targetName.."("..targetID..")")
    end,-2)
    hook.Add("LuctusWarnBanned","luctus_log",function(ply,warncount,minutes)
        if not IsValid(ply) then return end
        LuctusLog("Warn",ply:SteamID().." was banned for "..minutes.." minutes with "..warncount.." warns")
    end,-2)
    hook.Add("LuctusWarnKicked","luctus_log",function(ply,warncount)
        if not IsValid(ply) then return end
        LuctusLog("Warn",ply:SteamID().." was kicked for having "..warncount.." warns")
    end,-2)
    LuctusLogAddCategory("Warn")
end

--Luctus Jobranks
if LUCTUS_JOBRANKS_RANKUP_CMD then
    hook.Add("LuctusJobranksUprank","luctus_log",function(adminPly,ply,newJobName,message)
        LuctusLog("Jobranks",message)
    end,-2)
    hook.Add("LuctusJobranksDownrank","luctus_log",function(adminPly,ply,newJobName,message)
        LuctusLog("Jobranks",message)
    end,-2)
    LuctusLogAddCategory("Jobranks")
end

--Luctus Radio
if LUCTUS_RADIO_EXISTS then
    hook.Add("LuctusRadioFreqChanged","luctus_log",function(ply,newFreq)
        if not IsValid(ply) then return end
        LuctusLog("Radio",ply:Nick().."("..ply:SteamID()..") set his radio freq to "..newFreq)
    end,-2)
    LuctusLogAddCategory("Radio")
end

--Luctus Raidhelper
if LUCTUS_RAIDHELPER_JOBS then
    hook.Add("LuctusRaidHelperAsk","luctus_log",function(ply,jobname,acceptNum)
        LuctusLog("Raids",ply:Nick().."("..ply:SteamID()..") asked to start a raid as "..jobname.." ("..acceptNum..")")
    end,-2)
    hook.Add("LuctusRaidHelperApproved","luctus_log",function(adminPly,raidLeader)
        LuctusLog("Raids",adminPly:Nick().."("..adminPly:SteamID()..") has approved the raid of "..raidLeader:Nick().."("..raidLeader:SteamID()..") as "..team.GetName(raidLeader:Team()))
    end,-2)
    hook.Add("LuctusRaidHelperDenied","luctus_log",function(adminPly,raidLeader)
        LuctusLog("Raids",adminPly:Nick().."("..adminPly:SteamID()..") has denied the raid of "..raidLeader:Nick().."("..raidLeader:SteamID()..") as "..team.GetName(raidLeader:Team()))
    end,-2)
    hook.Add("LuctusRaidHelperStart","luctus_log",function(ply,jobname,members)
        LuctusLog("Raids",ply:Nick().."("..ply:SteamID()..") started a raid as "..jobname.." with "..members.." people")
    end,-2)
    hook.Add("LuctusRaidHelperEnd","luctus_log",function(jobname,reason)
        LuctusLog("Raids","Raid of "..jobname.." ended with reason: "..reason)
    end,-2)
    hook.Add("LuctusRaidHelperLeft","luctus_log",function(ply,jobname,reason)
        LuctusLog("Raids",ply:Nick().."("..ply:SteamID()..") left the raid of "..jobname.." with reason: "..reason)
    end,-2)
    LuctusLogAddCategory("Raids")
end

--Luctus Jobbans
if ulx and ulx.jobban then
    hook.Add("LuctusJobbanBan","luctus_log",function(steamid,jobname,newBanTime,ply)
        local name = steamid
        if IsValid(ply) then
            name = ply:Nick().."("..steamid..")"
        end
        LuctusLog("Jobban",name.." was jobbanned from "..jobname.." until "..os.date("%H:%M:%S - %d.%m.%Y",newBanTime))
    end,-2)
    hook.Add("LuctusJobbanUnban","luctus_log",function(steamid,jobname,ply)
        local name = steamid
        if IsValid(ply) then
            name = ply:Nick().."("..steamid..")"
        end
        LuctusLog("Jobban",name.." was jobunbanned from "..jobname)
    end,-2)
    LuctusLogAddCategory("Jobban")
end

--AreaManager, create areas that players can enter
if AreaManager then
    hook.Add("PlayerChangedArea","luctus_log",function(ply, newArea)
        if not IsValid(ply) then return end
        LuctusLog("AreaManager", ply:Nick().."("..ply:SteamID()..") changed area to "..newArea.uniquename)
    end,-2)
    LuctusLogAddCategory("AreaManager")
end

--Awarn3, hooks taken from the discord warning module of awarn3
if AWarn then
    hook.Add("AWarnPlayerWarned","luctus_log",function(ply, aID, reason)
        if not IsValid(ply) then return end
        local admin = AWarn:GetPlayerFromID64(aID)
        if not admin then return end
        LuctusLog("awarn3", ply:GetName().."("..ply:SteamID()..") got warned by "..admin:GetName().."("..admin:SteamID()..") for reason: "..reason)
    end,-2)

    hook.Add("AWarnPlayerIDWarned","luctus_log",function(pID, aID, reason)
        local admin = AWarn:GetPlayerFromID64( aID )
        if not admin then return end
        LuctusLog("awarn3", tostring("ID: " .. pID).." got warned by "..admin:GetName().."("..admin:SteamID()..") for reason: "..reason)
    end,-2)
    LuctusLogAddCategory("awarn3")
end

--CH_Mining, for mining gold with a pickaxe
if CH_Mining then
    hook.Add("CH_Mining_Hook_MineMinerals","luctus_log",function(ply, mineral, extracted_amount)
        if not IsValid(ply) then return end
        --LuctusLog("chmining", ply:GetName().."("..ply:SteamID()..") mined "..extracted_amount.."x "..mineral)
    end,-2)
    hook.Add("CH_Mining_Hook_SellMinerals","luctus_log",function(ply, amount, mineral, mineral_worth)
        if not IsValid(ply) then return end
        LuctusLog("chmining", ply:GetName().."("..ply:SteamID()..") sold "..amount.."x "..mineral.."("..mineral_worth.."$ each)")
    end,-2)
    LuctusLogAddCategory("chmining")
end

--itemstore
if itemstore then
    hook.Add("ItemStoreItemPickedUp","luctus_log",function(ply, item, ent)
        if not IsValid(ply) then return end
        LuctusLog("itemstore", ply:GetName().."("..ply:SteamID()..") itemstore-pickuped "..ent:GetClass())
    end,-2)
    hook.Add("ItemStoreItemUsed","luctus_log",function(ply, container, item)
        if not IsValid(ply) then return end
        local fromText = ""
        if container and container.GetOwner and IsValid(container:GetOwner()) and container:GetOwner():GetClass()=="itemstore_deathloot" then
            fromText = " from deathloot"
        end
        LuctusLog("itemstore", ply:GetName().."("..ply:SteamID()..") itemstore-used "..item:GetName()..fromText)
    end,-2)
    hook.Add("ItemStoreItemsMoved","luctus_log",function(ply,fromContainer,fromSlot,fromItem,toCon,toSlot,toItem)
        if not IsValid(ply) then return end
        local fromText = ""
        if fromContainer and fromContainer.GetOwner and IsValid(fromContainer:GetOwner()) and fromContainer:GetOwner():GetClass()=="itemstore_deathloot" then
            fromText = " from deathloot"
        end
        LuctusLog("itemstore", ply:GetName().."("..ply:SteamID()..") itemstore-pickuped "..fromItem:GetName()..fromText)
    end,-2)
    hook.Add("ItemStoreItemDropped","luctus_log",function(ply, container, slot, item)
        if not IsValid(ply) then return end
        if isnumber(item) then return end --split and drop have the same hookname, meh
        LuctusLog("itemstore", ply:GetName().."("..ply:SteamID()..") itemstore-dropped "..item:GetName())
    end,-2)
    hook.Add("ItemStoreItemDestroyed","luctus_log",function(ply, container, slot, item)
        if not IsValid(ply) then return end
        LuctusLog("itemstore", ply:GetName().."("..ply:SteamID()..") itemstore-destroyed "..item:GetName())
    end,-2)
    LuctusLogAddCategory("itemstore")
end


--Military Rank System (MRS), similar to jobranksystem
if MRS and MRS.Config then
    hook.Add("MRS.OnPromotion","luctus_log",function(targetPly, adminPly, rankGroup, newRankId, oldRankId, adminRankId, newRankName, oldRankName)
        if not IsValid(targetPly) or not IsValid(adminPly) then return end
        local rType = "up"
        if newRankId < oldRankId then
            rType = "down"
        end
        LuctusLog("mranks",targetPly:Nick().."("..targetPly:SteamID()..") got ranked "..rType.." to "..newRankName.." by "..adminPly:Nick().."("..adminPly:SteamID()..")")
    end)
    LuctusLogAddCategory("mranks")
end

--gDeathSystem
if MedConfig then
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
    LuctusLogAddCategory("gDeathSystem")
end

--TBFY Handcuffs
--This guy has no global vars that show the presence of his addon, so:
if hook.GetTable()["CanPlayerEnterVehicle"] and hook.GetTable()["CanPlayerEnterVehicle"]["Cuffs PreventVehicle"] then
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
    LuctusLogAddCategory("cuffs")
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
    LuctusLogAddCategory("adminsit")
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
    LuctusLogAddCategory("bwhitelist")
end

end,2)

print("[luctus_logs] sv customs loaded")
