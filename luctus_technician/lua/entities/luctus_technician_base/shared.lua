AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Controlbox"
ENT.PrintName = "Controlbox"
ENT.Author = "OverlordAkise"
ENT.Category = "Technician Luctus"
ENT.Purpose = "Press E to repair!"
ENT.Instructions = "N/A"
ENT.Model = "models/props/de_nuke/NuclearControlBox.mdl"

ENT.Freeze = false
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.Hitpoints = 200

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Broken")
    if SERVER then
        self:SetBroken(false)
    end
end
