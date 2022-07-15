--Luctus Refunds
--Made by OverlordAkise

LUCTUS_REFUND_TIMER_DELAY = 120 --how often entities get saved


--Config end

LUCTUS_RP_ENTS = LUCTUS_RP_ENTS or {}
LUCTUS_REFUNDS_JOINED = LUCTUS_REFUNDS_JOINED or {}
LUCTUS_REFUNDS = LUCTUS_REFUNDS or {}

--Load all darkrp entities into a list
hook.Add("PlayerInitialSpawn","luctus_refunds_get_ents",function()
    for k,v in pairs(DarkRPEntities) do
        LUCTUS_RP_ENTS[v.ent] = v.price
    end
    
    --Zero's Weedfarm
    if zwf and zwf.config and zwf.config.Shop then
        for k,category in pairs(zwf.config.Shop) do
            for kk,item in pairs(category.items) do
                if LUCTUS_RP_ENTS[item.class] then continue end
                LUCTUS_RP_ENTS[item.class] = item.price
            end
        end
    end
    --Zero's Retrominer
    if zrmine and zrmine.config and zrmine.config.BuilderSWEP and zrmine.config.BuilderSWEP.entity_price then
        for entclass,price in pairs(zrmine.config.BuilderSWEP.entity_price) do
            if LUCTUS_RP_ENTS[entclass] then continue end
            LUCTUS_RP_ENTS[entclass] = price
        end
    
    end
    
    --PrintTable(LUCTUS_RP_ENTS)
    --Why PlayerInitialSpawn? Because i need for all ents to get created and added, and no hook is after "InitPostEntity" except this
    hook.Remove("PlayerInitialSpawn","luctus_refunds_get_ents")
end)


hook.Add("playerBoughtCustomEntity","luctus_ent_set_owner",function(ply, entityTable, ent, price)
    ent.luctus_owner = ply
end)


function luctusGetEntWorth(entClass)
    if LUCTUS_RP_ENTS[entClass] then
        return LUCTUS_RP_ENTS[entClass]
    end
    return 0
end


timer.Create("luctus_calculate_refunds",LUCTUS_REFUND_TIMER_DELAY,0,function()
    if #player.GetAll() < 1 then return end
    local ss = SysTime()
    local allents = ents.GetAll()
    for k,v in pairs(player.GetAll()) do
        if not LUCTUS_REFUNDS_JOINED[v:SteamID()] then continue end
        LUCTUS_REFUNDS[v:SteamID()] = 0
    end
    --print("[luctus_refunds] Calculating refunds...")
    
    --DarkRP ents
    for k,v in pairs(allents) do
        owner, _ = v:CPPIGetOwner()
        if not IsValid(owner) then
            owner = v.luctus_owner
        end
        if IsValid(owner) and LUCTUS_REFUNDS[owner:SteamID()] and v:GetClass() ~= "prop_physics" and LUCTUS_REFUNDS_JOINED[owner:SteamID()] then
            local entclass = v:GetClass()
            --print("Player:")
            --print(owner)
            --print("Ent:")
            --print(v)
            --print("Price:")
            --print(luctusGetEntWorth(entclass))
            LUCTUS_REFUNDS[owner:SteamID()] = LUCTUS_REFUNDS[owner:SteamID()] + luctusGetEntWorth(entclass)
            --ch_bitminer
            if entclass == "ch_bitminer_shelf" then
                local minerCount = v:GetMinersInstalled()
                if minerCount and minerCount > 0 then
                    LUCTUS_REFUNDS[owner:SteamID()] = LUCTUS_REFUNDS[owner:SteamID()] + (luctusGetEntWorth("ch_bitminer_upgrade_miner")*minerCount)
                end
            end
            --sprinter
            if string.StartWith(entclass, "sprinter_") and v.data and v.data.upgrades then
                for n,u in pairs(v.data.upgrades) do
                    if u.stage and u.stage > 0 then
                        LUCTUS_REFUNDS[owner:SteamID()] = LUCTUS_REFUNDS[owner:SteamID()] + ((u.stage * u.stage + u.stage) / 2) * u.baseprice
                        --^calculation of price via factorial but additive
                    end
                end
            end
        end
    end
    
    --retrominer bars
    for k,v in pairs(player.GetAll()) do
        if v.zrms_GetMetalBars then
            local bars = v:zrms_GetMetalBars()
            local barValue = 0
            for bartype,amount in pairs(bars) do
                if not isnumber(amount) then continue end
                barValue = barValue + (zrmine.config.BarValue[bartype]*amount)
            end
            if barValue > 0 then 
                LUCTUS_REFUNDS[v:SteamID()] = LUCTUS_REFUNDS[v:SteamID()] + barValue
            end
        end
    end
    

    --print("[luctus_refunds] Calculation done!")
    --PrintTable(LUCTUS_REFUNDS)
    file.Write("refunds.txt",util.TableToJSON(LUCTUS_REFUNDS))
    --print("[luctus_refunds] Refunds saved!")
    print("[luctus_refunds] Time taken: "..(SysTime()-ss).."s")
end)



