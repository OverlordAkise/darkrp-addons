AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()

	self:SetModel( "models/mossman.mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal()
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE || CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()


	self.items = {}
	self.Delay = CurTime()

	self:SetShopName("No Name")
end

function ENT:AcceptInput(_input, ac, caller, usetype)
	if _input == "Use" then
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

			if table.HasValue(self.jobs, team.GetName(ac:Team())) or table.HasValue(self.jobs, ac:SteamID()) then 
				net.Start("KS_OpenShop")
					net.WriteTable(self.items)
					net.WriteEntity(Entity(self:EntIndex()))
					net.WriteTable(self.jobs or {})
					net.WriteBool(true)
				net.Send(ac)
			else
				if KShop.isAdmin(ac) then
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
end


