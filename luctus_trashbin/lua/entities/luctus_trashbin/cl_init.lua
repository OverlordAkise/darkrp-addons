include("shared.lua")

function ENT:Draw()
  self:DrawModel()

  if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 300*300) then return end
  local a = Angle(0,0,0)
  a:RotateAroundAxis(Vector(1,0,0),90)
  a.y = LocalPlayer():GetAngles().y - 90
  cam.Start3D2D(self:GetPos() + Vector(0,0,40), a , 0.074)
    draw.RoundedBox(8,-105,-75,210,75 , Color(45,45,45,255))
    local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
    surface.SetDrawColor(Color(45,45,45,255))
    draw.NoTexture()
    surface.DrawPoly( tri )

    draw.SimpleText("Trashbin","DermaLarge",0,-40,Color(255,255,255,255) , 1 , 1)
  cam.End3D2D()
end