hook.Add("InitPostEntity","luctus_refunds",function()
    local f = file.Read("refunds.txt")
    if f then
        LUCTUS_REFUNDS = util.JSONToTable(f)
        print("[luctus_refunds] old refunds loaded!")
    end
end)


hook.Add("PlayerInitialSpawn","luctus_refunds_notification",function(ply)
    timer.Simple(10,function()
        --print("[luctus_refunds] Checking if new player has refunds waiting...")
        --PrintTable(LUCTUS_REFUNDS)
        --print(ply:SteamID())
        --if LUCTUS_REFUNDS[ply:SteamID()] then print(LUCTUS_REFUNDS[ply:SteamID()]) end
        if not IsValid(ply) then return end
        if LUCTUS_REFUNDS[ply:SteamID()] then
            if LUCTUS_REFUNDS[ply:SteamID()] > 0 then
                local money = LUCTUS_REFUNDS[ply:SteamID()]
                LUCTUS_REFUNDS[ply:SteamID()] = 0
                ply:PrintMessage(3,"[refunds] You will be refunded for the previous session!")
                ply:addMoney(money)
                ply:PrintMessage(3,"[refunds] You gained "..money.."$ !")
                print("[luctus_refunds] Refunded "..ply:Nick().."("..ply:SteamID()..") "..money.."$")
            end
        end
        LUCTUS_REFUNDS_JOINED[ply:SteamID()] = true
    end)
end)


--Weapon refunds
LUCTUS_REFUND_WEAPONS = {}
hook.Add("PlayerDeath","luctus_refunds_weps",function(ply)
    LUCTUS_REFUND_WEAPONS[ply:SteamID()] = {}
    for k,v in pairs(ply:GetWeapons()) do
        table.insert(LUCTUS_REFUND_WEAPONS[ply:SteamID()], v:GetClass())
    end
end)


hook.Add("PlayerSay", "luctus_refunds", function(ply,text,team)
    if text == "!refundweapon" then
        local targetPly = ply:GetEyeTrace().Entity
        if IsValid(targetPly) and targetPly:IsPlayer() and LUCTUS_REFUND_WEAPONS[targetPly:SteamID()] then
            for k,v in pairs(LUCTUS_REFUND_WEAPONS[targetPly:SteamID()]) do
                targetPly:Give(v)
            end
            ply:PrintMessage(3, "[refunds] Player weapons refunded!")
        end
    end
end)


gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","luctus_refunds_anti_abuse",function(tab)
    if tab and tab.reason and isstring(tab.reason) then
        if not LUCTUS_REFUNDS_JOINED[tab.networkid] then return end
        if tab.reason == "Disconnect by user." then
            print("[luctus_refunds] User left by their will, removing refund")
            LUCTUS_REFUNDS[tab.networkid] = 0
        end
    end
    LUCTUS_REFUNDS_JOINED[tab.networkid] = nil
end)

print("[luctus_refunds] sv loaded!")
