include("shared.lua")

ENT.TopText = "Police\nConfiscation Box"
ENT.BotText = "Drop items via\nyour GravGun\nhere"
local color_white = Color(255,255,255,255)

function ENT:Draw()
    self:DrawModel()

    if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 400*400 then return end
    local pos = self:GetPos() + (self:GetAngles():Forward()*-20) + (self:GetAngles():Up() * 24) + (self:GetAngles():Right() *15)
    local ang = self:GetAngles()
    local back = Color( 0, 0, 0, 200 )
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(),73)
    cam.Start3D2D(pos, ang, 0.4)
        surface.SetDrawColor( 0, 0, 0, 150 )
        surface.DrawRect( -20, -13, 115, 59 )
        draw.DrawText(self.TopText, "TargetID", 37, 0, color_white,TEXT_ALIGN_CENTER)
    cam.End3D2D()

    ang:RotateAroundAxis(ang:Forward(),-73)
    pos = pos + (self:GetAngles():Forward()*13) + (self:GetAngles():Up()*-20)
    cam.Start3D2D(pos, ang, 0.4)
        surface.SetDrawColor( 0, 0, 0, 150 )
        surface.DrawRect( -20, -13, 115, 59 )
        draw.DrawText(self.BotText, "ChatFont", 37, 0, color_white,TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
