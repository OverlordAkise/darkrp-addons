--Luctus MultiServerChat
--Made by OverlordAkise

hook.Add("PlayerSay","luctus_multiserverchat",function(ply,text,team)
    if string.StartWith(text,"/rfunk ") then
        ggwsocket:write("RFUNK "..ply:Nick()..": "..string.Replace(text,"/rfunk ",""))
        return ""
    end
end)

print("[luctus_msc] loaded sv send")
