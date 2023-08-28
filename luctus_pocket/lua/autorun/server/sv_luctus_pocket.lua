--Luctus Pocket
--Made by OverlordAkise

util.AddNetworkString("luctus_pocket")

hook.Add("InitPostEntity","luctus_pocket",function()
    local res = sql.Query("CREATE TABLE IF NOT EXISTS luctus_pocket(steamid TEXT, id INT, stab TEXT)")
    if res==false then
        error(sql.LastError())
    end
end)

hook.Add("PlayerInitialSpawn","luctus_pocket",function(ply)
    ply.darkRPPocket = ply.darkRPPocket or {}
    local res = sql.Query("SELECT * FROM luctus_pocket WHERE steamid = "..sql.SQLStr(ply:SteamID()))
    if res==false then
        error(sql.LastError())
    end
    if res and res[1] then
        for k,v in pairs(res) do
            table.insert(ply.darkRPPocket, util.JSONToTable(v.stab))
        end
    end
end)

hook.Add("onPocketItemAdded","luctus_pocket",function(ply,ent,stab)
    local id = table.insert(ply.darkRPPocket,12)
    table.remove(ply.darkRPPocket)
    local res = sql.Query("INSERT INTO luctus_pocket(steamid,id,stab) VALUES("..sql.SQLStr(ply:SteamID())..","..id..","..sql.SQLStr(util.TableToJSON(stab))..")")
    if res==false then error(sql.LastError()) end
end)

hook.Add("onPocketItemDropped","luctus_pocket",function(ply,ent,id,item)
    local res = sql.Query("DELETE FROM luctus_pocket WHERE id="..id.." AND steamid="..sql.SQLStr(ply:SteamID()))
    if res==false then error(sql.LastError()) end
end)

net.Receive("luctus_pocket",function(len,ply)
    if ply.luctusPocketSynced then return end
    ply.luctusPocketSynced = true
    net.Start("DarkRP_Pocket")
        net.WriteTable(ply:getPocketItems())
    net.Send(ply)
end)

print("[luctus_pocket] sv loaded")
