include("shared.lua")

local vector_cache = Vector(1,0,0)
local color_cache1 = Color( 255, 20, 20, 255 )
local color_cache2 = Color( 20, 255, 20, 255 )
local color_black = Color( 0, 0, 0, 255 )

function ENT:Draw()
    self:DrawModel()
    local lp = LocalPlayer()
    if self:GetPos():DistToSqr(lp:GetPos()) > 300*300 then return end
    if RPExtraTeams[lp:Team()].name ~= LUCTUS_TECHNICIAN_JOBNAME then return end
    local a = Angle(0,0,0)
    a:RotateAroundAxis(vector_cache,90)
    a.y = lp:GetAngles().y - 90
    local va,vb = self:GetModelBounds()
    local height = vb.z
    --if vb.z > height then height = vb.z end
    --self:BoundingRadius()
    cam.Start3D2D(self:GetPos() + Vector(0,0,10+height), a , 0.074)
    if self:GetBroken() then
        draw.SimpleTextOutlined("BROKEN","TechnicianText", 0, -40, color_cache1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1,color_black)
    else
        draw.SimpleTextOutlined("OK","TechnicianText", 0, -40, color_cache2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1,color_black)
    end
    cam.End3D2D()
end

function ENT:ShowSparks()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(1)
    effectdata:SetScale(1)
    effectdata:SetRadius(2)
    util.Effect("Sparks", effectdata)
end

function ENT:Think()
    if self:GetBroken() then
        self:ShowSparks()
    end
    self:SetNextClientThink( CurTime() + 0.5 )
    return true
end
