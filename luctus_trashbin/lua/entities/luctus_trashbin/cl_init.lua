include("shared.lua")

local color_white = Color(255,255,255,255)
local color_bg = Color(45,45,45,255)
local extraHeight = Vector(0,0,40)
function ENT:Draw()
    self:DrawModel()

    if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 300*300 then return end
    local a = Angle(0,0,0)
    a:RotateAroundAxis(Vector(1,0,0),90)
    a.y = LocalPlayer():GetAngles().y - 90
    cam.Start3D2D(self:GetPos()+extraHeight, a , 0.074)
        draw.RoundedBox(8,-105,-75,210,75 , color_bg)
        draw.SimpleText("Trashbin","DermaLarge",0,-40,color_white,1,1)
    cam.End3D2D()
end
