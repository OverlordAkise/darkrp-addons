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
  if res == false then print("[luctus_minesystem] ERROR DURING TABLE CREATION!") end
  if res == nil then print("[luctus_minesystem] PreInit Done!") end
  for k,v in pairs(luctus.mine.ores) do
    local res = sql.Query("ALTER TABLE luctus_mine ADD COLUMN "..v["Name"].." INT DEFAULT 0")
    if res == false then print("Column '"..v["Name"].."' already exists.") end
    if res == nil then print("Column '"..v["Name"].."' created!.") end
  end
  print("[luctus_minesystem] PostInit Done!")
end

luctusMineCreateTable() --PostGamemodeLoaded


hook.Add("OnPlayerChangedTeam","luctus_mine_config",function(ply, numBefore, numAfter)
  local nam = TEAM_SIMPLEMINER or -1
  if nam ~= -1 then
    if numAfter == nam then
      if not ply.luctusOres then luctusMineLoadPlayer(ply) end
    end
    if numBefore == nam then
      luctusMineSavePlayer(ply)
    end
  end
end)

hook.Add("PlayerInitialSpawn","luctus_mine_loadPlayer",function(ply,transition)
  luctusMineLoadPlayer(ply)
end)

function luctusRandomNPCPrice(ent)
  for k,v in pairs(luctus.mine.ores) do
    ent:SetNWInt("sOre_"..v["Name"],math.random(v["PriceMin"],v["PriceMax"]))
  end
end

function luctusMineLoadPlayer(ply)
  ply.luctusOres = {}
  local res = sql.Query("SELECT * FROM luctus_mine WHERE steamid='"..ply:SteamID64().."'")
  if res == false then print("[luctus_minesystem] ERROR: Couldn't load player "..ply:Nick().." from DB!") return end
  if res == nil then
    local rres = sql.Query("INSERT INTO luctus_mine(steamid) VALUES('"..ply:SteamID64().."')")
    if rres == false then print("[luctus_minesystem] ERROR: Couldn't create player "..ply:Nick().." in DB!") return end
    if rres == nil then 
      print("[luctus_minesystem] Data for player "..ply:Nick().." was created!")
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
  print("[luctus_minesystem] Successfully loaded player data for "..ply:Nick().."!")
end

function luctusMineSavePlayer(ply)
  local sText = ""
  for k,v in pairs(luctus.mine.ores) do
    if k~=1 then sText = sText .. ", " end
    sText = sText .. v["Name"] .. "=" .. ply.luctusOres[v["Name"]]
  end
  local res = sql.Query("UPDATE luctus_mine SET "..sText.." WHERE steamid='"..ply:SteamID64().."'")
  if res == false then print("[luctus_minesystem] ERROR: Couldn't save player "..ply:Nick().." to DB!") return end
  if res == nil then
    print("[luctus_minesystem] Successfully saved player "..ply:Nick().."!")
  end
end

timer.Create("luctus_mine_savePlayerData",120,0,function()
  for k,v in pairs(player.GetAll()) do
    if v:Team() == TEAM_DKLASSE then
      luctusMineSavePlayer(v)
    end
  end
  print("[luctus_minesystem] Player Data saved successfully by timer!")
end)

timer.Create("luctus_mine_randomNPCPrices",60,0,function()
  for k,v in pairs(ents.GetAll()) do
    if v:GetClass() == "luctus_mine_npc" then
      for a,b in pairs(luctus.mine.ores) do
        v:SetNWInt("sOre_"..b["Name"],math.random(b["PriceMin"],b["PriceMax"]))
      end
    end
  end
  
end)

function luctusMineGiveOre(ply)
  local randomOre = weightedRandom(luctus.mine.ores)
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
end)

net.Receive("luctus_get_pickaxe", function(len,ply)
  if not ply:getJobTable().name == luctus.mine.jobName then return end
  ply:Give("weapon_crowbar")
end)

net.Receive("luctus_mine_craft",function(len,ply)
  local sitem = net.ReadString()
  if not sitem or sitem == "" then return end
  if (#ply:getPocketItems() >= GAMEMODE.Config.pocketitems) then
    DarkRP.notify(ply,1,5,"Error: Please make room in your pocket!")
    return 
  end
  local item = {}
  for k,v in pairs(luctus.mine.craftables) do
    if v["Entity"] == sitem then
      item = v
      break
    end
  end
  if item == {} then return end
  for k,v in pairs(item) do
    if k=="Entity" then continue end
    --Why in the fuck is GetNWInt a string?
    if tonumber(ply:GetNWInt("ore_"..k,-1)) < tonumber(v) then
      DarkRP.notify(ply,1,5,"Error: You don't have enough resources for that!")
      return
    end
  end
  --Create entity first and check if it exists
  local ent = ents.Create( item["Entity"] )
  if not ent then return end
  if not IsValid(ent) then return end
  
  --Now that everything is ok we remove the ore and give the item
  for k,v in pairs(item) do
    if k=="Entity" then continue end
    ply:SetNWInt("ore_"..k,ply:GetNWInt("ore_"..k,-1)-v)
  end
  --ply:Give(item["Entity"])
  
  --button:SetModel( "models/dav0r/buttons/button.mdl" )
  ent:SetPos( ply:GetPos() )
  ent:Spawn()
  ply:addPocketItem(ent)
  ply:SendLua("surface.PlaySound('ambient/levels/labs/coinslot1.wav')")
  DarkRP.notify(ply,3,5,"[mine] Successfully crafted '"..item["Entity"].."' !")
end)

hook.Add("EntityTakeDamage", "luctus_mineshaft_quick", function(target, dmginfo)
	if (target and target:GetClass() == "func_breakable" and dmginfo:GetAttacker():GetActiveWeapon():GetClass() == "weapon_crowbar") then
		dmginfo:ScaleDamage(15)
	end
end)

print("[luctus_minesystem] SV file loaded!")