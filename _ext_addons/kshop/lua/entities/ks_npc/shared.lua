ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.SetAutomaticFrameAdvance = true
ENT.AutomaticFrameAdvance = true

ENT.PrintName 			= "KShop NPC"
ENT.Author 				= "KiwontaTv"
ENT.Contact 			= "https://steamcommunity.com/id/KiwontaTv"
ENT.Purpose 			= ""
ENT.Instructions 		= ""
ENT.Category 			= "KShop" 
ENT.Spawnable 			= false
ENT.AdminSpawnable 		= false

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "ShopName")

	self:NetworkVar("Int", 0, "ShopID")
end