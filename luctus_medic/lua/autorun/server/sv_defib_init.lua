--Luctus Medicsystem
--Made by OverlordAkise

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

hook.Add("CreateEntityRagdoll","luctus_test_owner",function(ply,rag)
  ply.lragdoll = rag
end)

print("[luctus_medic] SV init loaded!")
