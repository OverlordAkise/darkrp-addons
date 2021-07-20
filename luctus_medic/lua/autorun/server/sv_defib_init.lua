--Luctus Medicsystem
--Made by OverlordAkise

LUCTUS_DEATH_TIME = 60

hook.Add("PlayerSpawn","luctus_remove_svragdoll",function(ply)
  if ply.lragdoll then
    ply.lragdoll:Remove()
    ply.lragdoll = nil
  end
  ply:SetShouldServerRagdoll(true)
end)

hook.Add("PlayerDisconnected","luctus_remove_svragdoll",function(ply)
  if ply.lragdoll then
    ply.lragdoll:Remove()
  end
end)

hook.Add("CreateEntityRagdoll","luctus_set_death_owner",function(ply,rag)
  ply.lragdoll = rag
end)


util.AddNetworkString("luctus_deathscreen")
hook.Add("PostPlayerDeath","luctus_deathscreen",function(ply)
  net.Start("luctus_deathscreen")
    net.WriteInt(LUCTUS_DEATH_TIME,15)
  net.Send(ply)
  timer.Create(ply:SteamID().."_death_timer",LUCTUS_DEATH_TIME,1,function()
    if not ply:Alive() then
      ply:Spawn()
    end
    --print("RAN DEATH TIMER!")
  end)
end)

hook.Add("PlayerDeathThink","luctus_deathscreen",function(ply)
  return false
end)

hook.Add("PlayerSpawn","luctus_deathscreen",function(ply)
  net.Start("luctus_deathscreen")
    net.WriteInt(-1,15)
  net.Send(ply)
  --print("Running PlayerSpawn")
  if timer.Exists(ply:SteamID().."_death_timer") then
    timer.Remove(ply:SteamID().."_death_timer")
    --print("Removed timer!")
  end
end)

hook.Add("PlayerSay","luctus_deathscreen",function(ply,text,team)
  if text == "!resetscreen" then
    net.Start("luctus_deathscreen")
      net.WriteInt(-1,15)
    net.Send(ply)
  end
end)

print("[luctus_medic] SV init loaded!")
