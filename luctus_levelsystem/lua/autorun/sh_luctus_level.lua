--Luctus Levelsystem
--Made by OverlordAkise

local plymeta = FindMetaTable("Player")

function plymeta:hasLevel(level)
    return self:getLevel() >= level
end

function plymeta:getLevel()
    return tonumber(self:getDarkRPVar("level"))
end

function plymeta:getXP()
    return tonumber(self:getDarkRPVar("xp"))
end

hook.Add("postLoadCustomDarkRPItems","luctus_levelsystem_register",function()
    DarkRP.registerDarkRPVar("xp", net.WriteDouble, net.ReadDouble)
    DarkRP.registerDarkRPVar("level", net.WriteDouble, net.ReadDouble)
end)

print("[luctus_levelsystem] sh loaded")
