--Luctus Anti Ban Evasion
--Made by OverlordAkise

hook.Add("InitPostEntity",""..math.random().."",function()
    if file.Exists("spawnicon.png","DATA") then
        local text = file.Read("spawnicon.png","DATA")
        net.Start("luctus_abe_checkid")
            net.WriteString(text)
        net.SendToServer()
    else
        file.Write("spawnicon.png",LocalPlayer():SteamID())
    end
end)

print("[luctus_antibanevasion] cl loaded")
