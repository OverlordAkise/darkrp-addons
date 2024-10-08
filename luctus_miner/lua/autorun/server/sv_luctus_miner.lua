--Luctus Mining System
--Made by OverlordAkise

util.AddNetworkString("luctus_miner_sync")
util.AddNetworkString("luctus_miner_sync_all")
util.AddNetworkString("luctus_miner_npc")
util.AddNetworkString("luctus_miner_craft")
util.AddNetworkString("luctus_miner_get_pickaxe")

hook.Add("InitPostEntity","luctus_miner_database",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_miner(steamid TEXT, ores TEXT)")
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
    print("[luctus_miner] Database initialized!")
end)

net.Receive("luctus_miner_sync_all",function(len,ply)
    if ply.luctusMinerSynced then return end
    ply.luctusMinerSynced = true
    net.Start("luctus_miner_sync_all")
        net.WriteTable(ply.luctusOres)
    net.Send(ply)
end)

local orePoolSize = 0
for k,v in ipairs(LUCTUS_MINER_ORES) do
    orePoolSize = orePoolSize + v.DropPercent
end
function LuctusMinerGetRandomOre()
    local selection = math.random(1,orePoolSize*1.5)
    for k,v in ipairs(LUCTUS_MINER_ORES) do
        selection = selection - v.DropPercent
        if selection <= 0 then
            return v
        end
    end
    return nil
end

hook.Add("PlayerInitialSpawn","luctus_miner_loadPlayer",function(ply,transition)
    LuctusMinerLoadPlayer(ply)
end)

function LuctusMinerLoadPlayer(ply)
    ply.luctusOres = {}
    for k,ore in ipairs(LUCTUS_MINER_ORES) do
        ply.luctusOres[ore.Name] = 0
    end
    local res = sql.QueryValue("SELECT ores FROM luctus_miner WHERE steamid="..sql.SQLStr(ply:SteamID64()))
    if res == false then
        error(sql.LastError())
    end
    if res == nil then --not in db yet, so insert here
        local rres = sql.Query("INSERT INTO luctus_miner(steamid,ores) VALUES("..sql.SQLStr(ply:SteamID64())..",'{}')")
        if rres == false then
            error(sql.LastError())
        end
    else
        local tab = util.JSONToTable(res)
        for name,amount in pairs(tab) do
            ply.luctusOres[name] = amount
        end
    end
    print("[luctus_miner] Successfully loaded player data for "..ply:Nick())
end

function LuctusMinerSavePlayer(ply)
    local res = sql.Query("UPDATE luctus_miner SET ores="..sql.SQLStr(util.TableToJSON(ply.luctusOres)).." WHERE steamid="..sql.SQLStr(ply:SteamID64()))
    if res == false then
        ErrorNoHaltWithStack(sql.LastError())
    end
end

local plyNeedsSaving = {}
timer.Create("luctus_miner_savePlayerData",120,0,function()
    for ply,v in pairs(plyNeedsSaving) do
        LuctusMinerSavePlayer(ply)
    end
    plyNeedsSaving = {}
end)

function LuctusMinerRandomNPCPrice(ent)
    for k,ore in ipairs(LUCTUS_MINER_ORES) do
        ent.SellTable[ore.Name] = math.random(ore.PriceMin,ore.PriceMax)
    end
end

timer.Create("luctus_miner_randomizeNPCPrices",LUCTUS_MINER_RANDOM_TIMER,0,function()
    for k,ent in ipairs(ents.FindByClass("luctus_miner_npc")) do
        LuctusMinerRandomNPCPrice(ent)
    end
end)

function LuctusMinerGiveRandomOre(ply)
    plyNeedsSaving[ply] = true
    local randomOre = LuctusMinerGetRandomOre()
    if randomOre and randomOre.Name then 
        local name = randomOre["Name"]
        LuctusMinerGiveOre(ply,name,1)
    end
end

