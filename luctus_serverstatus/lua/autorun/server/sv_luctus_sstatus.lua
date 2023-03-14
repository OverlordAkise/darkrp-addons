--Luctus Serverstatus
--Made by OverlordAkise

util.AddNetworkString("luctus_serverstatus")
util.AddNetworkString("luctus_serverstatus_fpssync")
util.AddNetworkString("luctus_serverstatus_connecttime")

LUCTUS_SERVERCHECKS = {
    ["Entity Count"] = {
        function()
            return (#ents.GetAll() <= 6000), #ents.GetAll().." / 8176"
        end
    },
    ["Server Uptime"] = {
        function()
            return (CurTime() < 86400), "Current uptime: "..(CurTime()/60).."min"
        end
    },
    ["Current Tickrate"] = {
        function()
            local shouldtick = math.floor(1/engine.TickInterval())
            local tickrate = math.floor(LuctusCurTickrate)+1
            return (tickrate >= shouldtick), tickrate.." / "..shouldtick
        end
    },
    ["Player FPS"] = {
        function()
            local all = 100
            local count = 1
            print("[DEBUG]","FPS calc:")
            PrintTable(LuctusPlayerStats)
            
            for k,v in pairs(LuctusPlayerStats) do
                all = all + v.fps
                count = count + 1
            end
            print("[DEBUG]",all,"/",count,"=",math.Round(all/count))
            local avg = math.Round(all/count)
            if avg == 0 then
                return true, "Average N/A ( >= 100)"
            end
            return (avg >= 100), "Average "..avg.." ( >= 100)"
        end
    },
    ["Player Ping"] = {
        function()
            local all = 100
            local count = 1
            for k,v in pairs(LuctusPlayerStats) do
                count = count + 1
                all = all + v.ping
            end
            local avg = math.Round(all/count)
            return (avg <= 100), "Average "..avg.." ( <= 100)"
        end
    },
    ["Player Connect time"] = {
        function()
            local count = 0
            local all = 0
            for k,v in pairs(LuctusConnectTimes) do
                count = count + 1
                all = all + v
            end
            if all == 0 then return true, "Average N/A ( < 300s)" end
            local avg = math.Round(all/count)
            return (avg < 300), "Average "..avg.." ( < 300s)"
        end
    },
    ["Players cancel join"] = {
        function()
            local connected = table.Count(LuctusConnectTimes)
            local canceled = table.Count(LuctusCanceledConnects)
            return (canceled <= connected), "Canceled/Connected: "..canceled.." / "..connected
        end
    },
}


net.Receive("luctus_serverstatus",function(len,ply)
    if not ply:IsAdmin() then return end
    local checktable = util.Compress(util.TableToJSON(LuctusDoServerChecks()))
    net.Start("luctus_serverstatus")
        net.WriteInt(#checktable,18)
        net.WriteData(checktable,#checktable)
    net.Send(ply)
end)

function LuctusDoServerChecks()
    local returnTable = {}
    for k,v in pairs(LUCTUS_SERVERCHECKS) do
        returnTable[k] = {v[1]()}
    end
    return returnTable
end
concommand.Add("luctus_serverstatus",function()
    PrintTable(LuctusDoServerChecks())
end)

--Tickrates
local lasttick = SysTime()
LuctusCurTickrate = 0
local ticktimes = 0
local tickcount = 0
hook.Add("Tick", "luctus_serverstatus_tickratecheck", function()
    tickcount = tickcount + 1
    ticktimes = ticktimes + SysTime() - lasttick
    lasttick = SysTime()
    if tickcount >= 100 then
        LuctusCurTickrate = 1/(ticktimes/tickcount)
        tickcount = 0
        ticktimes = 0
    end
end)

--Player stats (FPS/Ping)
LuctusPlayerStats = {}
net.Receive("luctus_serverstatus_fpssync",function(len,ply)
    LuctusPlayerStats[ply:SteamID()] = {
        ["fps"] = net.ReadInt(16),
        ["ping"] = ply:Ping(),
        ["packetloss"] = ply:PacketLoss(),
    }
end)
hook.Add("PlayerDisconnected","luctus_serverstatus",function(ply)
    LuctusPlayerStats[ply:SteamID()] = nil
end)

--Player connect times
LuctusConnectPlayer = {}
LuctusConnectTimes = {}
LuctusCanceledConnects = {}
gameevent.Listen("player_connect")
hook.Add("player_connect", "luctus_serverstatus", function(data)
	LuctusConnectPlayer[data.networkid] = CurTime()
end)
net.Receive("luctus_serverstatus_connecttime",function(len,ply)
    local sid = ply:SteamID()
    if LuctusConnectPlayer[sid] then
        LuctusConnectTimes[sid] = CurTime() - LuctusConnectPlayer[sid]
        LuctusConnectPlayer[sid] = nil
    end
end)
hook.Add("PlayerDisconnected","luctus_serverstatus_cancel",function(ply)
    local sid = ply:SteamID()
    if LuctusConnectPlayer[sid] then
        LuctusCanceledConnects[sid] = CurTime() - LuctusConnectPlayer[sid]
        LuctusConnectPlayer[sid] = nil
    end
end)

print("[luctus_serverstatus] sv loaded")
