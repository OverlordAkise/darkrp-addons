function KShop:SpawnShops()
	for k, v in pairs(ents.GetAll()) do
		if v:GetClass() == "ks_shop" or v:GetClass() == "ks_npc" then
			v:Remove()
		end
	end
	local path = "kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt"
	local shops = file.Read(path)
	if shops != nil then
		shops = util.JSONToTable(shops)
		for k, v in pairs(shops) do
			local s = nil
			if tobool(v["npc"]) == true then
				s = ents.Create("ks_npc")
			else
				s = ents.Create("ks_shop")
			end
			s:SetPos(v["pos"])
			s:SetPos(s:GetPos())
			s:Spawn()
		    s:SetShopID(k)
		    s:SetAngles(v["ang"])
		    s:SetModel(v["model"])
		    s.items = v["items"]
		   	s.jobs = v["jobs"]
		   	s:SetNWInt("shop_x_offset", v["x_offset"] or 0)
		   	s:SetNWInt("shop_y_offset", v["y_offset"] or 0)

		    if v["npc"] == true then
		    	--s:SetPos(v["pos"] - s:GetAngles():Up())
		    end

			local phy = s:GetPhysicsObject();
			if (phy && IsValid( phy )) then
			    phy:Sleep()
			    phy:SetMass(10)
			    phy:EnableMotion(false)
			end


		    s:SetShopName(v["name"])
		end
	end
end

