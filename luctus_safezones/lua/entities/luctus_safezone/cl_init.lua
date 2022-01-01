--Luctus Safezones
--Made by OverlordAkise

include("shared.lua")

function ENT:Initialize() end
 
function ENT:Think()
	local Min, Max = self:GetCollisionBounds()
	self:SetRenderBounds( Min, Max )
end
 
function ENT:Draw()
	local Min, Max = self:GetCollisionBounds()
	Min = self:GetPos() + Min
	Max = self:GetPos() + Max
  
	local Col, Width = Color( 0, 255, 0, 255 ), 1
	local B1, B2, B3, B4 = Vector(Min.x, Min.y, Min.z), Vector(Min.x, Max.y, Min.z), Vector(Max.x, Max.y, Min.z), Vector(Max.x, Min.y, Min.z)
	local T1, T2, T3, T4 = Vector(Min.x, Min.y, Max.z), Vector(Min.x, Max.y, Max.z), Vector(Max.x, Max.y, Max.z), Vector(Max.x, Min.y, Max.z)
	
  render.DrawLine( B1, B2, Col, true )
	render.DrawLine( B2, B3, Col, true )
	render.DrawLine( B3, B4, Col, true )
	render.DrawLine( B4, B1, Col, true )
  
	render.DrawLine( T1, T2, Col, true )
	render.DrawLine( T2, T3, Col, true )
	render.DrawLine( T3, T4, Col, true )
	render.DrawLine( T4, T1, Col, true )
  
	render.DrawLine( B1, T1, Col, true )
	render.DrawLine( B2, T2, Col, true )
	render.DrawLine( B3, T3, Col, true )
	render.DrawLine( B4, T4, Col, true )
end