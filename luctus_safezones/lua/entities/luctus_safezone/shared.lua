--Luctus Safezones
--Made by OverlordAkise

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
    self:NetworkVar("String",0,"ZoneName")
    self:NetworkVar("Int",1,"ID")
    self:NetworkVar("Int",2,"EID")
end
