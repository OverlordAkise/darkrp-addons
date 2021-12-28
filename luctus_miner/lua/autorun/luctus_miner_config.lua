--Luctus Mining System
--Made by OverlordAkise

luctus = luctus or {}
luctus.mine = {}
-- Which job can get a pickaxe from the NPC
-- The fancy name here:
luctus.mine.jobName = "Miner"
luctus.mine.orePercent = 33
luctus.mine.minSpawnTime = 30
luctus.mine.maxSpawnTime = 120
luctus.mine.minSpawnHP = 150
luctus.mine.maxSpawnHP = 400
luctus.mine.ores = {
  {Name = "Coal", PriceMin = 25, PriceMax = 75, Color=Color(255,255,255,255), DropPercent = 50},
  {Name = "Bronze", PriceMin = 100, PriceMax = 200, Color=Color(139,69,19,255), DropPercent = 30},
  {Name = "Silver", PriceMin = 200, PriceMax = 300, Color=Color(192,192,192,255), DropPercent = 20},
  {Name = "Gold", PriceMin = 300, PriceMax = 400, Color=Color(255,215,0,255), DropPercent = 5},
  {Name = "Diamond", PriceMin = 400, PriceMax = 500, Color=Color(0,191,255,255), DropPercent = 3},
  {Name = "Ruby", PriceMin = 800, PriceMax = 1200, Color=Color(255,5,5,255), DropPercent = 2},
}

luctus.mine.craftables = {
  {Entity = "m9k_knife", Coal=50, Bronze=50,Silver=5},
  {Entity = "guthscp_keycard_lvl_1", Coal=10, Silver=20},
  {Entity = "guthscp_keycard_lvl_2", Coal=10, Gold=20},
  {Entity = "guthscp_keycard_lvl_3", Coal=10, Diamond=10},
  {Entity = "guthscp_keycard_lvl_4", Coal=10, Ruby=10},
} 

function weightedRandom(oresTable)
   local poolsize = 0
   for k,v in pairs(oresTable) do
      poolsize = poolsize + v["DropPercent"]
   end
   local selection = math.random(1,poolsize*1.5)
   for k,v in pairs(oresTable) do
      selection = selection - v["DropPercent"] 
      if (selection <= 0) then
         return v
      end
   end
   return nil
end

print("[luctus_minesystem] SH config file loaded!")
