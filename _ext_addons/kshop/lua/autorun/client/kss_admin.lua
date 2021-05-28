function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

function KShop:PaintScroll(panel)
	local scr 				= panel:GetVBar()
	scr.Paint 				= function() end
	scr.btnUp.Paint 		= function() end
	scr.btnDown.Paint 		= function() end
	scr.btnGrip.Paint 		= function() draw.RoundedBox(6, 2, 0, scr.btnGrip:GetWide()-4, scr.btnGrip:GetTall()-2, KShop.UIColor) end
end

function KShop:EditShop(data, shop, items, restr)
	if not IsValid(shop) then return end
	local id = shop:GetShopID()
	local main = vgui.Create("kshop_frame")
	main:SetSize(650, 580)
	main:Center()
	main:MakePopup()
	main:SetTitle("KShop - Edit shop")
	main.model = ""
	main.name = ""
	main.npc = false
	main.items = items

	main.typ = ""
	main.iname = ""
	main.iprice = 0
	main.icat = ""
	main.iitem = ""

	main.x_offset = 0
	main.y_offset = 0

	main.restr = restr
	local ddata = data
	local sval = data
	sval = sval[id]
	if IsValid(shop) then
		main.name = shop:GetShopName()
		main.model = shop:GetModel()
		main.npc = sval.npc
		main.x_offset = shop:GetNWInt("shop_x_offset", 0)
		main.y_offset = shop:GetNWInt("shop_y_offset", 0)
	else
		main.name = "No Name"
		main.model = "models/props_interiors/VendingMachineSoda01a.mdl"
		main.npc = false
	end

	local bar = main:Add("KShop_sidetab")
	bar:AddTab("General", "kshop_itempanel")
	bar:AddTab("Model", "kshop_itempanel")
	bar:AddTab("Items | Entities", "kshop_itempanel")
	bar:AddTab("Currtent Items", "kshop_itempanel")
	bar:AddTab("Save Shop", "kshop_itempanel")

