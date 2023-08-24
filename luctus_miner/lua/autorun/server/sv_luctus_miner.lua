--Luctus Mining System
--Made by OverlordAkise

util.AddNetworkString("luctus_miner_sync")
util.AddNetworkString("luctus_miner_sync_all")
util.AddNetworkString("luctus_miner_npc")
util.AddNetworkString("luctus_miner_craft")
util.AddNetworkString("luctus_miner_get_pickaxe")

function luctusMineCreateTable()
    local oreText = ""
    for k,v in pairs(LUCTUS_MINER_ORES) do
        if k~=1 then oreText = oreText .. ", " end
        oreText = oreText .. v["Name"] .. " INT DEFAULT 0"
    end
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_mine(steamid TEXT, "..oreText..")")
    if res == false then
        error(sql.LastError())
    end
    for k,v in pairs(LUCTUS_MINER_ORES) do
        local res = sql.Query("ALTER TABLE luctus_mine ADD COLUMN "..v["Name"].." INT DEFAULT 0")
        --if false then column exists, which is a non-error case
        if res == nil then
            print("[luctus_miner] New column '"..v["Name"].."' created!")
        end
    end
    print("[luctus_miner] Database initialized!")
end

luctusMineCreateTable() --PostGamemodeLoaded

net.Receive("luctus_miner_sync_all",function(len,ply)
    if ply.luctusMinerSynced then return end
    ply.luctusMinerSynced = true
    net.Start("luctus_miner_sync_all")
        net.WriteTable(ply.luctusOres)
    net.Send(ply)
end)

function LuctusMinerRandomOre(oresTable)
    local poolsize = 0
    for k,v in pairs(oresTable) do
        poolsize = poolsize + v["DropPercent"]
    end
    local selection = math.random(1,poolsize*1.5)
    for k,v in pairs(oresTable) do
        selection = selection - v["DropPercent"] 
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
    local res = sql.Query("SELECT * FROM luctus_mine WHERE steamid="..sql.SQLStr(ply:SteamID64()))
    if res == false then
        error(sql.LastError())
    end
    if res == nil then
        --not in db yet, so insert here
        local rres = sql.Query("INSERT INTO luctus_mine(steamid) VALUES("..sql.SQLStr(ply:SteamID64())..")")
        if rres == false then
            error(sql.LastError())
        end
        if rres == nil then
            print("[luctus_miner] Data for player "..ply:Nick().." was created!")
            LuctusMinerLoadPlayer(ply) --Should be only one recursion
            return
        end
    end
    local tempOres = res[1]
    for k,v in pairs(tempOres) do
        if k == "steamid" then continue end
        local nr = tonumber(v)
        if not nr then 
            ply.luctusOres[k] = 0
        else
            ply.luctusOres[k] = nr
        end
    end
    print("[luctus_miner] Successfully loaded player data for "..ply:Nick())
end

function LuctusMinerSavePlayer(ply)
    local sText = ""
    for k,v in pairs(LUCTUS_MINER_ORES) do
        if k~=1 then sText = sText .. ", " end
        sText = sText .. v["Name"] .. "=" .. ply.luctusOres[v["Name"]]
    end
    local res = sql.Query("UPDATE luctus_mine SET "..sText.." WHERE steamid="..sql.SQLStr(ply:SteamID64()))
    if res == false then
        error(sql.LastError())
    end
    --print("[luctus_miner] Successfully saved player "..ply:Nick().."!")
end

timer.Create("luctus_miner_savePlayerData",120,0,function()
    for k,v in pairs(player.GetAll()) do
        if v.lmine_needstosave then
            LuctusMinerSavePlayer(v)
            v.lmine_needstosave = false
        end
    end
    --print("[luctus_miner] Player Data saved successfully by timer!")
end)

function LuctusMinerRandomNPCPrice(ent)
    for k,v in pairs(LUCTUS_MINER_ORES) do
        ent.SellTable[v["Name"]] = math.random(v["PriceMin"],v["PriceMax"])
    end
end

timer.Create("luctus_miner_randomNPCPrices",300,0,function()
    for k,ent in ipairs(ents.FindByClass("luctus_miner_npc")) do
        LuctusMinerRandomNPCPrice(ent)
    end
end)

function LuctusMinerGiveRandomOre(ply)
    ply.lmine_needstosave = true
    local randomOre = LuctusMinerRandomOre(LUCTUS_MINER_ORES)
    if randomOre and randomOre.Name then 
        local name = randomOre["Name"]
        LuctusMinerGiveOre(ply,name,1)
    end
end

function LuctusMinerGiveOre(ply,ore,amount,dontNotify)
    ply.lmine_needstosave = true
    ply.luctusOres[ore] = ply.luctusOres[ore] + amount
    if dontNotify then return end
    net.Start("luctus_miner_sync")
        net.WriteString(ore)
        net.WriteUInt(ply.luctusOres[ore],16)
    net.Send(ply)
end

net.Receive("luctus_miner_npc",function(len,ply)
    local num = net.ReadInt(16)
    local ore = net.ReadString()
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if num < 1 then return end
    if num > ply.luctusOres[ore] then return end

    ply:addMoney(npc.SellTable[ore]*num)
    LuctusMinerGiveOre(ply,ore,-1*num)
    DarkRP.notify(ply,3,5,"[Miner] You sold your ore for "..(npc.SellTable[ore]*num).."$!")
    LuctusMinerSavePlayer(ply)
    npc:EmitSound("ambient/levels/labs/coinslot1.wav")
end)

net.Receive("luctus_miner_get_pickaxe", function(len,ply)
    if ply:getJobTable().name == LUCTUS_MINER_JOBNAME then return end
    ply:Give(LUCTUS_MINER_PICKAXE_CLASSNAME)
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
    if not tableEnt or not IsValid(tableEnt) or tableEnt:GetPos():Distance(ply:GetPos()) > 500 then return end
    if LUCTUS_MINER_USE_POCKET and (#ply:getPocketItems() >= GAMEMODE.Config.pocketitems) then
        DarkRP.notify(ply,1,5,"[Miner] Please make room in your pocket!")
        return 
    end
    
    local item = LUCTUS_MINER_CRAFTABLES[sitem]
    for k,v in pairs(item) do
        if not ply.luctusOres[k] or ply.luctusOres[k] < tonumber(v) then
            DarkRP.notify(ply,1,5,"[Miner] You don't have enough resources for that!")
            return
        end
    end
    if IsWeapon(sitem) and not LUCTUS_MINER_USE_POCKET then
        ply:Give(sitem)
    else
        local ent = ents.Create(sitem)
        if not ent or not IsValid(ent) then return end

        for k,v in pairs(item) do
            LuctusMinerGiveOre(ply,k,-1*v,true)
        end
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
