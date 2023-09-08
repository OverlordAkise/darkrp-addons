--Luctus Skills
--Made by OverlordAkise

util.AddNetworkString("luctus_skills")

LUCTUS_SKILLS_PLY = LUCTUS_SKILLS_PLY or {}

hook.Add("InitPostEntity","luctus_skills",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_skills (steamid TEXT, skills TEXT, UNIQUE(steamid) ON CONFLICT REPLACE)")
    if res==false then
        error(sql.LastError())
    end
    local meta = FindMetaTable("Player")
    if not meta.getLevel then
        ErrorNoHaltWithStack("ERROR, No compatible leveling system installed! Skills not working!")
    end
end)

function LuctusSkillHas(ply,name)
    return LUCTUS_SKILLS_PLY[ply][name] > 0
end

hook.Add("PlayerSay","luctus_skills",function(ply,text)
    if text == "!skills" then
        net.Start("luctus_skills")
            net.WriteTable(LUCTUS_SKILLS_PLY[ply])
        net.Send(ply)
    end
end)

function LuctusSkillLoadPly(ply)
    LUCTUS_SKILLS_PLY[ply] = {}
    for name,tab in pairs(LUCTUS_SKILLS) do
        LUCTUS_SKILLS_PLY[ply][name] = 0
    end
    local skills = sql.QueryValue("SELECT skills FROM luctus_skills WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if skills == false then
        error(sql.LastError())
    end
    if skills then
        LUCTUS_SKILLS_PLY[ply] = util.JSONToTable(skills)
    end
end

hook.Add("PlayerInitialSpawn","luctus_skills",function(ply)
    LuctusSkillLoadPly(ply)
end)

hook.Add("PlayerDisconnected","luctus_skills",function(ply)
    LUCTUS_SKILLS_PLY[ply] = nil
end)

net.Receive("luctus_skills",function(len,ply)
    local numberOfSkills = net.ReadUInt(8)
    if numberOfSkills > 100 then return end
    local tab = {}
    for i=1,numberOfSkills do
        tab[net.ReadString()] = net.ReadUInt(8)
    end
    --Check input
    local levelTotal = 0
    local plyLevel = ply:getLevel()
    local skills = LUCTUS_SKILLS
    for name,level in pairs(tab) do
        local skill = skills[name]
        if not skill then return end
        if level > 0 and plyLevel < skill.req then return end
        if level > skill.max then return end
        levelTotal = levelTotal + (skill.cost*level)
    end
    if levelTotal > plyLevel then return end
    --Save
    local res = sql.Query("INSERT INTO luctus_skills(steamid,skills) VALUES("..sql.SQLStr(ply:SteamID())..","..sql.SQLStr(util.TableToJSON(tab))..")")
    if res == false then error(sql.LastError()) end
    --Set
    for skill,level in pairs(tab) do
        LUCTUS_SKILLS_PLY[ply][skill] = level
    end
    DarkRP.notify(ply,0,5,"[skills] Successfully saved!")
    ply:PrintMessage(3,"[skills] Successfully saved!")
end)

hook.Add("EntityTakeDamage","luctus_skills",function(ply,dmginfo)
--hook.Add("ScalePlayerDamage","luctus_skills",function(ply,hitgroup,dmginfo)
    --Defender
    if ply:IsPlayer() then
        local skillTab = LUCTUS_SKILLS_PLY[ply]
        if dmginfo:IsFallDamage() then
            dmginfo:SubtractDamage(skillTab["Upperthighmuscles"])
        end
        if skillTab["Second Chance"] > 0 and ply:Health() == ply:GetMaxHealth() and dmginfo:GetDamage() >= ply:Health() then
            dmginfo:SetDamage(ply:Health()-1)
            return
        end
    end
    --Attacker
    local att = dmginfo:GetAttacker()
    if not IsValid(att) or not att:IsPlayer() then return end
    local wep = att:GetActiveWeapon()
    if not IsValid(wep) then return end
    
    local skillTab = LUCTUS_SKILLS_PLY[att]
    if wep:GetClass() == "weapon_fists" then
        dmginfo:AddDamage(skillTab["Boxer"])
    end
    if wep:GetClass() == "weapon_fists" then
        dmginfo:AddDamage(skillTab["BoxChampion"]*10)
    end
    if dmginfo:IsDamageType(DMG_BURN) then
        dmginfo:SubtractDamage(skillTab["Fireman"])
    end
    if att:Health() <= 5 then
        dmginfo:AddDamage(skillTab["Last Chance"]*10)
    end
end,-1)

hook.Add( "PlayerFootstep", "luctus_skills", function(ply)
    if LuctusSkillHas(ply,"SneakyShoes") then return true end
end)

timer.Create("luctus_skills_hp",60,0,function()
    for k,ply in pairs(player.GetHumans()) do
        if LuctusSkillHas(ply,"Patience") then
            ply:SetHealth(math.min(ply:Health()+LUCTUS_SKILLS_PLY[ply]["Patience"],ply:GetMaxHealth()))
        end
    end
end)

print("[luctus_skills] sv loaded")
