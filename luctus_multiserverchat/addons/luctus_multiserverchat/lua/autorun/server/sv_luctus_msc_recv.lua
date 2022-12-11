--Luctus MultiServerChat
--Made by OverlordAkise

require("gwsockets")

--Start of configurable area

ggwsocket = GWSockets.createWebSocket("ws://localhost:9091/ws")

function ggwsocket:onMessage(txt)
    print("[LUCTUS_MSC] RECEIVING:",txt)
    local cmd = string.Split(txt," ")[1]
    if cmd == "RFUNK" then
        MSCSendMessage("[Langstreckenfunk]",string.Replace(txt,"RFUNK ",""))
    end
end

--End of config

ggwsocket_isconnected = true

util.AddNetworkString("luctus_msc_chat")
function MSCSendMessage(tag,msg)
    --PrintMessage(HUD_PRINTTALK, tag.." "..msg)
    net.Start("luctus_msc_chat")
        net.WriteString(tag)
        net.WriteString(msg)
    net.Broadcast()
end

function ggwsocket:onError(txt)
    print("[LUCTUS_SYNC] Error: ", txt)
end

function ggwsocket:onConnected()
    print("[LUCTUS_MSC] Connected to echo server")
    ggwsocket_isconnected = true
end

function ggwsocket:onDisconnected()
    print("[LUCTUS_MSC] WebSocket disconnected!! Will try to reconnect...")
    ggwsocket_isconnected = false
end

ggwsocket:open()

timer.Create("luctus_msc_autoreconnect",60,0,function()
    if not ggwsocket_isconnected then
        print("[LUCTUS_MSC] WebSocket seems disconnected, trying to reconnect...")
        ggwsocket:open()
    end
end)

print("[LUCTUS_MSC] sv_luctus_msc_recv.lua loaded")
