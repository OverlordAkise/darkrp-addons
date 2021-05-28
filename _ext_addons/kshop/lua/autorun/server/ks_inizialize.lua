
function KShop:Init()
	local path = "kiwontasshopsystem"
	if not file.Exists(path, "DATA") then
		file.CreateDir(path)
		self:Message('Datapath created!', 3)
	end
	timer.Simple(2, function()
		self:SpawnShops()
	end)
	self:Message('Successfully initialized!', 3)
end
hook.Add("InitPostEntity", "KS_Init", timer.Simple(5, function() KShop:Init() end))