function LuctusMinerGiveOre(ply,ore,amount,dontNotify)
    plyNeedsSaving[ply] = true
    ply.luctusOres[ore] = ply.luctusOres[ore] + amount
    if dontNotify then return end
    net.Start("luctus_miner_sync")
        net.WriteString(ore)
        net.WriteUInt(ply.luctusOres[ore],16)
    net.Send(ply)
    hook.Run("LuctusMinerOreGained",ply,ore,amount)
end

net.Receive("luctus_miner_npc",function(len,ply)
    local num = net.ReadUInt(16)
    local ore = net.ReadString()
    local npc = net.ReadEntity()
    if not IsValid(npc) or not npc:GetClass() == "luctus_miner_npc" or not npc.SellTable[ore] or num > ply.luctusOres[ore] then return end

    ply:addMoney(npc.SellTable[ore]*num)
    LuctusMinerGiveOre(ply,ore,-1*num)
    DarkRP.notify(ply,3,5,"[Miner] You sold your ore for "..(npc.SellTable[ore]*num).."$!")
    LuctusMinerSavePlayer(ply)
    npc:EmitSound("ambient/levels/labs/coinslot1.wav")
    hook.Run("LuctusMinerSold",ply,ore,num,npc.SellTable[ore]*num)
end)

net.Receive("luctus_miner_get_pickaxe", function(len,ply)
    if LUCTUS_MINER_JOBWHITELIST and not LUCTUS_MINER_JOBNAMES[team.GetName(ply:Team())] then return end
    local npc = net.ReadEntity()
    if not IsValid(npc) or not npc:GetClass() == "luctus_miner_npc" or npc:GetPos():Distance(ply:GetPos()) > 512 then return end
    ply:Give(LUCTUS_MINER_PICKAXE_CLASSNAME)
end)

--Some servers forget this
hook.Add("canDropWeapon","luctus_miner_dont_drop_crowbar",function(ply, weapon)
    if not IsValid(weapon) then return end
    if weapon:GetClass() == "weapon_crowbar" then return false end
end)

local function IsWeapon(class)
    local swep = weapons.Get(class)
    if swep and swep.PrintName then return true end
    return false
end

net.Receive("luctus_miner_craft",function(len,ply)
    local sitem = net.ReadString()
    local tableEnt = net.ReadEntity()
    if not LUCTUS_MINER_CRAFTABLES[sitem] then return end
    if not tableEnt or not IsValid(tableEnt) or not tableEnt:GetClass() == "luctus_miner_craft" or tableEnt:GetPos():Distance(ply:GetPos()) > 500 then return end
    if LUCTUS_MINER_USE_POCKET and (#ply:getPocketItems() >= GAMEMODE.Config.pocketitems) then
        DarkRP.notify(ply,1,5,"[Miner] Please make room in your pocket!")
        return 
    end
    
    local item = LUCTUS_MINER_CRAFTABLES[sitem]
    for oreName,amount in pairs(item) do
        if not ply.luctusOres[oreName] or ply.luctusOres[oreName] < tonumber(amount) then
            DarkRP.notify(ply,1,5,"[Miner] You don't have enough resources for that!")
            return
        end
    end
    
    for k,v in pairs(item) do
        LuctusMinerGiveOre(ply,k,-1*v,true)
    end
    
    if IsWeapon(sitem) and not LUCTUS_MINER_USE_POCKET then
        ply:Give(sitem)
    else
        local ent = ents.Create(sitem)
        if not ent or not IsValid(ent) then return end

        ent:SetPos(tableEnt:GetPos()+Vector(0,0,50))
        ent:Spawn()
        if LUCTUS_MINER_USE_POCKET then
            ply:addPocketItem(ent)
        end
    end
    DarkRP.notify(ply,3,5,"[Miner] Successfully crafted '"..sitem.."' !")
    LuctusMinerSavePlayer(ply)
    tableEnt:EmitSound("npc/combine_soldier/gear1.wav")
    hook.Run("LuctusMinerCrafted",ply,sitem)
end)

print("[luctus_miner] sv loaded")
