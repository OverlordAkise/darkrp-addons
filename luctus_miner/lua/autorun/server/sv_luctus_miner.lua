--Luctus Mining System
--Made by OverlordAkise

util.AddNetworkString("luctus_mine_npc")
util.AddNetworkString("luctus_mine_craft")
util.AddNetworkString("luctus_get_pickaxe")

function luctusMineCreateTable()
    local oreText = ""
    for k,v in pairs(luctus.mine.ores) do
        if k~=1 then oreText = oreText .. ", " end
        oreText = oreText .. v["Name"] .. " INT DEFAULT 0"
    end
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_mine(steamid TEXT, "..oreText..")")
    if res == false then
        error(sql.LastError())
    end
    for k,v in pairs(luctus.mine.ores) do
        local res = sql.Query("ALTER TABLE luctus_mine ADD COLUMN "..v["Name"].." INT DEFAULT 0")
        --if false then column exists, which is a non-error case
        if res == nil then
            print("[luctus_mine] New column '"..v["Name"].."' created!")
        end
    end
    print("[luctus_mine] Database initialized!")
end

luctusMineCreateTable() --PostGamemodeLoaded

function LuctusOreRandomWeighted(oresTable)
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

hook.Add("PlayerInitialSpawn","luctus_mine_loadPlayer",function(ply,transition)
    luctusMineLoadPlayer(ply)
end)

function luctusMineLoadPlayer(ply)
    ply.luctusOres = {}
    local res = sql.Query("SELECT * FROM luctus_mine WHERE steamid='"..ply:SteamID64().."'")
    if res == false then
        error(sql.LastError())
    end
    if res == nil then
        --not in db yet, so insert here
        local rres = sql.Query("INSERT INTO luctus_mine(steamid) VALUES('"..ply:SteamID64().."')")
        if rres == false then
            error(sql.LastError())
        end
        if rres == nil then
            print("[luctus_mine] Data for player "..ply:Nick().." was created!")
            luctusMineLoadPlayer(ply)--Should be only one recursion
            return
        end
    end
  ply.luctusOres = res[1]
  for k,v in pairs(ply.luctusOres) do
    if k~="steamid" then
      local nr = tonumber(v)
      if not nr then 
        ply:SetNWInt("ore_"..k,0)
      else
        ply:SetNWInt("ore_"..k,nr)
      end
    end
  end
  print("[luctus_mine] Successfully loaded player data for "..ply:Nick().."!")
end

function luctusMineSavePlayer(ply)
    local sText = ""
    for k,v in pairs(luctus.mine.ores) do
        if k~=1 then sText = sText .. ", " end
        sText = sText .. v["Name"] .. "=" .. ply.luctusOres[v["Name"]]
    end
    local res = sql.Query("UPDATE luctus_mine SET "..sText.." WHERE steamid='"..ply:SteamID64().."'")
    if res == false then
        error(sql.LastError())
    end
    print("[luctus_mine] Successfully saved player "..ply:Nick().."!")
end

timer.Create("luctus_mine_savePlayerData",120,0,function()
    for k,v in pairs(player.GetAll()) do
        if v.lmine_needstosave then
            luctusMineSavePlayer(v)
            v.lmine_needstosave = false
        end
    end
    --print("[luctus_mine] Player Data saved successfully by timer!")
end)

function luctusRandomNPCPrice(ent)
    for k,v in pairs(luctus.mine.ores) do
        ent:SetNWInt("sOre_"..v["Name"],math.random(v["PriceMin"],v["PriceMax"]))
    end
end

timer.Create("luctus_mine_randomNPCPrices",300,0,function()
    for k,v in pairs(ents.GetAll()) do
        if v:GetClass() == "luctus_mine_npc" then
            luctusRandomNPCPrice(v)
        end
    end
end)

function luctusMineGiveOre(ply)
    ply.lmine_needstosave = true
    local randomOre = LuctusOreRandomWeighted(luctus.mine.ores)
    if randomOre and randomOre.Name then 
        local name = randomOre["Name"]
        ply.luctusOres[name] = ply.luctusOres[name] + 1
        ply:SetNWInt("ore_"..name,ply:GetNWInt("ore_"..name)+1)
        DarkRP.notify(ply,2,5,"+"..name)
    end
end

net.Receive("luctus_mine_npc",function(len,ply)
    local num = net.ReadInt(16)
    local ore = net.ReadString()
    local npc = net.ReadEntity()
    if not IsValid(npc) then return end
    if num < 1 then return end
    if ply:GetNWInt("ore_"..ore,-1) == -1 then return end
    if num > ply:GetNWInt("ore_"..ore,-1) then return end

    ply:addMoney(npc:GetNWInt("sOre_"..ore,100)*num)
    ply:SetNWInt("ore_"..ore,ply:GetNWInt("ore_"..ore,0)-num)
    ply:SendLua("surface.PlaySound('ambient/levels/labs/coinslot1.wav')")
    DarkRP.notify(ply,3,5,"You sold your ore for "..(npc:GetNWInt("sOre_"..ore,100)*num).."$!")
    --PrintMessage(HUD_PRINTTALK, ore.." / "..num)
    luctusMineSavePlayer(ply)
end)

net.Receive("luctus_get_pickaxe", function(len,ply)
    if ply:getJobTable().name == LUCTUS_MINE_JOBNAME then return end
    ply:Give("weapon_crowbar")
end)

net.Receive("luctus_mine_craft",function(len,ply)
    local sitem = net.ReadString()
    if not sitem or sitem == "" then return end
    if (#ply:getPocketItems() >= GAMEMODE.Config.pocketitems) then
        DarkRP.notify(ply,1,5,"Error: Please make room in your pocket!")
        return 
    end
    if not luctus.mine.craftables[sitem] then return end
    local item = luctus.mine.craftables[sitem]
    for k,v in pairs(item) do
        --Why in the fuck is GetNWInt a string?
        if tonumber(ply:GetNWInt("ore_"..k,-1)) < tonumber(v) then
            DarkRP.notify(ply,1,5,"Error: You don't have enough resources for that!")
            return
        end
    end
    --Create entity first and check if it exists
    local ent = ents.Create(sitem)
    if not ent then return end
    if not IsValid(ent) then return end

    --Now that everything is ok we remove the ore and give the item
    for k,v in pairs(item) do
        ply:SetNWInt("ore_"..k,ply:GetNWInt("ore_"..k,-1)-v)
    end
    --ply:Give(item["Entity"])

    --button:SetModel( "models/dav0r/buttons/button.mdl" )
    ent:SetPos( ply:GetPos() )
    ent:Spawn()
    ply:addPocketItem(ent)
    ply:SendLua("surface.PlaySound('ambient/levels/labs/coinslot1.wav')")
    DarkRP.notify(ply,3,5,"[mine] Successfully crafted '"..sitem.."' !")
    luctusMineSavePlayer(ply)
end)

print("[luctus_mine] SV file loaded!")
