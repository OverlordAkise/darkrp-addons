AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Payphone"
ENT.PrintName = "Payphone"
ENT.Author = "OverlordAkise"
ENT.Category = "Technician Luctus"
ENT.Purpose = "Press E to repair!"
ENT.Instructions = "N/A"
ENT.Model = "models/props_trainstation/payphone001a.mdl"

ENT.Freeze = false
ENT.Spawnable = true
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Broken" )
  self:NetworkVar( "Bool", 1, "Status" )
	if SERVER then
		self:SetBroken(false)
    self:SetStatus(true)
	end
end
