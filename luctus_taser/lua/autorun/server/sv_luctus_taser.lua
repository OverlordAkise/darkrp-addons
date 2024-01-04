--Luctus Taser
--Made by OverlordAkise

hook.Add("onDarkRPWeaponDropped", "luctus_taser_worldmodel", function(ply, spawned_weapon, orig_weapon)
    if orig_weapon:GetClass() == "stungun_new" then
        spawned_weapon:SetMaterial("phoenix_storms/stripes")
    end
end)

hook.Add("Initialize", "luctus_taser_ammo", function()
    game.AddAmmoType({
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

function LuctusTazerRagdoll(ply,attacker)
    if IsValid(ply.luctusRagdollEnt) then
        ply.luctusRagdollEnt:Remove()
    end
    
    hook.Run("LuctusTaserPreRagdoll",ply,attacker)

    local ragdoll = ents.Create("prop_ragdoll")
    ragdoll.player = ply
    ply.luctusRagdollEnt = ragdoll
    ragdoll:SetPos(ply:GetPos())
    ragdoll:SetAngles(ply:GetAngles())
    ragdoll:SetModel(ply:GetModel())
    ragdoll:SetSkin(ply:GetSkin())
    ragdoll:SetColor(ply:GetColor())
    ragdoll:Spawn()
    ragdoll:Activate()
    ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

    ply:SetParent(ragdoll)
    ply:DeleteOnRemove(ragdoll)

    for i,v in ipairs(ply:GetBodyGroups()) do
        ragdoll:SetBodygroup(v.id, ply:GetBodygroup(v.id))
    end

    local velocity = ply:GetVelocity()
    velocity:Normalize()
    velocity:Mul(100)

    for i=0, ragdoll:GetPhysicsObjectCount() - 1 do
        local phys = ragdoll:GetPhysicsObjectNum(i)
        if not IsValid(phys) then break end
        phys:SetVelocity(velocity)
    end

    ply.luctusRagdollEntData = { hp = ply:Health(), armor = ply:Armor(), weapons = {}, model = ply:GetModel(), godmode = ply:HasGodMode() }
    for i,wep in ipairs(ply:GetWeapons()) do
        table.insert(ply.luctusRagdollEntData.weapons, wep:GetClass())
    end

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ragdoll)
    ply:StripWeapons()

    timer.Create("luctus_taser_ragdoll_"..ply:SteamID(), LUCTUS_TASER_RAGDOLLTIME, 1, function()
        if not IsValid(ply) then return end
        LuctusTazerUnRagdoll(ply)
    end)
    
    hook.Run("LuctusTaserPostRagdoll",ply,attacker,ragdoll)

    return ragdoll
end

function LuctusTazerUnRagdoll(ply)
    timer.Destroy("luctus_taser_ragdoll_" .. ply:SteamID())

    local ragdoll = ply.luctusRagdollEnt
    local data = ply.luctusRagdollEntData or {}
    ply:SetParent()
    ply:UnSpectate()
    ply:Spawn()
    ply:SetHealth(data.hp or 10)
    ply:SetArmor(data.armor or 0)
  
    for k,wepClass in ipairs(data.weapons) do
        ply:Give(wepClass)
    end

    if data.model then
        ply:SetModel(data.model)
    end

    if LUCTUS_TASER_FREEZETIME > 0 then
        ply:Freeze(true)
        timer.Simple(LUCTUS_TASER_FREEZETIME, function()
            if IsValid(ply) then
                ply:Freeze(false)
            end
        end)
    end

    --DarkRP "babygod" kills godmode after spawning, workaround:
    if data.godmode then
        if GAMEMODE.Config.babygodtime then
            timer.Simple(GAMEMODE.Config.babygodtime+0.1,function()
                ply:GodEnable()
            end)
        else
            ply:GodEnable()
        end
    end

    if not IsValid(ragdoll) then return end
    local y = ragdoll:GetAngles().y
    ply:SetAngles(Angle(0,yaw,0))
    ply:SetPos(ragdoll:GetPos() + Vector(0,0,2))
    ply:SetVelocity(ragdoll:GetVelocity())
    ragdoll:Remove()
end

print("[luctus_taser] sv loaded")
