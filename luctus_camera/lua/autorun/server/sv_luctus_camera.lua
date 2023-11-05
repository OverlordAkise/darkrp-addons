--Luctus Camera
--Made by OverlordAkise

util.AddNetworkString("luctus_camera_pvs")

LUCTUS_CAMERA_ACTIVE = LUCTUS_CAMERA_ACTIVE or {}
LUCTUS_CAMERA_POS = LUCTUS_CAMERA_POS or {}

function LuctusCameraActivate(ply,status)
    LUCTUS_CAMERA_ACTIVE[ply] = status
end

net.Receive("luctus_camera_pvs",function(len,ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) then
        LUCTUS_CAMERA_POS[ply] = nil
        return
    end
    if not ply:GetActiveWeapon():GetClass() == "weapon_luctus_camera_tablet" then return end
    LUCTUS_CAMERA_POS[ply] = ent:GetPos()
end)
--Or else you won't see players:
hook.Add("SetupPlayerVisibility","luctus_camera",function(ply)
    if not LUCTUS_CAMERA_ACTIVE[ply] then return end
    local pos = LUCTUS_CAMERA_POS[ply]
    if not pos then return end
    AddOriginToPVS(pos)
end)

print("[luctus_camera] sv loaded")
