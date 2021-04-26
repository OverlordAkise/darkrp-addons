ENT.Base = "base_ai"
ENT.Type = "ai"

ENT.PrintName = "Buyer"
ENT.Author = "EnnX49"
ENT.Contact = ""
ENT.Category	= "EML"

ENT.AutomaticFrameAdvance = true
   
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate( physobj )
end

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end 