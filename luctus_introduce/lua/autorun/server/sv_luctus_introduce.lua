--Luctus Introduce
--Made by OverlordAkise

util.AddNetworkString("luctus_introduce")

function LuctusIntroduceCD(ply)
    if not ply.introduceCD then ply.introduceCD=0 end
    if ply.introduceCD > CurTime() then return true end
    ply.introduceCD = CurTime()+1
end

if LUCTUS_INTRODUCE_USE_WHEEL then
    net.Receive("luctus_introduce",function(len,ply)
        if LuctusIntroduceCD(ply) then return end
        local target = net.ReadEntity()
        if not IsValid(target) or not target:IsPlayer() then return end
        LuctusIntroduceDo(ply,target)
    end)
else
    hook.Add("PlayerUse","luctus_introduce",function(ply,ent)
        if not ent:IsPlayer() then return end
        if LuctusIntroduceCD(ply) then return end
        LuctusIntroduceDo(ply,ent)
    end)
end

function LuctusIntroduceDo(ply,target)
    if ply:GetPos():Distance(target:GetPos()) > 256 then return end
    net.Start("luctus_introduce")
        net.WriteEntity(ply)
    net.Send(target)
    hook.Run("LuctusIntroduced",ply,target)
end

print("[luctus_introduce] sv loaded")
