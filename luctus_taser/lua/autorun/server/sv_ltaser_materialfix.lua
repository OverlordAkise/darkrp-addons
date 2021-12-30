--Luctus Taser
--Made by OverlordAkise

hook.Add("onDarkRPWeaponDropped", "luctus_taser_material_fix", function(ply, spawned_weapon, orig_weapon)
  if orig_weapon:GetClass() == "stungun_new" then
    spawned_weapon:SetMaterial("phoenix_storms/stripes")
  end
end)

hook.Add( "Initialize", "luctus_taser_ammo", function()
	game.AddAmmoType( {
    name = "tazer",
    dmgtype = DMG_SHOCK,
    tracer = TRACER_LINE,
    plydmg = 0,
    npcdmg = 0,
    force = 2000,
    minsplash = 10,
    maxsplash = 5
  })
end)