--[[-------------------------------------------------------------------------
General
---------------------------------------------------------------------------]]
	local tab = bar:GetTab(1)
	tab.DoClick = function()
		local tub = vgui.Create("kshop_panel", main)
		tub.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
			draw.SimpleText("Shopname", "ks1", 20, 10, Color(255,255,255))
			draw.SimpleText("Is NPC (true or false)", "ks1", 20, 100, Color(255,255,255))
			draw.SimpleText("Remove a single job", "ks1", 20, 180, Color(255,255,255))
			draw.SimpleText("Whitelist SteamIDs (32 only)", "ks1", 20, 340, Color(255,255,255))
			draw.SimpleText("X-Offset", "ks1", 20, 430, Color(255,255,255))
			draw.SimpleText("Y-Offset", "ks1", w/2+5, 430, Color(255,255,255))
		end
		tub:SetTall(550)		
		tab:SetSelfActive()

		local name = vgui.Create("kshop_dtext2", tub)
		name:SetSize(tub:GetWide()-40, 40)
		name:SetPos(20, 45)
		name:SetText(main.name)
		name:SetFont("ks3")
		name.OnChange = function()
			main.name = name:GetValue()
		end
		name:SetData()

		local npc = vgui.Create("kshop_dtext2", tub)
		npc:SetSize(tub:GetWide()-40, 40)
		npc:SetPos(20, 130)
		npc:SetText(tostring(main.npc))
		npc:SetFont("ks3")
		npc:SetBackColor(Color(200,50,50))
		npc.OnChange = function()
			local val = npc:GetValue()
			if val == "true" then
				main.npc = true
				npc:PaintBack(false)
			elseif val == "false" then
				main.npc = false
				npc:PaintBack(false)
			else
				npc:PaintBack(true)
			end
		end
		npc:SetData()

		local res = vgui.Create("DComboBox", tub)
		res:SetSize(tub:GetWide()-130, 40)
		res:SetValue("Select a Job/id to remove")
		if restr != nil then
			for k, v in pairs(restr) do
				res:AddChoice(v)
			end
		end
		res:SetPos(20,210)
		res:SetFont("ks1")
		res.value = ""
		res.OnSelect = function(s, i, v)
			res.value = v
		end
		local rem = vgui.Create("kshop_button", tub)
		rem:EnterText("Remove")
		rem:SetSize(80, 40)
		rem:SetPos(tub:GetWide()-20-80, 210)
		rem.DoClick = function()
			if table.HasValue(restr, res.value) then
				for k, v in pairs(restr) do
					if v == res.value then
						restr[k] = nil
						res:SetValue("Select a Job to remove")
						local sshop = shop
						local iitems = items 
						local rrestr = restr
						main:Remove()
						KShop:EditShop(ddata, sshop, iitems, rrestr)
					end
				end
			end
		end

		----------------------------------------------

		local add = vgui.Create("DComboBox", tub)
		add:SetSize(tub:GetWide()-130, 40)
		add:SetValue("Select a Job to add")
		for k, v in pairs(RPExtraTeams) do
			if restr == nil or not table.HasValue(restr, v.name) then
				add:AddChoice(v.name)
			end
		end
		add:SetPos(20,280)
		add:SetFont("ks1")
		add.v = ""
		add.OnSelect = function(s, i, v)
			add.v = v
		end
		local sav = vgui.Create("kshop_button", tub)
		sav:EnterText("Add")
		sav:SetSize(80, 40)
		sav:SetPos(tub:GetWide()-20-80, 280)
		sav.DoClick = function()
			if restr == nil then
				restr = {}
			end
			table.insert(restr, add.v)
			local sshop = shop
			local iitems = items 
			local rrestr = restr
			main:Remove()
			KShop:EditShop(ddata, sshop, iitems, rrestr)
			add:SetValue("Select a Job to add")
		end

		--------------------------------

		local steamid = vgui.Create("kshop_dtext2", tub)
		steamid:SetSize(tub:GetWide()-40-90, 40)
		steamid:SetPos(20, 370)
		steamid:SetText("")
		steamid:SetFont("ks3")
		steamid.id = ""
		steamid.OnChange = function()
			steamid.id = steamid:GetValue()
		end
		steamid:SetData()

		local addid = vgui.Create("kshop_button", tub)
		addid:EnterText("Add")
		addid:SetSize(80, 40)
		addid:SetPos(tub:GetWide()-20-80, 370)
		addid.DoClick = function()
			if restr == nil then
				restr = {}
			end
			table.insert(restr, steamid.id)
			local sshop = shop
			local iitems = items 
			local rrestr = restr
			main:Remove()
			KShop:EditShop(ddata, sshop, iitems, rrestr)
			add:SetValue("Select a Job to add")
		end

		-------------------------------
		-- offset
		local x_of = vgui.Create("kshop_dtext2", tub)
		x_of:SetSize((tub:GetWide()-40)/2-5, 40)
		x_of:SetPos(20, 370+90)
		x_of:SetText(main.x_offset)
		x_of:SetFont("ks3")
		x_of:SetBackColor(Color(200,50,50))
		x_of.OnChange = function()
			if isnumber(tonumber(x_of:GetValue())) then
				main.x_offset = tonumber(x_of:GetValue())
				x_of:PaintBack(false)
			else
				main.x_offset = 0
				x_of:PaintBack(true)
			end
		end
		x_of:SetData()

		local y_of = vgui.Create("kshop_dtext2", tub)
		y_of:SetSize((tub:GetWide()-40)/2-5, 40)
		y_of:SetPos(20 + ((tub:GetWide()-40)/2-10) + 10, 370+90)
		y_of:SetText(main.y_offset)
		y_of:SetFont("ks3")
		y_of:SetBackColor(Color(200,50,50))
		y_of.OnChange = function()
			if isnumber(tonumber(y_of:GetValue())) then
				main.y_offset = tonumber(y_of:GetValue())
				y_of:PaintBack(false)
			else
				main.y_offset = 0
				y_of:PaintBack(true)
			end
		end
		y_of:SetData()



	end
