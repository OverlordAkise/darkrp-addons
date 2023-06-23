--Luctus Skills
--Made by OverlordAkise

util.AddNetworkString("luctus_skills")

hook.Add("InitPostEntity","luctus_skills",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_skills (steamid TEXT, skill TEXT, level INT, UNIQUE(steamid,skill) ON CONFLICT REPLACE)")
    if res==false then
        error(sql.LastError())
    end
end)

hook.Add("PlayerSay","luctus_skills",function(ply,text)
    if text == "!skills" then
        local tab = table.Copy(LUCTUS_SKILLS)
        for skill,v in pairs(tab) do
            if ply.lskills[skill] then
                tab[skill]["level"] = ply.lskills[skill]
            else
                tab[skill]["level"] = 0
            end
        end
        net.Start("luctus_skills")
            net.WriteTable(tab)
        net.Send(ply)
    end
end)

function LuctusSkillLoadPly(ply)
    ply.lskills = {}
    local res = sql.Query("SELECT * FROM luctus_skills WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res == false then
        error(sql.LastError())
    end
    if res and res[1] then
        for k,v in pairs(res) do
            ply.lskills[v.skill] = v.level
        end
    end
end

hook.Add("PlayerInitialSpawn","luctus_skills",function(ply)
    LuctusSkillLoadPly(ply)
end)

net.Receive("luctus_skills",function(len,ply)
    
    local numberOfSkills = net.ReadUInt(8)
    if numberOfSkills > 100 then return end
    local tab = {}
    for i=1,numberOfSkills do
        tab[net.ReadString()] = net.ReadUInt(8)
    end
    PrintTable(tab)
    --Check input
    local levelTotal = 0
    for skill,level in pairs(tab) do
        if not LUCTUS_SKILLS[skill] then return end
        if level > 0 and ply:getLevel() < LUCTUS_SKILLS[skill].req then return end
        if level > LUCTUS_SKILLS[skill].max then return end
        levelTotal = levelTotal + level
    end
    if levelTotal > ply:getLevel() then return end
    --Set input
    local res = nil
    for skill,level in pairs(tab) do
        ply.lskills[skill] = level
        res = sql.Query("INSERT INTO luctus_skills(steamid,skill,level) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(skill)..","..level..")")
        if res==false then error(sql.LastError()) end
    end
    DarkRP.notify(ply,0,5,"[skills] Successfully saved!")
    ply:PrintMessage(3,"[skills] Successfully saved!")
end)

hook.Add("EntityTakeDamage","luctus_skills",function(ply,dmginfo)
--hook.Add("ScalePlayerDamage","luctus_skills",function(ply,hitgroup,dmginfo)
    local att = dmginfo:GetAttacker()
    if not IsValid(att) then return end
    if not att:IsPlayer() then return end
    local wep = att:GetActiveWeapon()
    if not IsValid(wep) then return end
    
    if att.lskills.Boxer and wep:GetClass() == "weapon_fists" then
        dmginfo:AddDamage(att.lskills.Boxer)
    end
    if att.lskills.BoxChampion and wep:GetClass() == "weapon_fists" then
        dmginfo:AddDamage(10)
    end
    if att.lskills.Fireman and dmginfo:IsDamageType(DMG_BURN) then
        dmginfo:SubtractDamage(att.lskills.Fireman)
    end
    if att.lskills.Upperthighmuscles and dmginfo:IsDamageType(DMG_FALL) then
        dmginfo:SubtractDamage(att.lskills.Upperthighmuscles)
    end
    if att.lskills["Last Chance"] and att:Health() <= 5 then
        dmginfo:AddDamage(10)
    end
    --At the end
    if not ply.lskills then return end
    if ply.lskills["Second Chance"] and ply:Health() == ply:GetMaxHealth() and dmginfo:GetDamage() >= ply:Health() then
        dmginfo:SetDamage(ply:Health()-1)
    end
end)

hook.Add( "PlayerFootstep", "luctus_skills", function(ply)
    if ply.lskills.SneakyShoes and ply.lskills.SneakyShoes > 0 then return true end
end)

timer.Create("luctus_skills_hp",60,0,function()
    for k,v in pairs(player.GetAll()) do
        if IsValid(v) and v.lskills and v.lskills.Patience then
            v:SetHealth(math.min(v:Health()+v.lskills.Patience,v:GetMaxHealth()))
        end
    end
end)

print("[luctus_skills] sv loaded")
