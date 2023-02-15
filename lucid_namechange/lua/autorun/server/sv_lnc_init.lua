--Luctus Name Change
--Made by OverlordAkise

util.AddNetworkString("luctus_namechange")
util.AddNetworkString("luctus_namecheck")

hook.Add("onPlayerFirstJoined","luctus_namechange",function(ply, data)
    ply.luctusShouldNameChange = true
end)

net.Receive("luctus_namechange", function(len,ply)
    if IsValid(ply) and ply.luctusShouldNameChange then
        net.Start("luctus_namechange")
        net.Send(ply)
    end
end)

net.Receive("luctus_namecheck", function(len,ply)
    local fname = net.ReadString()
    local lname = net.ReadString()
    local b,m = hook.Run("CanChangeRPName",ply,fname.." "..lname)
    DarkRP.retrieveRPNames(fname.." "..lname,function(ans)
        if b == false then
            DarkRP.notify(ply,1,5,"Error: Name '"..m.."'")
        elseif ans == true then
            DarkRP.notify(ply,1,5,"Error: Name 'already taken'")
        elseif fname:match("%W") or lname:match("%W") then
            DarkRP.notify(ply,1,5,"Error: Name 'has illegal characters'")
        else
            net.Start("luctus_namecheck") 
                net.WriteString(fname.." "..lname)
            net.Send(ply)
        end
    end)
end)

print("[luctus_namechange] sv loaded")
