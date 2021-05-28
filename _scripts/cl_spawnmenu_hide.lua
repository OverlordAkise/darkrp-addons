--Luctus No-Spawn-and-Context-Menu
--Made by OverlordAkise

--This hides the Spawnmenu (default Q) and the Contextmenu (default C)
--Only players with the following rank (usergroup) are allowed to open it:

local allowedRanks = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
}

hook.Add("ContextMenuOpen", "luctus_hide_spawnmenu", function()
	if not allowedRanks[LocalPlayer():GetUserGroup()] then
		return false
	end
end)

hook.Add("SpawnMenuOpen", "luctus_hide_spawnmenu", function()
	if not allowedRanks[LocalPlayer():GetUserGroup()] then
		return false
	end
end)
