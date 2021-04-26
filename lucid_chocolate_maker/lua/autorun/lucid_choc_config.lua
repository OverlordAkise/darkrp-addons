
if CLIENT then
  surface.CreateFont( "DWall", {
    font = "Roboto",
    size = 38,
    weight = 500,
  })

  surface.CreateFont( "DWallSmall", {
    font = "Roboto",
    size = 20,
    weight = 500,
  })
  surface.CreateFont( "chocolate_font", {
    font = "Roboto Lt",
    size = 65,
    weight = 500,
} )
end

if SERVER then
  hook.Add("playerBoughtCustomEntity","lucid_choc_setowner",function(ply, entityTable, ent, price)
    if ent:GetClass() == "lucid_choc_stove" then
      ent:SetNWEntity("owner",ply)
    end
  end)
  hook.Add("PlayerDeath", "lucid_choc_giveChocolate", function(victim,inflictor,attacker)
    if IsValid(victim) and IsValid(attacker) and attacker:IsPlayer() then
      if victim.chefChocolate and victim.chefChocolate > 0 then
        attacker.chefChocolate = victim.chefChocolate
        victim.chefChocolate = 0
        DarkRP.notify(ply, 3, 5, "[choc] You stole "..victim:Nick().."'s "..attacker.chefChocolate.." chocolate bars! Sell it to WillyWonka!")
      end
    end
  end)
end

print("[choc] Loaded CHOC Job!")