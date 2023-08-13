--Luctus Jobranks
--Made by OverlordAkise

hook.Add("loadCustomDarkRPItems", "luctus_nick_overwrite", function()
    local PLAYER = FindMetaTable("Player")
    PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name
    PLAYER.jobrankOldName = PLAYER.Name
    function PLAYER:Name()
        if not self:IsValid() then DarkRP.error("Attempt to call Name/Nick/GetName on a non-existing player!", SERVER and 1 or 2) end
        local Nick = self:jobrankOldName()
        if self:GetNWString("l_nametag","") ~= "" then
            Nick = self:GetNWString("l_nametag","") .. " " .. Nick
        end

        return Nick
    end
    PLAYER.GetName = PLAYER.Name
    PLAYER.Nick = PLAYER.Name
end)

if CLIENT then
    hook.Add("LuctusLogAddCategory","luctus_jobranks",function()
        LuctusLogAddCategory("Jobranks")
    end)
end

print("[luctus_jobranks] sh loaded!")
