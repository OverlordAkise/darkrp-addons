--Luctus Ingame Config
--Made by OverlordAkise

util.AddNetworkString("luctus_ingame_config")

hook.Add("PlayerSay","luctus_ingame_config",function(ply,text,team)
    if ply:IsAdmin() and text == LUCTUS_INGAME_CONFIG_CMD_SV then
        net.Start("luctus_ingame_config")
            net.WriteTable(LuctusIngameConfigGetAll())
        net.Send(ply)
    end
end)

net.Receive("luctus_ingame_config",function(len,ply)
    if not ply:IsAdmin() then return end
    local variable = net.ReadString()
    local value = net.ReadString()
    LuctusIngameConfigChange(variable,value,ply)
end)

print("[luctus_config] sv loaded")
