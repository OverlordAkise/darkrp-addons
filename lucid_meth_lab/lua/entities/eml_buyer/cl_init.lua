include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Draw()
	self:DrawModel()
  if LocalPlayer():GetPos():Distance(self:GetPos()) < 550 then
      local a = Angle(0,0,0)
      a:RotateAroundAxis(Vector(1,0,0),90)
      a.y = LocalPlayer():GetAngles().y - 90
      cam.Start3D2D(self:GetPos() + Vector(0,0,80), a , 0.074)
          draw.RoundedBox(8,-225,-75,450,75 , Color(45,45,45,255))
          local tri = {{x = -25 , y = 0},{x = 25 , y = 0},{x = 0 , y = 25}}
          surface.SetDrawColor(Color(45,45,45,255))
          draw.NoTexture()
          surface.DrawPoly( tri )

          draw.SimpleText("Meth Buyer","Farmer_NPC_Font",0,-40,Color(255,255,255,255) , 1 , 1)
      cam.End3D2D()
  end
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:BuildBonePositions( NumBones, NumPhysBones )
end
 
function ENT:SetRagdollBones( bIn )
	self.m_bRagdollSetup = bIn
end

function ENT:DoRagdollBone( PhysBoneNum, BoneNum )
end