--[[-------------------------------------------------------------------------
Model
---------------------------------------------------------------------------]]
	local tab = bar:GetTab(2)
	tab.DoClick = function()
		local tub = vgui.Create("kshop_panel", main)
		tub.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
		end
		tub:SetTall(550)	
		tab:SetSelfActive()

		local smdl = tub:Add("DModelPanel")
		--smdl:Dock(LEFT)
		smdl:SetSize(tub:GetWide(), tub:GetTall()-80)
		smdl:SetMouseInputEnabled(true)
		smdl.LayoutEntity = function() end
		local oldPaint = baseclass.Get("DModelPanel").Paint
		smdl.Paint = function(pnl, w, h)
		    draw.RoundedBoxEx(6, 0, 0, w, h, Color(0, 0, 0, 100), false, false, false, false)
		 
		    oldPaint(pnl, w, h)
			end
		smdl:SetModel(main.model)
		local mn, mx = smdl.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
		size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
		size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
		smdl:SetFOV(70)
		smdl:SetCamPos(Vector(size - 45, size + 30, size-20))
		smdl:SetLookAt((mn + mx) * 0.5)

		smdl.rot = 110
		smdl.fov = 120
		smdl:SetFOV( smdl.fov )
		smdl.dragging = false -- left click
		smdl.dragging2 = false -- right click
		smdl.ux = 0
		smdl.uy = 0
		smdl.spinmul = 0.4
		smdl.zoommul = 0.09

		smdl.xmod = 0
		smdl.ymod = 0


		function smdl:LayoutEntity( ent )

			local newrot = self.rot
			local newfov = self:GetFOV()

			if self.dragging == true then
				newrot = self.rot + (gui.MouseX() - self.ux)*self.spinmul
				newfov = self.fov + (self.uy - gui.MouseY()) * self.zoommul
				--if newfov < 20 then newfov = 20 end
				--if newfov > 75 then newfov = 75 end
			end

			local newxmod, newymod = self.xmod, self.ymod

			if self.dragging2 == true then
				newxmod = self.xmod + (self.ux - gui.MouseX())*0.02
				newymod = self.ymod + (self.uy - gui.MouseY())*0.02
			end

			newxmod = math.Clamp( newxmod, -16, 16 )
			newymod = math.Clamp( newymod, -16, 16 )

			ent:SetAngles( Angle(0,0,0) )
			self:SetFOV( newfov )

			-- calculate if we should look at the face
			local height = 100
			-- fov between 20 and 75,
			-- height between 72/2 and 72
			local frac = InverseLerp( newfov, 75, 20 )
			height = Lerp( frac, 72/2, 64 )

			-- calculate look ang
			local norm = (self:GetCamPos() - Vector(0,0,64))
			norm:Normalize()
			local lookAng = norm:Angle()

			self:SetLookAt( Vector(0,0,height-(2*frac) ) - Vector( 0, 0, newymod*2*(1-frac) ) - lookAng:Right()*newxmod*2*(1-frac) )
			self:SetCamPos( Vector( 64*math.sin( newrot * (math.pi/180)), 64*math.cos( newrot * (math.pi/180)), height + 4*(1-frac)) - Vector( 0, 0, newymod*2*(1-frac) ) - lookAng:Right()*newxmod*2*(1-frac) )

		end

		function smdl:OnMousePressed( k )
			self.ux = gui.MouseX()
			self.uy = gui.MouseY()
			self.dragging = (k == MOUSE_LEFT) or false 
			self.dragging2 = (k == MOUSE_RIGHT) or false 
		end

		function smdl:OnMouseReleased( k )
			if self.dragging == true then
				self.rot = self.rot + (gui.MouseX() - self.ux)*self.spinmul
				self.fov = self.fov + (self.uy - gui.MouseY()) * self.zoommul
				self.fov = math.Clamp( self.fov, 20, 75 )
			end

			if self.dragging2 == true then
				self.xmod = self.xmod + (self.ux - gui.MouseX())*0.02
				self.ymod = self.ymod + (self.uy - gui.MouseY())*0.02

				self.xmod = math.Clamp( self.xmod, -16, 16 )
				self.ymod = math.Clamp( self.ymod, -16, 16 )
			end

			self.dragging = false 
			self.dragging2 = false
		end

		function smdl:OnCursorExited()
			if self.dragging == true or self.dragging2 == true then
				self:OnMouseReleased()
			end
		end


		local mdltxt = vgui.Create("kshop_dtext2", tub)
		mdltxt:SetSize(tub:GetWide()-40, 40)
		mdltxt:SetPos(20, tub:GetTall()-60)
		mdltxt:SetText(main.model)
		mdltxt:SetFont("ks3")
		mdltxt:SetBackColor(Color(200,50,50))
		mdltxt.OnChange = function()
			if string.find(mdltxt:GetValue(),".mdl") then
				smdl:SetModel(mdltxt:GetValue())
				main.model = mdltxt:GetValue()
				mdltxt:PaintBack(false)
			else
				mdltxt:PaintBack(true)
			end
		end
		mdltxt:SetData()

	end

