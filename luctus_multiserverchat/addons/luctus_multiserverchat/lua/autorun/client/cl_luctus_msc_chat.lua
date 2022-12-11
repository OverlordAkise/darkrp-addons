--Luctus MultiServerChat
--Made by OverlordAkise

net.Receive("luctus_msc_chat",function()
    local tag = net.ReadString()
    local msg = net.ReadString()
    chat.AddText(Color(0,195,165),tag,Color(255,255,255)," ",msg)
end)

print("[LUCTUS_MSC] cl_luctus_msc_chat.lua loaded")