function KShop:AddShop(trace, ply)
	local s = ents.Create("KS_shop")
	s:SetPos(trace.HitPos)
	s:SetPos(s:GetPos() + s:GetUp() * 50)
	s:SetModel("models/props_interiors/VendingMachineSoda01a.mdl")
	s:Spawn()
    s:Activate()
    if self:GetAllShops() == "none" then
    	s:SetShopID(1)
    else
    	s:SetShopID(#self:GetAllShops()+1)
    end
    local _phys = s:GetPhysicsObject();
    if (_phys && IsValid( _phys )) then
        _phys:Sleep()
        _phys:SetMass(10)
        _phys:EnableMotion(false)
    end

    local _pos = s:GetPos()
    local _angles = s:GetAngles()

    self:Message("Creating a new shop...", 2)
    local newshop = {
    ["pos"] 	= _pos,
    ["ang"] 	= _angles,
    ["npc"] 	= false,
    ["model"]	= "models/props_interiors/VendingMachineSoda01a.mdl",
    ["items"] 	= {},
    ["jobs"]	= {},
    ["name"] 	= "No Name",
    ["x_offset"]= 0,
    ["y_offset"]= 0
	}

	local path = "kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt"

	if file.Exists(path, "DATA") then
		local shops = file.Read(path, "DATA")
		shops = util.JSONToTable(shops)
		if shops != nil then
			table.insert(shops, #shops + 1, newshop)
			local json = util.TableToJSON(shops)
			file.Write(path, json)
			self:Message("New Shop successfully created!", 3)
		end
    else
        local shops = {}
        table.insert(shops, #shops + 1, newshop)
        local json = util.TableToJSON(shops)
        file.Write(path, json)
        self:Message("New Shop successfully created!", 3)   
	end

    s:Remove()
    self:SpawnShops()
end

function KShop:TeleportShop(data, ply)
	if not data then return end
	local pos = ply:GetEyeTrace().HitPos
	pos = pos + ply:GetAngles():Up()*50
	local id = data.id
	local dat = KShop:GetAllShops()
	dat[id]["pos"] = pos
	KShop:SaveShop(dat)
	KShop:SpawnShops()
end
net.Receive("KS_TeleportShop", function(_, ply)
	if KShop.isAdmin(ply) then
		KShop:TeleportShop(net.ReadTable(), ply)
	end
end)

function KShop:DeleteShop(data)
	if not data then return end
	local id = data.id
	local dat = KShop:GetAllShops()
	dat[id] = nil
	KShop:SaveShop(dat)
	KShop:SpawnShops()
end
net.Receive("KS_DeleteShop", function(_, ply)
	if KShop.isAdmin(ply) then
		KShop:DeleteShop(net.ReadTable())
	end
end)

function KShop:DeleteAllShops()
	local path = "kiwontasshopsystem"
	if not file.Exists(path, "DATA") then
		file.CreateDir(path)
	end
	file.Write(path.."/shops_"..game.GetMap().."_JSON.txt", "[]")
	file.Delete(path.."/shops_"..game.GetMap().."_JSON.txt")
	KShop:SpawnShops()
end
net.Receive("KS_DeleteAllShops", function(_, ply)
	if KShop.isAdmin(ply) then
		KShop:DeleteAllShops()
	end
end)

net.Receive("KS_Respawn_All_Shops", function(_, ply)
	if KShop.isAdmin(ply) then
		KShop:SpawnShops()
	end
end)

function KShop:EditShop(ply, data)
	if !data.name or !data.ent or !data.model then
		self:Message("An error occured while editing a shop.", 1)
		return
	end
	local id = nil
	local ent = data.ent
	local items = data.items
	local jobs = data.jobs
	local model = data.model
	local name = data.name 
	local npc = data.npc or false
	local x_o = data.x_offset
	local y_o = data.y_offset
	if IsValid(data.ent) then
		id = data.ent:GetShopID()
	end
	if id != nil and IsValid(ent) then
		local data = self:GetAllShops()
		local shop = {
		    ["pos"] 	= ent:GetPos(),
		    ["ang"] 	= ent:GetAngles(),
		    ["npc"] 	= npc,
		    ["model"]	= model,
		    ["items"] 	= items,
		    ["jobs"]	= jobs,
		    ["name"] 	= name,
		    ["x_offset"]= x_o,
		    ["y_offset"]= y_o
		}
		local snp, nnp = data[id]["npc"], shop["npc"]
		data[id] = shop
		self:SaveShop(data)
		ent.items = shop.items
		ent.jobs = shop.jobs
		ent:SetModel(shop.model)
		ent:SetShopName(shop.name)
		ent.items = items

		ent:SetNWInt("shop_x_offset", x_o or 0)
		ent:SetNWInt("shop_y_offset", y_o or 0)

		ent:SetModel(shop["model"])
		ent:Activate()

		local vPoint = ent:GetPos()
		local effectdata = EffectData()
		effectdata:SetOrigin( vPoint )
		util.Effect( "ManhackSparks", effectdata )

		local _phys = ent:GetPhysicsObject();
		if (_phys && IsValid( _phys )) then
		    _phys:Sleep()
		    _phys:SetMass(10)
		    _phys:EnableMotion(false)
	 	end

		if snp == true and nnp == false then
			self:SpawnShops()
		end
		if snp == false and nnp == true then
			self:SpawnShops()
		end
	end
end

--Luctus/OverlordAkise was here
--This admin-only function was missing an isAdmin check
net.Receive("KS_RetrieveEdits", function(_, ply)
  if KShop.isAdmin(ply) then
		KShop:EditShop(ply, net.ReadTable())
	end
end)

function KShop:CopyShop(data, ply)
	if not data then return end
	data = data.data
	local trace = ply:GetEyeTrace()
	local s
	if data["npc"] == true then
		s = ents.Create("ks_npc")
	else
		s = ents.Create("KS_shop")
	end
	s:SetPos(trace.HitPos)
	s:SetPos(s:GetPos() + s:GetUp() * 50)
	s:SetModel(data["model"])
	s:Spawn()
    s:Activate()
    if self:GetAllShops() == "none" then
    	s:SetShopID(1)
    else
    	s:SetShopID(#self:GetAllShops()+1)
    end

    local _pos = s:GetPos()
    local _angles = s:GetAngles()

    self:Message("Copy a shop...", 2)
    local newshop = {
    ["pos"] 	= _pos,
    ["ang"] 	= _angles,
    ["npc"] 	= data["npc"],
    ["model"]	= data["model"],
    ["items"] 	= data["items"],
    ["jobs"]	= data["jobs"],
    ["name"] 	= data["name"],
	["x_offset"]= data["x_offset"] or 0,
	["y_offset"]= data["y_offset"] or 0
	}

	local path = "kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt"

	if file.Exists(path, "DATA") then
		local shops = file.Read(path, "DATA")
		shops = util.JSONToTable(shops)
		if shops != nil then
			table.insert(shops, #shops + 1, newshop)
			local json = util.TableToJSON(shops)
			file.Write(path, json)
			self:Message("New Shop successfully created!", 3)
		end
    else
        local shops = {}
        table.insert(shops, #shops + 1, newshop)
        local json = util.TableToJSON(shops)
        file.Write(path, json)
        self:Message("New Shop successfully created!", 3)   
	end

    s:Remove()
    self:SpawnShops()
end
net.Receive("KS_Copyshop_return", function(_, ply)
	if KShop.isAdmin(ply) then
		KShop:CopyShop(net.ReadTable(), ply)
	end
end)

function KShop:SaveShop(data)
	file.Write("kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt", util.TableToJSON(data, true))
end

function KShop:GetAllShops()
	local data = file.Read("kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt")
	if data != nil then
		return util.JSONToTable(data)
	else
		return "none"
	end
end

net.Receive("KS_RequestEdit", function(_, ply)
	net.Start("KS_EditShop")
		net.WriteTable(KShop:GetAllShops())
		net.WriteEntity(net.ReadEntity())
		net.WriteTable(net.ReadTable())
		net.WriteTable(net.ReadTable())
	net.Send(ply)
end)

function KShop:RemoveShop(_e, _id, _p)
    local path = "kiwontasshopsystem/shops_"..game.GetMap().."_JSON.txt"
    local shops = file.Read(path, "DATA")
    shops = util.JSONToTable(shops)
    if shops != nil then
        table.remove(shops, _id)
        local json = util.TableToJSON(shops)
        file.Write(path, json)
        self:Message("Shop with id ".._id.." has been removed!", 4)
        if IsValid(_p) then
            local rm = KShop.Messages.ShopRemoved 
            rm = string.Replace(rm,"%id", "#".._e.id)
            _p:SendLua([[chat.AddText(Color(50,255,50), "[Kiwonta's Shopsystem] ", Color(255,255,255), "]]..rm..[[")]])
        end
        self:SpawnShops()
        _e:Remove()
    end
end

function KShop:Playersay(ply, text)
    if (string.lower(text) == "/"..KShop.AddShopCommand) or (string.lower(text) == "!"..KShop.AddShopCommand) then
        if not ply:IsSuperAdmin() then return end
        self:AddShop(ply:GetEyeTrace(), ply)
        return ""
    end

    if (string.lower(text) == "/"..KShop.CopyShopCommand) or (string.lower(text) == "!"..KShop.CopyShopCommand) then
        if not ply:IsSuperAdmin() then return end
        net.Start("KS_Copyshop")
        	net.WriteTable(KShop:GetAllShops())
        net.Send(ply)
        return ""
    end

    if (string.lower(text) == "/"..KShop.AdminShopCommand) or (string.lower(text) == "!"..KShop.AdminShopCommand) then
        if not ply:IsSuperAdmin() then return end
        local _sData = KShop:GetAllShops()
        if type(_sData) == "string" then 
        	ply:ChatPrint("There are no shops to administrate!")
        	return
        end
        net.Start("KS_AdminFunctions")
        	net.WriteTable(_sData)
        net.Send(ply)
        return ""
    end
end
hook.Add("PlayerSay", "KS_Playersayhook", function(ply, text, public) KShop:Playersay(ply, text) end) -- Unique enough gmod? :^)
