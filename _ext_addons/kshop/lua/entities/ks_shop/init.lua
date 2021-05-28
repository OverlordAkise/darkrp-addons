AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetTrigger()
 
	local _phys = self:GetPhysicsObject();
	if( _phys && IsValid( _phys ) ) then
		_phys:Sleep();
		_phys:SetMass( 10 );
		_phys:EnableMotion( false );
	end

	self:SetShopName("No Name")

	self.items = {}
	self.Delay = CurTime()

end
 
function ENT:Use( ac, ply )
	if self.Delay < CurTime() then self.Delay = CurTime() + 1
		if table.IsEmpty(self.jobs) then
			net.Start("KS_OpenShop")
				net.WriteTable(self.items)
				net.WriteEntity(Entity(self:EntIndex()))
				net.WriteTable(self.jobs or {})
				net.WriteBool(true)
			net.Send(ac)
			return
		end

		if table.HasValue(self.jobs, team.GetName(ac:Team())) or table.HasValue(self.jobs, ply:SteamID()) then 
			net.Start("KS_OpenShop")
				net.WriteTable(self.items)
				net.WriteEntity(Entity(self:EntIndex()))
				net.WriteTable(self.jobs or {})
				net.WriteBool(true)
			net.Send(ac)
		else
			if KShop.isAdmin(ac) then
				print("sssss")
				net.Start("KS_OpenShop")
					net.WriteTable(self.items)
					net.WriteEntity(Entity(self:EntIndex()))
					net.WriteTable(self.jobs or {})
					net.WriteBool(false)
				net.Send(ac)
			end
			ac:ChatPrint("No Access to use the shop!")
		end
	end
end

function ENT:OnTakeDamage(damage)

end

function ENT:Think()

end

function ENT:OnRemove()

end
