--Luctus RP-Score
--Made by OverlordAkise

local plymeta = FindMetaTable("Player")

function plymeta:hasRPScore(s)
    return self:getRPScore() >= s
end

function plymeta:getRPScore()
    return tonumber(self:getDarkRPVar("rpscore"))
end

hook.Add("postLoadCustomDarkRPItems","luctus_rpscore",function()
    DarkRP.registerDarkRPVar("rpscore", net.WriteDouble, net.ReadDouble)
end)

print("[luctus_rpscore] sh loaded")
