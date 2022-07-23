--Luctus Levelsystem
--Made by OverlordAkise

function levelReqExp(lvl)
    lvl = tonumber(lvl)
    return (5+(lvl*5))
end

local plymeta = FindMetaTable("Player")

function plymeta:hasLevel(level)
    if not tonumber(level) then return end
    return tonumber(self:getDarkRPVar("level")) >= tonumber(level)
end

function plymeta:getLevel()
    return self:getDarkRPVar("level")
end

function plymeta:getXP()
    return self:getDarkRPVar("xp")
end

hook.Add("postLoadCustomDarkRPItems","luctus_levelsystem_register",function()
    DarkRP.registerDarkRPVar("xp", net.WriteDouble, net.ReadDouble)
    DarkRP.registerDarkRPVar("level", net.WriteDouble, net.ReadDouble)
end)

print("[luctus_levelsystem] SH file loaded!")
