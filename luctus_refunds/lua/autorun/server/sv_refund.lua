--Luctus Refunds
--Made by OverlordAkise

LUCTUS_RP_ENTS = {}

hook.Add("PlayerInitialSpawn","luctus_refunds_get_ents",function()
    for k,v in pairs(DarkRPEntities) do
        LUCTUS_RP_ENTS[v.ent] = v.price
    end

    if zwf and zwf.config and zwf.config.Shop then
        for k,category in pairs(zwf.config.Shop) do
            for kk,item in pairs(category.items) do
                if LUCTUS_RP_ENTS[item.class] then continue end
                LUCTUS_RP_ENTS[item.class] = item.price
            end
        end
    end
    PrintTable(LUCTUS_RP_ENTS)
    --Why PlayerInitialSpawn? Because i need for all ents to get created and added, and no hook is past "InitPostEntity" except this
    hook.Remove("PlayerInitialSpawn","luctus_refunds_get_ents")
end)

hook.Add("playerBoughtCustomEntity","luctus_ent_set_owner",function(ply, entityTable, ent, price)
    ent.luctus_owner = ply
end)

function luctusGetWorth(entClass)
    if LUCTUS_RP_ENTS[entClass] then
        return LUCTUS_RP_ENTS[entClass]
    end
    return 0
end


hook.Add("ShutDown","luctus_refunds",function()
    local allents = ents.GetAll()
    for k,v in pairs(player.GetAll()) do
        if not LUCTUS_REFUNDS[v:SteamID()] then
            LUCTUS_REFUNDS[v:SteamID()] = 0
        end
    end
    print("[luctus_refunds] Calculating refunds...")
    for k,v in pairs(allents) do
        owner, _ = v:CPPIGetOwner()
        if not IsValid(owner) then
            owner = v.luctus_owner
        end
        if IsValid(owner) and LUCTUS_REFUNDS[owner:SteamID()] and v:GetClass() ~= "prop_physics" then
            --print("Player:")
            --print(owner)
            --print("Ent:")
            --print(v)
            --print("Price:")
            --print(luctusGetWorth(v:GetClass()))
            LUCTUS_REFUNDS[owner:SteamID()] = LUCTUS_REFUNDS[owner:SteamID()] + luctusGetWorth(v:GetClass())
        end
    end

    PrintTable(LUCTUS_REFUNDS)
    file.Write("refunds.txt",util.TableToJSON(LUCTUS_REFUNDS))
    print("[luctus_refunds] Refunds saved!")
end)

LUCTUS_REFUNDS = {}
hook.Add("InitPostEntity","luctus_refunds",function()
    local f = file.Read("refunds.txt")
    if f then
        LUCTUS_REFUNDS = util.JSONToTable(f)
    end
    print("[luctus_refunds] Refunds loaded!")
end)


LUCTUS_REFUND_WEAPONS = {}
hook.Add("PlayerDeath","luctus_refunds_weps",function(ply)
    LUCTUS_REFUND_WEAPONS[ply:SteamID()] = {}
    for k,v in pairs(ply:GetWeapons()) do
        table.insert(LUCTUS_REFUND_WEAPONS[ply:SteamID()], v:GetClass())
    end
end)

hook.Add("PlayerInitialSpawn","luctus_refunds_notification",function(ply)
    if LUCTUS_REFUNDS[ply:SteamID()] then
        ply:PrintMessage(3,"You can request a refund of your previous entities!")
    end
end)

--[[
timer.Create("luctus_refunds_weps_cleanup",60,0,function()
    for k,v in pairs(LUCTUS_REFUND_WEAPONS) do
        
    end
end)
--]]

hook.Add("PlayerSay", "luctus_refunds", function(ply,text,team)
    if text == "!refund" then
        if LUCTUS_REFUNDS[ply:SteamID()] then
            local refund = LUCTUS_REFUNDS[ply:SteamID()]
            LUCTUS_REFUNDS[ply:SteamID()] = 0
            ply:addMoney(refund)
            ply:PrintMessage(3, "You got "..refund.."$ refunded!")
            print("[luctus_refunds] Player "..ply:Nick().." received refund of $"..refund)
        end
    end
    if text == "!refundweapon" then
        local targetPly = ply:GetEyeTrace().Entity
        if IsValid(targetPly) and targetPly:IsPlayer() and LUCTUS_REFUND_WEAPONS[targetPly:SteamID()] then
            for k,v in pairs(LUCTUS_REFUND_WEAPONS[targetPly:SteamID()]) do
                targetPly:Give(v)
            end
            ply:PrintMessage(3, "Player weapons refunded!")
        end
    end
end)

print("[luctus_refunds] sv loaded!")
