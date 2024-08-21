local allowedRanks = {
    ["superadmin"] = true,
    ["admin"] = true,
}

hook.Add("SpawnMenuOpen", "luctus_blockmenutabs", function()
    if allowedRanks[LocalPlayer():GetUserGroup()] then return end
    for k, v in pairs( g_SpawnMenu.CreateMenu.Items ) do
        if not IsValid(v) then continue end 
        if (v.Tab:GetText() == language.GetPhrase("spawnmenu.category.npcs") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.entities") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.weapons") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.vehicles") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.postprocess") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.dupes") or
            v.Tab:GetText() == language.GetPhrase("spawnmenu.category.saves")) then
            g_SpawnMenu.CreateMenu:CloseTab( v.Tab, true )
            --removeOldTables()
        end
    end
end)