--[[-------------------------------------------------------------------------
Items | Entities
---------------------------------------------------------------------------]]
	local tab = bar:GetTab(3)
	tab.DoClick = function()
		local tub = vgui.Create("kshop_panel", main)

		tub.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
			draw.SimpleText("Itemname", "ks1", 20, 70, Color(255,255,255))
			draw.SimpleText("Price (Numbers only)", "ks1", 20, 150, Color(255,255,255))
			draw.SimpleText("Category (A new will automatically created)", "ks1", 20, 230, Color(255,255,255))
			draw.SimpleText(tub.typ, "ks1", 20, 310, Color(255,255,255))
		end

		tub.typ = "Select a Type..."
		tub.delay = CurTime()
		tub:SetTall(550)	

		tub.Think = function()
			if tub.delay > CurTime() then return end
			tub.delay = CurTime() + 0.75
			if tub.typ == "Select a Type..." then
				tub.typ = "Select a Type"
			elseif tub.typ == "Select a Type" then
				tub.typ = "Select a Type."
			elseif tub.typ == "Select a Type." then
				tub.typ = "Select a Type.."
			elseif tub.typ == "Select a Type.." then
				tub.typ = "Select a Type..."
			end
		end

		local typ = vgui.Create("DComboBox", tub)
		typ:SetSize(tub:GetWide()-40, 40)
		typ:SetValue("Select a Type")
		typ:AddChoice("Give a Weapon")
		typ:AddChoice("Spawn a Entity")
		typ:AddChoice("Give HP")
		typ:AddChoice("Give Armor")
		typ:SetPos(20,20)
		typ:SetFont("ks1")
		typ.OnSelect = function(s, i, v)
			if v == "Give a Weapon" then
				tub.typ = "Enter a classname"
				main.typ = "weapon"
			elseif v == "Spawn a Entity" then
				tub.typ = "Enter a classname"
				main.typ = "entity"
			elseif v == "Give HP" then
				tub.typ = "Enter a value (numbers only)"
				main.typ = "hp"
			elseif v == "Give Armor" then
				tub.typ = "Enter a value (numbers only)"
				main.typ = "armor"
			end
		end
		if main.typ != "" then
			typ:SetValue(main.typ)
		end



		local iname = vgui.Create("kshop_dtext2", tub)
		iname:SetSize(tub:GetWide()-40, 40)
		iname:SetPos(20, 100)
		iname:SetText(main.iname)
		iname:SetFont("ks3")
		iname:SetBackColor(Color(200,50,50))
		iname.OnChange = function()
			main.iname = iname:GetValue()
		end
		iname:SetData()


		local ipr = vgui.Create("kshop_dtext2", tub)
		ipr:SetSize(tub:GetWide()-40, 40)
		ipr:SetPos(20, 180)
		ipr:SetText(main.iprice)
		ipr:SetFont("ks3")
		ipr:SetBackColor(Color(200,50,50))
		ipr.OnChange = function()
			if isnumber(tonumber(ipr:GetValue())) then
				main.iprice = tonumber(ipr:GetValue())
				ipr:PaintBack(false)
			else
				ipr:PaintBack(true)
			end
		end
		ipr:SetData()

		local icat = vgui.Create("kshop_dtext2", tub)
		icat:SetSize(tub:GetWide()-40, 40)
		icat:SetPos(20, 260)
		icat:SetText(main.icat)
		icat:SetFont("ks3")
		icat:SetBackColor(Color(200,50,50))
		icat.OnChange = function()
			main.icat = icat:GetValue()
		end
		icat:SetData()

		local iitem = vgui.Create("kshop_dtext2", tub)
		iitem:SetSize(tub:GetWide()-40, 40)
		iitem:SetPos(20, 340)
		iitem:SetText(main.iitem)
		iitem:SetFont("ks3")
		iitem:SetBackColor(Color(200,50,50))
		iitem.OnChange = function()
			main.iitem = iitem:GetValue()
		end
		iitem:SetData()

		local save = vgui.Create("kshop_button", tub)
		save:EnterText("Save")
		save:SetSize(tub:GetWide()-40, 40)
		save:SetPos(20, 390)
		save.DoClick = function()
			local typ = main.typ
			local name = main.iname
			local cat = main.icat
			local price = main.iprice
			local item = main.iitem
			local newitem = {}
			newitem.typ = typ

			if name != "" and name != nil then
				newitem.name = name
			else
				return
			end

			if cat != "" and cat != nil then
				newitem.category = cat
			else
				return
			end

			if price != nil and isnumber(tonumber(price)) then
				newitem.price = tonumber(price)
			else
				return
			end

			if typ == "weapon" then
				if item != "" and item != nil then
					newitem.item = item
				else
					return
				end				
			elseif typ == "entity" then
				if item != "" and item != nil then
					newitem.item = item
				else
					return
				end					
			elseif typ == "hp" then
				if item != 0 and isnumber(tonumber(item)) then
					newitem.hp = tonumber(item)
				else
					return
				end					
			elseif typ == "armor" then
				if item != 0 and isnumber(tonumber(item)) then
					newitem.armor = tonumber(item)
				else
					return
				end
			else
				LocalPlayer():ChatPrint("You need to select a type!")
				return				
			end
			iitem:SetText("")
			icat:SetText("")
			ipr:SetText("")
			iname:SetText("")

			table.insert(main.items, #main.items+1, newitem)

		end

		tab:SetSelfActive()		
	end
--[[-------------------------------------------------------------------------
Current Items
---------------------------------------------------------------------------]]
	local tab = bar:GetTab(4)
	tab.DoClick = function()
		local tub = vgui.Create("kshop_panel", main)
		tub.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
		end

		tub:DockPadding(8,8,8,8)
		tub:SetTall(550)	

		tab:SetSelfActive()
		local scroll = vgui.Create("DScrollPanel", tub)
		scroll:Dock(FILL)
		self:PaintScroll(scroll)

		local acats = {}
		local totalcats = {}

		local curcat = {}
		local index = 0
		local keintems = items

		for k, l in pairs(items) do
			index = index + 1
			local mcat = scroll:Add("DPanel")
			mcat:Dock(TOP)
			mcat:DockMargin(0,2,0,0)
			mcat:SetTall(40)
			mcat.int = k
			mcat.Paint = function(s, w, h)
				draw.RoundedBox(6,0,0,w,h,KShop.Themes.buypanel)
				draw.RoundedBox(0,0,0,w, 2, KShop.UIColor)

				draw.RoundedBoxEx(6,0,0,w,h,KShop.Themes.buypanel, true, false, true, false)
				if l.typ == "weapon" or l.typ == "entity" then
					draw.SimpleText(l.name..", $: "..l.price..", Class: "..l.item, "ks1", 5, h/2,Color(62,62,62), TEXT_ALIGN_LEFT, 1)
				elseif l.typ == "hp" then
					draw.SimpleText(l.name..", $: "..l.price..", HP: "..l.hp, "ks1", 5, h/2,Color(62,62,62), TEXT_ALIGN_LEFT, 1)
				elseif l.typ == "armor" then
					draw.SimpleText(l.name..", $: "..l.price..", Armor: "..l.armor, "ks1", 5, h/2,Color(62,62,62), TEXT_ALIGN_LEFT, 1)
				end
			end
			PrintTable(l)

			local delete = vgui.Create("kshop_close", mcat)
			delete:SetSize(60,30)
			delete:SetPos(tub:GetWide()-100, 5)
			delete.DoClick = function()
				items[k] = nil
				mcat:Remove()
			end
			local edit = vgui.Create("DButton", mcat)
			edit:SetSize(60,30)
			edit:SetText("Edit")
			edit:SetFont("ks1")
			edit:SetTextColor(Color(255,255,255,255))
			edit.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,Color(62,62,62, 200))
				if self:IsHovered() then
					draw.RoundedBox(0,0,0,w,h,Color(0,128,255, (CurTime()*1) * 300 %255))
					draw.RoundedBox(0,0,0,w,h,Color(0,128,255, (CurTime()*-1) * 300 %255))
				else

				end
			end
			edit:SetPos(tub:GetWide()-100-70, 5)
			edit.DoClick = function()
				items[k] = nil
				mcat:Remove()
				main.typ = l.typ
				main.iname = l.name
				main.icat = l.category
				main.iprice = l.price
				if l.typ == "weapon" or l.typ == "entity" then
					main.iitem = l.item
				elseif l.typ == "hp" then
					main.iitem = l.hp
				elseif l.typ == "armor" then
					main.iitem = l.armor
				end				
				local tab = bar:GetTab(3)
				tab.DoClick()
			end
		end
	end

--[[-------------------------------------------------------------------------
Save Shop
---------------------------------------------------------------------------]]
	local tab = bar:GetTab(5)
	tab.DoClick = function()
		local tub = vgui.Create("kshop_panel", main)
		tub.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.secondary)
		end
		tub:SetTall(550)	
		tab:SetSelfActive()	

		local name = main.name
		local model = main.model
		local npc = main.npc

		local o_x = main.x_offset
		local o_y = main.y_offset

		net.Start("KS_RetrieveEdits")
			net.WriteTable({
				ent = shop,
				name = name,
				items = main.items,
				jobs = restr,
				model = model,
				npc = npc,
				x_offset = o_x,
				y_offset = o_y
			})
		net.SendToServer()

		main:Remove()
	end
--[[-------------------------------------------------------------------------
other
---------------------------------------------------------------------------]]
	bar:SetActive(1)
	local bt = bar.sidebar.buttons[1]
	bt.DoClick()
end


net.Receive("KS_EditShop", function()
	KShop:EditShop(net.ReadTable(), net.ReadEntity(), net.ReadTable(), net.ReadTable())
end)