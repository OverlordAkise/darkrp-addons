--Luctus Camera
--Made by OverlordAkise

util.AddNetworkString("luctus_camera_pvs")

LUCTUS_CAMERA_ACTIVE = LUCTUS_CAMERA_ACTIVE or {}
LUCTUS_CAMERA_POS = LUCTUS_CAMERA_POS or {}

function LuctusCameraActivate(ply,status)
    LUCTUS_CAMERA_ACTIVE[ply] = status
end

--Or else you won't see players:
hook.Add("SetupPlayerVisibility","luctus_camera",function(ply)
    if not LUCTUS_CAMERA_ACTIVE[ply] then return end
    local pos = LUCTUS_CAMERA_POS[ply]
    if not pos then return end
    AddOriginToPVS(pos)
end)

function LuctusCameraSwitch(ply,num)
    local tab = LuctusCameraGetEnts(ply)
    if not ply.specIndex then ply.specIndex = 1 end
    ply.specIndex = (ply.specIndex+num)%(#tab+1)
    local ent = tab[ply.specIndex]
    ply.specEntity = ent
    if IsValid(ent) then
        LUCTUS_CAMERA_POS[ply] = ent:GetPos()
    else
        LUCTUS_CAMERA_POS[ply] = nil
    end
    
    
    net.Start("luctus_camera_pvs")
        if not IsValid(ent) then
            net.WriteBool(false)
        elseif ent:IsPlayer() then
            net.WriteBool(true)
            net.WriteEntity(ent)
        else
            net.WriteBool(true)
            net.WriteEntity(ent)
            local ang = ent:GetAngles()
            net.WriteVector(ent:GetPos()+ang:Forward()*7)
            net.WriteAngle(ang)
        end
    net.Send(ply)
end

local cacheRefresh = 0
local cache = {}
function LuctusCameraGetEnts(rply)
    if cacheRefresh > CurTime() then return cache end
    cacheRefresh = CurTime()+30
    local tab = {}
    if LUCTUS_CAMERA_BODYCAMS then
        for k,ply in ipairs(player.GetAll()) do
            if ply == rply then continue end
            if not LUCTUS_CAMERA_BODYCAM_JOBS[team.GetName(ply:Team())] then continue end
            table.insert(tab,ply)
        end
    end
    for k,ent in ipairs(ents.FindByClass("luctus_camera")) do
        table.insert(tab,ent)
    end
    --[[
    for k,ent in ipairs(ents.FindByModel("models/props_blackmesa/securitycamera.mdl")) do
        table.insert(tab,ent)
    end
    --]]
    cache = tab
    return tab
end

print("[luctus_camera] sv loaded")
