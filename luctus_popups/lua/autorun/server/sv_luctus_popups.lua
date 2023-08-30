--Luctus Popups
--Made by OverlordAkise

--if true then admins wont create popups if they use ulx asay
local disableAdminsCanCreate = false 

util.AddNetworkString("luctus_popup_open")
util.AddNetworkString("luctus_popup_claim")
util.AddNetworkString("luctus_popup_close")
util.AddNetworkString("luctus_popup_notify")

hook.Add("PlayerInitialSpawn", "luctus_popups", function(ply)
    ply.claimedCaseAdmin = nil
    ply.hasCaseOpen = false
end)

function LuctusPopupsHasAccess(ply)
    return ply:query("ulx seeasay")
end

function LuctusPopupGetAdmins()
    local plys = {}
    for k,v in pairs(player.GetHumans()) do
        if LuctusPopupsHasAccess(v) then
            table.insert(plys,v)
        end
    end
    return plys
end

local function luctusPopupUpdate(ply,text)
    net.Start("luctus_popup_open")
        net.WriteEntity(ply)
        net.WriteString(text)
        net.WriteEntity(ply.claimedCaseAdmin)
    net.Send(LuctusPopupGetAdmins())
end

local function luctusPopupNotify(ply,text)
    net.Start("luctus_popup_notify")
        net.WriteString(text)
    net.Send(ply)
end

function LuctusPopupCreate(ply,text)
    luctusPopupUpdate(ply,text)
    ply.hasCaseOpen = true
    LuctusPopupTimeoutCreate(ply)
    luctusPopupNotify(ply,"Your ticket has been created")
    hook.Run("LuctusPopupCreated",ply,text)
end

function LuctusPopupClaim(ply, admin)
    ply.claimedCaseAdmin = admin
    net.Start("luctus_popup_claim")
        net.WriteEntity(ply)
        net.WriteEntity(admin)
    net.Send(LuctusPopupGetAdmins())
    LuctusPopupTimeoutRemove(ply)
    luctusPopupNotify(ply,"Your ticket has been claimed by "..admin:Nick())
    hook.Run("LuctusPopupClaimed",ply,admin)
end

function LuctusPopupClose(ply,admin)
    ply.hasCaseOpen = false
    ply.claimedCaseAdmin = nil
    net.Start("luctus_popup_close")
        net.WriteString(ply:SteamID())
    net.Send(LuctusPopupGetAdmins())
    LuctusPopupTimeoutRemove(ply)
    luctusPopupNotify(ply,"Your ticket has been closed")
    hook.Run("LuctusPopupClosed",ply,admin) --admin can be nil
end

function LuctusPopupTimeoutCreate(ply)
    timer.Create("luctus_popup_"..ply:SteamID(), 120, 1, function()
        LuctusPopupClose(ply)
    end)
end

function LuctusPopupTimeoutRemove(ply)
    timer.Remove("luctus_popup_"..ply:SteamID())
end

hook.Add("ULibCommandCalled", "luctus_popups",function(ply, cmd, args)
    if not string.find(cmd, "ulx asay") or not ply:query("ulx asay") or table.Count(args) < 1 then return end
    if disableAdminsCanCreate and LuctusPopupsHasAccess(ply) then return end
    if not ply.hasCaseOpen then
        LuctusPopupCreate(ply, table.concat(args," "))
    else
        luctusPopupUpdate(ply, table.concat(args," "))
    end
end)

hook.Add("PlayerDisconnected", "luctus_popups",function(ply)
    LuctusPopupClose(ply)
    if LuctusPopupsHasAccess(ply) then
        for k,v in pairs(player.GetHumans()) do
            if v.claimedCaseAdmin and v.claimedCaseAdmin == ply then
                LuctusPopupClose(v,ply)
            end
        end
    end
end)

net.Receive("luctus_popup_claim", function(len, ply)
    local rPly = net.ReadEntity()
    if LuctusPopupsHasAccess(ply) and not rPly.claimedCaseAdmin then
        LuctusPopupClaim(rPly, ply)
    end
end)

net.Receive("luctus_popup_close", function(len, ply)
    local rPly = net.ReadEntity()
    if LuctusPopupsHasAccess(ply) and rPly.claimedCaseAdmin and rPly.claimedCaseAdmin == ply then
        LuctusPopupClose(rPly,ply)
    end
end)

print("[luctus_popups] sv loaded")
