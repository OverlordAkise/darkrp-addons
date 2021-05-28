net.Receive("KS_Copyshop", function()
	local shops = net.ReadTable()
	if not shops then return end
	local main = vgui.Create("kshop_frame")
	main:SetSize(350, 150)
	main:Center()
	main:MakePopup()
	main:SetTitle("KShop - Copy Shop")
	main:ChangeW(main:GetWide()-90)

	local shop = {}

	local add = vgui.Create("DComboBox", main)
	add:SetSize(main:GetWide()-40, 40)
	add:SetValue("Select a Shop")
	for k, v in pairs(shops) do
		add:AddChoice(k..":   "..v["name"])
		shop[#shop+1] = {data = v, id = k}
	end
	add:SetPos(20,45)
	add:SetFont("ks1")
	add.selected = ""
	add.k = 0
	add.OnSelect = function(s, i, v)
		add.selected = v
		add.k = i
	end

	local save = vgui.Create("kshop_button", main)
	save:EnterText("Copy the Shop")
	save:SetSize(main:GetWide()-40, 40)
	save:SetPos(20, 95)
	save.DoClick = function()
		if add.k == nil or add.k == 0 or shop == nil then return end
		net.Start("KS_Copyshop_return")
			net.WriteTable(shop[add.k])
		net.SendToServer()

		main:Remove()

	end

end)

net.Receive("KS_AdminFunctions", function()
	local shops = net.ReadTable()
	if type(shops) == "String" then return end
	if not shops then return end
	local main = vgui.Create("kshop_frame")
	main:SetSize(350, 250)
	main:Center()
	main:MakePopup()
	main:SetTitle("KShop - Adminfunctions")
	main:ChangeW(main:GetWide()-90)


	-------------------------------------------------

	local shop = {}

	local add = vgui.Create("DComboBox", main)
	add:SetSize(main:GetWide()-125, 40)
	add:SetValue("Shop to delete")
	for k, v in pairs(shops) do
		add:AddChoice(k..":   "..v["name"])
		shop[#shop+1] = {data = v, id = k}
	end
	add:SetPos(20,45)
	add:SetFont("ks1")
	add.selected = ""
	add.OnSelect = function(s, i, v)
		add.selected = v
		add.k = i
	end
	
	local save = vgui.Create("kshop_button", main)
	save:EnterText("Delete")
	save:SetSize(80, 40)
	save:SetPos(main:GetWide()-100, 45)
	save.DoClick = function()
		if shop[add.k] == nil then return end
		net.Start("KS_DeleteShop")
			net.WriteTable(shop[add.k])
		net.SendToServer()

		main:Remove()
	end
	-------------------------------------

	local shop = {}

	local add = vgui.Create("DComboBox", main)
	add:SetSize(main:GetWide()-125, 40)
	add:SetValue("Shop to teleport")
	for k, v in pairs(shops) do
		add:AddChoice(k..":   "..v["name"])
		shop[#shop+1] = {data = v, id = k}
	end
	add:SetPos(20,45+50)
	add:SetFont("ks1")
	add.selected = ""
	add.OnSelect = function(s, i, v)
		add.selected = v
		add.k = i
	end
	
	local save = vgui.Create("kshop_button", main)
	save:EnterText("Teleport")
	save:SetSize(80, 40)
	save:SetPos(main:GetWide()-100, 45+50)
	save.DoClick = function()
		if shop[add.k] == nil then return end
		net.Start("KS_TeleportShop")
			net.WriteTable(shop[add.k])
		net.SendToServer()

		main:Remove()
	end

	-------------------------------------
	local respawn = vgui.Create("kshop_button", main)
	respawn:EnterText("Respawn Shops")
	respawn:SetSize(main:GetWide()-40, 40)
	respawn:SetPos(20, 95+50)
	respawn.DoClick = function()
		net.Start("KS_Respawn_All_Shops")
		net.SendToServer()
		main:Remove()
	end

	----------------------------------------------

	local delall = vgui.Create("kshop_button", main)
	delall:EnterText("Delete all shops (Last warning)")
	delall:SetSize(main:GetWide()-40, 40)
	delall:SetPos(20, 145+50)
	delall.DoClick = function()
		net.Start("KS_DeleteAllShops")
		net.SendToServer()
		main:Remove()
	end
end)