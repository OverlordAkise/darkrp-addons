--Luctus Streetrobber
--Made by OverlordAkise

hook.Add("PlayerInitialSpawn","luctus_streetrobber",function(ply)
    --For whatever reason NW2 breaks if set directly here without delay
    timer.Simple(5,function()
        if IsValid(ply) then ply:SetNW2Bool("lstreetrobbable",true) end
    end)
end)

LUCTUS_STREETROBBER_LAST_E_PRESS = LUCTUS_STREETROBBER_LAST_E_PRESS or {}

timer.Create("luctus_streetrobber_cache_clean",180,0,function()
    for ply,k in pairs(LUCTUS_STREETROBBER_LAST_E_PRESS) do
        if not IsValid(ply) then LUCTUS_STREETROBBER_LAST_E_PRESS[ply] = nil end
    end
end)

hook.Add("PlayerUse","luctus_streetrobber",function(robber,victim)
    if not victim:IsPlayer() then return end
    if not robber:GetNW2Bool("lstreetrobbable",false) then return end
    if not victim:GetNW2Bool("lstreetrobbable",false) then return end
    if not LuctusCanBeStreetRobbed(robber,victim) then return end
    if not LUCTUS_STREETROBBER_LAST_E_PRESS[victim] then
        LUCTUS_STREETROBBER_LAST_E_PRESS[victim] = 0
    end
    if LUCTUS_STREETROBBER_LAST_E_PRESS[victim] < CurTime() then
        victim:SetNW2Float("lstreetrob_progress",0)
        victim:EmitSound("npc/combine_soldier/gear5.wav")
        
    end
    LUCTUS_STREETROBBER_LAST_E_PRESS[victim] = CurTime() + LUCTUS_STREETROBBER_RESET_DELAY
    victim:SetNW2Float("lstreetrob_progress",victim:GetNW2Float("lstreetrob_progress")+LUCTUS_STREETROBBER_SPEED)
    if victim:GetNW2Float("lstreetrob_progress") >= 100 then
        LuctusStreetRob(robber,victim)
        victim:SetNW2Float("lstreetrob_progress",0)
    end
end)

function LuctusStreetRob(attacker,victim)
    victim:SetNW2Bool("lstreetrobbable",false)
    attacker:SetNW2Bool("lstreetrobbable",false)
    local moneyToRob = LUCTUS_STREETROBBER_AMOUNT
    if LUCTUS_STREETROBBER_AMOUNT < 1 then
        moneyToRob = math.floor(victim:getDarkRPVar("money")*LUCTUS_STREETROBBER_AMOUNT)
    end
    if not victim:canAfford(moneyToRob) then
        moneyToRob = victim:getDarkRPVar("money")
    end
    
    victim:addMoney(-moneyToRob)
    attacker:addMoney(moneyToRob)
    
    hook.Run("LuctusStreetRobbed",victim,attacker)
    victim:EmitSound("items/ammo_pickup.wav")
    DarkRP.notify(victim,4,5,"You have been robbed! You lost $"..moneyToRob)
    DarkRP.notify(attacker,3,5,"You have robbed $"..moneyToRob)
    timer.Simple(LUCTUS_STREETROBBER_ROBBER_COOLDOWN,function()
        if IsValid(attacker) then
            attacker:SetNW2Bool("lstreetrobbable",true)
        end
    end)
    timer.Simple(LUCTUS_STREETROBBER_VICTIM_COOLDOWN,function()
        if IsValid(victim) then
            victim:SetNW2Bool("lstreetrobbable",true)
        end
    end)
end

print("[luctus_streetrobber] sv loaded")
