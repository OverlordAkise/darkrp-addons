--Luctus Medicsystem
--Made by OverlordAkise


LUCTUS_DEATHSCREEN_HEADLINE = "My Community"
LUCTUS_DEATHSCREEN_RULES = "You are dead!\nYou either have to wait 60s or hope a medic revives you!"



hook.Add("CreateClientsideRagdoll","luctus_hide_cl_ragdolls",function(ownEnt,ragEnt)
  if ragEnt:GetClass() == "class C_HL2MPRagdoll" then
    ragEnt:SetNoDraw(true)
  end
end)

lDeathscreen = nil
net.Receive("luctus_deathscreen",function()
  print("Receiving deathscreen!")
  local deathTime = net.ReadInt(15)
  local endTime = CurTime()+deathTime
  if deathTime < 0 then -- = -1
    if lDeathscreen and IsValid(lDeathscreen) then
      lDeathscreen:Close()
    end
    print("Closing deathscreen")
    return
  end
  
  lDeathscreen = vgui.Create("DFrame")
  lDeathscreen:SetDraggable(false)
  lDeathscreen:ShowCloseButton(false)
  lDeathscreen:SetTitle("")
  lDeathscreen:SetPos(0,0)
  lDeathscreen:SetSize(ScrW(),ScrH())
  function lDeathscreen:Paint(w,h)
    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,240))
    draw.DrawText(LUCTUS_DEATHSCREEN_HEADLINE,"Trebuchet24",ScrW()/2,200,COLOR_WHITE,TEXT_ALIGN_CENTER)
    draw.DrawText(LUCTUS_DEATHSCREEN_RULES,"Trebuchet18",ScrW()/2,400,COLOR_WHITE,TEXT_ALIGN_CENTER)
    draw.DrawText("Respawn in "..math.Round(endTime-CurTime(),1),"DermaDefault",ScrW()/2,ScrH()-200,COLOR_WHITE,TEXT_ALIGN_CENTER)
  end
end)

print("[luctus_medic] CL init loaded!")