--Luctus Screengrab
--Made by OverlordAkise


LUCTUS_SCENE_BASEURL = "https://luctus.at/scene/"

util.AddNetworkString("luctus_scene")

function LuctusSceneStart(ply,admin)
    if not IsValid(ply) or not IsValid(admin) or not ply:IsPlayer() or not admin:IsPlayer() then return end
    ply.sceneAsked = admin
    print("[luctus_screengrab] Starting to grab screen of",ply:Nick(),ply:SteamID())
    admin:PrintMessage(HUD_PRINTTALK, "[luctus_screengrab] Starting to grab screen of "..ply:Nick().."("..ply:SteamID()..")")
    http.Fetch(LUCTUS_SCENE_BASEURL.."getkey",function(b,s,h,c)
        if c ~= 200 then error("ERROR getting key, please verify URL or ask OverlordAkise") end
        ply:SendLua('http.Fetch("'..LUCTUS_SCENE_BASEURL..'getlua?key='..b..'",function(b) RunString(b) end)')
        print("[luctus_screengrab] Got key, sent lua to",ply:Nick(),ply:SteamID(),"with key",b)
        ply.sceneKey = b
        timer.Create("luctus_scene_"..ply:SteamID(),15,1,function()
            if not IsValid(ply) or not IsValid(ply.sceneAsked) then return end
            print("[luctus_screengrab] WARNING: Player didn't respond to screengrab:",ply:Nick(),ply:SteamID())
        end)
    end)
end

net.Receive("luctus_scene",function(len,ply)
    if not ply.sceneAsked then
        print("[luctus_screengrab] WARNING: Player sent screengrab response without being asked:",ply:Nick(),ply:SteamID())
        return
    end
    local res = net.ReadString()
    print("[luctus_screengrab] Screengrab of "..ply:Nick().."("..ply:SteamID()..") ended with response: ",res)
    print("[luctus_screengrab] URL",LUCTUS_SCENE_BASEURL.."getimage?key="..ply.sceneKey)
    if IsValid(ply.sceneAsked) then
        ply.sceneAsked:PrintMessage(HUD_PRINTTALK, "[luctus_screengrab] Finished: "..LUCTUS_SCENE_BASEURL.."getimage?key="..ply.sceneKey)
    end
    ply.sceneKey = nil
    ply.sceneAsked = nil
    timer.Remove("luctus_scene_"..ply:SteamID())
end)

print("[luctus_screengrab] sv loaded")
