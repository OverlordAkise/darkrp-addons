--Luctus Watchlist
--Made by OverlordAkise

local color_red = Color(255,0,0)
local color_white = Color(255,255,255)
net.Receive("luctus_watchlist",function()
    local text = net.ReadString()
    chat.AddText(color_red,"[watchlist] ",color_white,text)
end)

print("[luctus_watchlist] cl loaded")
