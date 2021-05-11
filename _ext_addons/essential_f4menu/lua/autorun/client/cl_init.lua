
local function precache(tbl)
  for v = 1, #tbl do
    if istable(tbl[v].model) then
      for i = 1, #tbl[v].model do
        if util.IsValidModel(tbl[v].model[i]) then
          util.PrecacheModel(tbl[v].model[i])
        end
      end
    else
      if util.IsValidModel(tbl[v].model) then
        util.PrecacheModel(tbl[v].model)
      end
    end
  end
end

hook.Add('InitPostEntity', 'edf_precaching', function()
  if not DarkRP then return end

	if #RPExtraTeams > 0 then
    precache(RPExtraTeams)
	end

	if #DarkRPEntities > 0 then
    precache(DarkRPEntities)
	end

	if #CustomShipments > 0 then
    precache(CustomShipments)
	end

	if #GAMEMODE.AmmoTypes > 0 then
    precache(GAMEMODE.AmmoTypes)
	end

	if #CustomVehicles > 0 then
    precache(CustomVehicles)
	end

	if not DarkRP.disabledDefaults.modules.hungermod then
    precache(FoodItems)
	end
end)

essentialDarkRPF4Menu = essentialDarkRPF4Menu or {}
essentialDarkRPF4Menu.settings = essentialDarkRPF4Menu.settings or {}
essentialDarkRPF4Menu.settings.languages = essentialDarkRPF4Menu.settings.languages or {}
essentialDarkRPF4Menu.settings.displayLanguage = "English"
essentialDarkRPF4Menu.settings.languages['English'] = {
	-- Menu tabs
	['Commands'] = 'Commands',
	['Jobs'] = 'Jobs',
	['Entities'] = 'Entities',
	['Shipments'] = 'Shipments',
	['Weapons'] = 'Weapons',
	['Ammo'] = 'Ammo',
	['Vehicles'] = 'Vehicles',
	['Food'] = 'Food',
	['Exit'] = 'Exit',
	-- Job/item description
	['TakeJob'] = 'Take Job',
	['CreateVote'] = 'Create Vote',
	['Purchase'] = 'Purchase',
	['Separate'] = 'Separate',
	['Shipment'] = 'Shipment',
	['Energy'] = 'Energy',
	['Cost'] = 'Cost',
	['Holds'] = 'Holds'
}

-- Console print
print("[essential_f4menu] Loaded essential F4 menu!")

