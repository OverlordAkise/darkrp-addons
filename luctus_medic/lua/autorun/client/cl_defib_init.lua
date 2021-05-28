--Luctus Medicsystem
--Made by OverlordAkise

hook.Add("CreateClientsideRagdoll","luctus_hide_cl_ragdolls",function(ownEnt,ragEnt)
  if ragEnt:GetClass() == "class C_HL2MPRagdoll" then
    ragEnt:SetNoDraw(true)
  end
end)

print("[luctus_medic] CL init loaded!")