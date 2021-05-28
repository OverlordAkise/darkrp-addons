function KShop:PaintScroll(panel)
	local scr 				= panel:GetVBar()
	scr.Paint 				= function() draw.RoundedBox(0, 0, 0, scr:GetWide(), scr:GetTall(), Color(62, 62, 62)) end
	scr.btnUp.Paint 		= function() end
	scr.btnDown.Paint 		= function() end
	scr.btnGrip.Paint 		= function() draw.RoundedBox(6, 2, 0, scr.btnGrip:GetWide()-4, scr.btnGrip:GetTall()-2, Color(255,0,0)) end
end

function KShop:BuyMenu(shop, ent, restr, canSee)
	local SHOPITEMS = shop
	if type(SHOPITEMS) == "string" then return end
	if not IsValid(ent) then return end

	if canSee == false then
		if KShop.isAdmin(LocalPlayer()) then
			net.Start("KS_RequestEdit")
				net.WriteEntity(ent)
				net.WriteTable(shop)
				net.WriteTable(restr)
			net.SendToServer()
		end
		return
	end

	local lb = Color(15, 188, 249)
	local main = vgui.Create("kshop_frame")
	main:SetSize(650, 450)
	main:Center()
	main:MakePopup()
	main:SetTitle("KShop - Buymenu")

	if KShop.isAdmin(LocalPlayer()) then
		edit = main:Add("DImageButton")
		edit.DoClick = function()
			net.Start("KS_RequestEdit")
				net.WriteEntity(ent)
				net.WriteTable(shop)
				net.WriteTable(restr)
			net.SendToServer()
			main:Remove()
		end

		edit:SetText("")
		edit:SetSize(30,30)
		edit:SetPos(530,0)
		edit.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,lb)
			draw.SimpleText("⚙", "ks4", 14,8, Color(42,42,42), 1, 1)
		end
		edit.mar = 0
		edit.OnCursorEntered = function()
			edit.Paint = function(s, w, h)
				draw.RoundedBox(0,0,0,w,h,lb)
				draw.RoundedBox(0,0,0,s.mar,h,KShop.UIColor)
				draw.SimpleText("⚙", "ks4", 14,8, Color(42,42,42), 1, 1)
				if s.mar +2 > w then
					s.mar = w
				else
					s.mar=s.mar+2
				end
			end
		end
		edit.OnCursorExited = function()
			edit.Paint = function(s, w, h)
				draw.RoundedBox(0,0,0,w,h,lb)
				draw.RoundedBox(0,0,0,s.mar,h,KShop.UIColor)
				draw.SimpleText("⚙", "ks4", 14,8, Color(42,42,42), 1, 1)
				if s.mar - 2 < 0 then
					s.mar = 0
				else
					s.mar=s.mar-2
				end
			end
		end
	end

	local bar = main:Add("KShop_sidetab")
	if shop != nil then
		local ind = 0
		--------------LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOP
		local cet = {}
		local ishop = shop
		for k, v in pairs(shop) do
			if cet[v.category] == true then continue end
			cet[v.category] = true
			ind = ind + 1
			bar:AddTab(v.category, "kshop_itempanel")

			local tab = bar:GetTab(ind)
			tab.cat = v.category
			tab.DoClick = function()
				local tub = vgui.Create("kshop_panel", main)
				tub.Paint = function(s, w, h)
					draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
				end

				tub:DockPadding(8,8,8,8)

				local itemtab = vgui.Create("DScrollPanel", tub)
				itemtab:Dock(FILL)
				local ind = 0
				----------------------------------------LOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOP
				for i, s in pairs(ishop) do
					ind = ind + 1
					if s.category == tab.cat then
						local ss = itemtab:Add("DButton")
						ss:SetText("")
						ss:Dock(TOP)
						ss:SetSize(itemtab:GetWide()-32, 50)
						if ind != 1 then
							ss:DockMargin(0,2,0,0)
						else
							ss:DockMargin(0,1,0,0)
						end

						local loop = s
						ss.Paint = function(s, w, h)
							draw.RoundedBox(6,0,0,w,h,KShop.Themes.buypanel)
							--draw.SimpleText(loop.name, "ks1", 5, h/2, Color(40,40,40), TEXT_ALIGN_LEFT, 1)
						end
						ss.mar = 0
						ss.OnCursorEntered = function()
							ss.Paint = function(s, w, h)
								draw.RoundedBox(6,0,0,w,h,KShop.Themes.buypanel)
								draw.RoundedBox(2,0,h-2,s.mar,2,KShop.UIColor)
								--draw.SimpleText(loop.name, "ks1", 5, h/2, Color(40,40,40), TEXT_ALIGN_LEFT, 1)
								if s.mar + 8 > w then
									s.mar = w
								else
									s.mar = s.mar + 8
								end
							end
						end
						ss.OnCursorExited = function()
							ss.Paint = function(s, w, h)
								draw.RoundedBox(6,0,0,w,h,KShop.Themes.buypanel)
								draw.RoundedBox(2,0,h-2,s.mar,2,KShop.UIColor)
								--draw.SimpleText(loop.name, "ks1", 5, h/2, Color(40,40,40), TEXT_ALIGN_LEFT, 1)
								if s.mar - 8 < 0 then
									s.mar = 0
								else
									s.mar = s.mar - 8
								end
							end
						end

						local pan = vgui.Create("DLabel", ss)
						pan:SetText(s.name)
						pan.item = s
						pan:SetFont("ks1")
						pan:SetTextColor(Color(62,62,62))
						pan:Dock(LEFT)
						pan:SizeToContentsX(8)
						pan.Paint = function(s, w, h)
							draw.RoundedBox(6,0,0,w,h,KShop.Themes.dark_one)
							draw.RoundedBox(0,w-20,0,20,h,KShop.Themes.dark_one)
							draw.RoundedBox(2,0,h-2,ss.mar,2,KShop.UIColor)
						end
						pan:SetContentAlignment(5)

						local buycolor = Color(255,255,255)

						if not LocalPlayer():canAfford(s.price) then
							buycolor = Color(255, 77, 77)
						end

						local price = s.price

						local buy = vgui.Create("DButton", ss)
						buy:SetText("Buy "..DarkRP.formatMoney(s.price))
						buy:SetFont("ks1")
						buy:SetTall(32)
						buy:SizeToContentsX(24)
						buy:SetPos(470-buy:GetSize(), ss:GetTall()/2-16)
						buy:SetTextColor(buycolor)
						buy.mar = 0
						buy.Paint = function(s, w, h)
							draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
							if !LocalPlayer():canAfford(price) then
								buycolor = Color(255, 77, 77)
							else
								buycolor = Color(255,255,255)
							end
							s:SetTextColor(buycolor)
						end
						buy.OnCursorEntered = function()
							buy.Paint = function(s, w, h)
								draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
								draw.RoundedBox(0,0,0,s.mar,h,KShop.UIColor)
								if s.mar + 2 > w then
									s.mar = w
								else
									s.mar = s.mar + 2
								end
							end
						end

						buy.OnCursorExited = function()
							buy.Paint = function(s, w, h)
								draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
								draw.RoundedBox(0,0,0,s.mar,h,KShop.UIColor)
								if s.mar - 2 < 0 then
									s.mar = 0
								else
									s.mar = s.mar - 2
								end
							end
						end
						buy.DoClick = function()
							net.Start("KS_BuyItem")
								net.WriteTable(pan.item)--item (id?)
                net.WriteEntity(ent)--shop ent
							net.SendToServer()
							surface.PlaySound("buttons/button9.wav")
						end
					end
				end
				tab:SetSelfActive()
			end

			bar:SetActive(1)
			local bt = bar.sidebar.buttons[1]
			bt.DoClick()
		end
	end
end

net.Receive("KS_OpenShop", function()
	local shop = net.ReadTable()
	KShop:BuyMenu(shop, net.ReadEntity(), net.ReadTable(), net.ReadBool())
end)