--Luctus MultiServerChat
--Made by OverlordAkise

require("gwsockets")

--Start of configurable area

ggwsocket = GWSockets.createWebSocket("ws://localhost:9091/ws")

function ggwsocket:onMessage(txt)
    print("[luctus_msc] RECEIVING:",txt)
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
    print("[luctus_msc] Error: ", txt)
end

function ggwsocket:onConnected()
    print("[luctus_msc] Connected to echo server")
    ggwsocket_isconnected = true
end

function ggwsocket:onDisconnected()
    print("[luctus_msc] WebSocket disconnected!! Will try to reconnect...")
    ggwsocket_isconnected = false
end

ggwsocket:open()

timer.Create("luctus_msc_autoreconnect",60,0,function()
    if not ggwsocket_isconnected then
        print("[luctus_msc] WebSocket seems disconnected, trying to reconnect...")
        ggwsocket:open()
    end
end)

print("[luctus_msc] loaded sv recv")
