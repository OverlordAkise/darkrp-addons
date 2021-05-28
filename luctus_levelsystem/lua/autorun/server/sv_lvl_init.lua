--Luctus Levelsystem
--Made by OverlordAkise

hook.Add("PostGamemodeLoaded","luctus_scpnames",function()
  sql.Query("CREATE TABLE IF NOT EXISTS luctus_levelsystem( steamid TEXT, exp INT, lvl INT )")
end)

function Luctus_savexp(ply)
  ply:SetNWInt("lvl",ply.lvl)
  ply:SetNWInt("exp",ply.exp)
  local res = sql.Query("UPDATE luctus_levelsystem SET exp = "..ply.exp..", lvl = "..ply.lvl.." WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  if res == false then
    print("[luctus_levelsystem] ERROR DURING SQL UPDATE!")
    print(sql.LastError())
  end
end

function Luctus_loadxp(ply)
  ply.lvl = 1
  ply.exp = 0
  ply:SetNWInt("lvl",ply.lvl)
  ply:SetNWInt("exp",ply.exp)
	local res = sql.Query("SELECT * FROM luctus_levelsystem WHERE steamid = "..sql.SQLStr(ply:SteamID()))
  if res == false then
    print("[luctus_levelsystem] ERROR DURING SQL UPDATE!")
    print(sql.LastError())
    return
  end
  if res and res[1] then
    --print("Found level!")
    --print(res[1].lvl)
    --print(type(res[1].lvl))
    ply.lvl = res[1].lvl
    ply.exp = res[1].exp
    ply:SetNWInt("lvl",ply.lvl)
    ply:SetNWInt("exp",ply.exp)
    print("[luctus_levelsystem] User successfully loaded!")
  else
    local res = sql.Query("INSERT INTO luctus_levelsystem(steamid,exp,lvl) VALUES("..sql.SQLStr(ply:SteamID())..",0,1)")
    if res == false then
      print("[luctus_levelsystem] ERROR DURING SQL INSERT!")
      print(sql.LastError())
      return
    end
    print("[luctus_levelsystem] New user successfully inserted!")
  end
end

hook.Add('PlayerDisconnected', 'LVL_SaveOnDisconnect', function(ply)
	Luctus_savexp(ply)
end)
 
hook.Add('ShutDown', 'LVL_SaveOnShutdown', function()
	for k,v in pairs(player.GetAll()) do
		Luctus_savexp(v)
	end
end)

hook.Add("PlayerInitialSpawn","LVL_InitialLevel",function(ply)
	Luctus_loadxp(ply)
end)

hook.Add("PlayerDeath","LVL_SetLevel",function(ply,inflictor,attacker)
	if attacker:IsPlayer() && IsValid(attacker) then
		Luctus_givexp(attacker,5)
	end
end)

function Luctus_givexp(ply,amount)
	ply.exp = ply.exp + amount
  DarkRP.notify(ply,0,5,"Du hast "..amount.." XP bekommen!")
	while ply.exp >= Luctus_reqexp(ply.lvl)  do
		ply.exp = ply.exp - Luctus_reqexp(ply.lvl)
		ply.lvl = ply.lvl + 1
    DarkRP.notify(ply,0,5,"Du hast Lv."..ply.lvl.." erreicht!")
	end
  Luctus_savexp(ply)
end

timer.Create("luctus_lvl_timer",300,0,function()
  for k,v in pairs(player.GetAll()) do
    Luctus_givexp(v,20)
  end
end)


print("[luctus_levelsystem] SV file loaded!")
