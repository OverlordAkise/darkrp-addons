--Luctus Mining System
--Made by OverlordAkise

luctus = luctus or {}
luctus.mine = {}

--CONFIG START

--Should crafted things be put into your DarkRP "pocket"
LUCTUS_MINE_USE_POCKET = false

-- Which job can get a pickaxe from the NPC
LUCTUS_MINE_JOBNAME = "Miner"
--Which weapon should be able to "mine" rocks?
LUCTUS_MINE_PICKAXE_CLASSNAME = "weapon_crowbar"
--How long a rock takes to respawn, in seconds
LUCTUS_MINE_RESPAWNTIME = 120
--Every hit, how much percent to get ore
LUCTUS_MINE_OREPERCENT = 33
--HP that a rock has
LUCTUS_MINE_ROCK_HP = 200

--Ore config
luctus.mine.ores = {
    {Name = "Coal", PriceMin = 25, PriceMax = 75, Color=Color(255,255,255,255), DropPercent = 50},
    {Name = "Bronze", PriceMin = 100, PriceMax = 200, Color=Color(139,69,19,255), DropPercent = 30},
    {Name = "Silver", PriceMin = 200, PriceMax = 300, Color=Color(192,192,192,255), DropPercent = 20},
    {Name = "Gold", PriceMin = 300, PriceMax = 400, Color=Color(255,215,0,255), DropPercent = 5},
    {Name = "Diamond", PriceMin = 400, PriceMax = 500, Color=Color(0,191,255,255), DropPercent = 3},
    {Name = "Ruby", PriceMin = 800, PriceMax = 1200, Color=Color(255,5,5,255), DropPercent = 2},
}

--Crafting config
luctus.mine.craftables = {
    ["m9k_knife"] = {Coal=50, Bronze=50,Silver=5},
    ["guthscp_keycard_lvl_1"] = {Coal=10, Silver=20},
    ["guthscp_keycard_lvl_2"] = {Coal=10, Gold=20},
    ["guthscp_keycard_lvl_3"] = {Coal=10, Diamond=10},
    ["guthscp_keycard_lvl_4"] = {Coal=10, Ruby=10},
} 

print("[luctus_mine] SH config file loaded!")
