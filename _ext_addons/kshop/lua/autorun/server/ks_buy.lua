function KShop:BuyItem(ply, data, shop)
	if ply.kshopwait != nil then
		DarkRP.notify(ply, 1, 5, "You need to wait 2 seconds.")
		return
	end
  if not IsValid(shop) then return end
  if shop:GetClass() ~= "ks_npc" and shop:GetClass() ~= "ks_shop" then return end
  if shop:GetPos():DistToSqr(ply:GetPos()) > 500*500 then return end
  --Luctus/OverlordAkise was here fixing exploits
  --Only buy it if the item exists in the (shop-)entities shop
  --Do not take user input (data), use shop.item's item instead
  local validItem = false
  for k,v in pairs(shop.items) do
    if v.name == data.name then
      data = v
      validItem = true
      break
    end
  end
  if not validItem then 
    DarkRP.notify(ply,1,5,"Item with such a name not found!")
    return 
  end
  
	ply.kshopwait = false
	timer.Simple(2, function() if IsValid(ply) then ply.kshopwait = nil end end)
	if not ply:canAfford(data.price) then
		--if !data.price == 0 then
			DarkRP.notify(ply, 1, 5, "You can't afford "..DarkRP.formatMoney(data.price).."!")
			return
		--end
	end
	local typ = data.typ
	if data.typ == "weapon" then
		if !ply:HasWeapon(data.item) then
			ply:Give(data.item)
			ply:addMoney(-data.price)
			ply:SelectWeapon(data.item)
			DarkRP.notify(ply, 0, 5, "You bought a "..data.name.." for "..DarkRP.formatMoney(data.price)..".")
		else
			DarkRP.notify(ply, 1, 5, "You already have a "..data.name..".")
		end
	elseif data.typ == "entity" then
		if not data.item then return end
		local ent = ents.Create(data.item)
		ent:SetPos(ply:GetPos())
		ent:Spawn()
		ent:Activate()
		ply:addMoney(-data.price)
		DarkRP.notify(ply, 0, 5, "You bought a "..data.name.." for "..DarkRP.formatMoney(data.price)..".")
	elseif data.typ == "hp" then
		local max = ply:GetMaxHealth()
		local hp = ply:Health()
		if hp == max then
			DarkRP.notify(ply, 1, 5, "You already have "..tostring(max).." hp.")
			return
		end
		if not data.hp then return end
		if hp + data.hp > max then
			ply:SetHealth(max)
			DarkRP.notify(ply, 0, 5, "You got "..tostring( math.abs( ((data.hp+hp)-100)-data.hp ) ).." hp.")
		else
			ply:SetHealth(hp+data.hp)
			DarkRP.notify(ply, 0, 5, "You got "..tostring(data.hp).." hp.")
		end
		ply:addMoney(-data.price)
	elseif typ == "armor" then
		local max = KShop.MaxArmor
		local armor = ply:Armor()
		if armor == max then
			DarkRP.notify(ply, 1, 5, "You already have "..tostring(max).." armor.")
			return
		end
		if not data.armor then return end
		if armor + data.armor > max then
			ply:SetArmor(max)
			DarkRP.notify(ply, 0, 5, "You got "..tostring( math.abs( ((data.armor+armor)-100)-data.armor ) ).." armor.")
		else
			ply:SetArmor(armor+data.armor)
			DarkRP.notify(ply, 0, 5, "You got "..tostring(data.armor).." armor.")
		end
		ply:addMoney(-data.price)		
	end
end
net.Receive("KS_BuyItem", function(_, ply)
	local data = net.ReadTable()
	if !data then return end
  local shop = net.ReadEntity()
	KShop:BuyItem(ply,data,shop)
end)