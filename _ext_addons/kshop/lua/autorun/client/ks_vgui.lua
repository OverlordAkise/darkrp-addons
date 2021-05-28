local PANEL = {}

AccessorFunc(PANEL, "m_body", "Body")

function PANEL:Init()
	self.clw = 570
	self.header = self:Add("Panel")
	self.header:Dock(TOP)
	self.header.Paint = function(s, w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.primary)
		draw.RoundedBox(0,0,29,w,1,KShop.Themes.dark_underline)
	end

	self.header.close = self.header:Add("DButton")
	--self.header.close:Dock(RIGHT)
	self.header.close.DoClick = function()
		self:Remove()
	end

	--KShop.Themes
	--light_red = Color(250, 177, 160),
	--dark_red = Color(214, 48, 49),

	self.header.close:SetText("")
	self.header.close:SetSize(80,28)
	self.header.close:SetPos(self.clw, 1)
	self.header.close.Paint = function(s, w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
		draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)
	end
	local close = self.header.close
	close.mar = 0
	close.OnCursorEntered = function()
		close.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
			draw.RoundedBox(0,0,0,s.mar,h,KShop.Themes.dark_red)
			draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)

			if s.mar != w+4 then
				s.mar=s.mar+4
			end
		end
	end
	close.OnCursorExited = function()
		close.Paint = function(s, w, h)
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
			draw.RoundedBox(0,0,0,s.mar,h,KShop.Themes.dark_red)
			draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)

			if s.mar != 0 then
				s.mar=s.mar-4
			end
		end
	end


	self.header.title = self.header:Add("DLabel")
	self.header.title:Dock(LEFT)
	self.header.title:SetFont("ks1")
	self.header.title:SetTextColor(Color(255,255,255))
	self.header.title:SetTextInset(5,0)
end

function PANEL:ChangeW(w)
	self.header.close:SetPos(w, 1)
end

function PANEL:PerformLayout(w, h)
	self.header:SetTall(30)
end

function PANEL:SetTitle(text)
	self.header.title:SetText(text)
	self.header.title:SizeToContents()	
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h,KShop.Themes.primary)
end

vgui.Register("kshop_frame", PANEL, "EditablePanel")
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local PANEL = {}

AccessorFunc(PANEL, "m_body", "Body")

function PANEL:Init()
	self.buttons = {}
	self.panels = {}
end

function PANEL:GetTab(id)
	return self.buttons[id]
end

function PANEL:SetActive(id)
	local bt = self.buttons[id]
	if !IsValid(bt) then return end

	local abt = self.buttons[self.active]
	if IsValid(abt) then
		abt:SetTextColor(Color(255,255,255))

		local apnl = self.panels[self.active]
		if IsValid(apnl) then
			apnl:SetVisible(false)
		end
	end

	self.active = id 

	bt:SetTextColor(KShop.UIColor)
	--bt.DoClick()
end

function PANEL:AddTab(name, panel, doclick)
	local i = #self.buttons+1
	self.buttons[i] = self:Add("DButton")
	local bt = self.buttons[i]
	bt:Dock(TOP)
	bt:SetTall(35)
	bt.id = i
	if i != 1 then
		bt:DockMargin(0,2,0,0)
	end
	bt:SetText(name)
	bt:SetFont("ks3")
	bt.Paint = function(s, w, h)
		if self.active == bt.id then
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.sel_but)
			draw.RoundedBox(0,w-2,0,2,h,KShop.UIColor)
		else
			draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
			bt:SetTextColor(Color(255,255,255))
		end
	end
	bt:SizeToContentsY(24)
	bt:SetTextColor(Color(255,255,255))
	local taab = self
	function bt:SetSelfActive()
		taab:SetActive(bt.id)
	end
	bt.OnCursorEntered = function()
		local x = 0
		local ind = bt:GetTall()
		bt.Paint = function(s, w, h)
			if self.active == bt.id then
				draw.RoundedBox(0,0,0,w,h,KShop.Themes.sel_but)
				draw.RoundedBox(0,w-2,0,2,h,KShop.UIColor)
				bt:SetTextColor(KShop.UIColor)
			else
				draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
				draw.RoundedBox(0,w-2,0,2,x,KShop.UIColor)
				bt:SetTextColor(KShop.UIColor)
				if ind == 0 then return end
				x = x + 1
				ind = ind - 1
			end				
		end
	end

	bt.OnCursorExited = function()
		local x = bt:GetTall()
		bt.Paint = function(s, w, h)
			if self.active == bt.id then
				draw.RoundedBox(0,0,0,w,h,KShop.Themes.sel_but)
				draw.RoundedBox(0,w-2,0,2,h,KShop.UIColor)
				bt:SetTextColor(KShop.UIColor)
			else
				draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
				bt:SetTextColor(Color(255,255,255))
			end				
		end
	end
/*
	self.panels[i] = self:GetBody():Add(panel or "DPanel")
	panel = self.panels[i]
	panel:SetPos(150, 0)
	--panel:Dock(FILL)
	panel:SetVisible(false)*/
	return bt
end

function PANEL:SetActiveName(name)
	for k, v in pairs(self.buttons) do
		if v:GetText() == name then
			self:SetActive(v.id)
			break
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h, KShop.Themes.primary)
end


vgui.Register("KShop_sidebar", PANEL)
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local PANEL = {}

AccessorFunc(PANEL, "m_body", "Body")

function PANEL:Init()
	self.sidebar = vgui.Create("KShop_sidebar", self)
	self.sidebar:SetBody(self)
	self:Dock(LEFT)
	self.sidebar:Dock(LEFT)
end

function PANEL:AddTab(name, panel, click)
	self.sidebar:AddTab(name, panel or "DPanel", click)
end

function PANEL:SetActiveName(name)
	self.sidebar:SetActiveName(name)
end

function PANEL:SetActive(id)
	self.sidebar:SetActive(id)
end

function PANEL:GetTab(id)
	return self.sidebar:GetTab(id)
end

function PANEL:Paint(w, h)
end

function PANEL:PerformLayout(w, h)
	self:SetWide(500)
	self:SetPos(150,0)
	self.sidebar:SetWide(150)
end


vgui.Register("KShop_sidetab", PANEL)
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()

	self.scrollpanel = self:Add("DScrollPanel")
	local scroll = self.scrollpanel
	scroll:Dock(FILL)
end

vgui.Register("kshop_itemtab", PANEL)
--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 450)
	self:SetPos(150,30)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,255))
end

vgui.Register("kshop_panel", PANEL, "Panel")

local PANEL = {}

function PANEL:Init()

end

function PANEL:SetData()
	self.one = 0
	self.two = 0
	self.three = self:GetWide()
	self.four = self:GetTall()

	self.onemax = self:GetWide()
	self.twomax = self:GetTall()
	self.threemax = 0
	self.fourmax = 0
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,1,Color(80,80,80))
	draw.RoundedBox(0,0,h-1,w,1,Color(80,80,80))
	draw.RoundedBox(0,0,0,1,h,Color(80,80,80))
	draw.RoundedBox(0,w-1,0,1,h,Color(80,80,80))
	self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))
end

function PANEL:OnCursorEntered()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,1,Color(80,80,80))
		draw.RoundedBox(0,0,h-1,w,1,KShop.UIColor)

		draw.RoundedBox(0,0,0,1,h,KShop.UIColor)--

		draw.RoundedBox(0,w-1,0,1,h,Color(80,80,80))

		draw.RoundedBox(0,0,0,self.one,1,KShop.UIColor)
		draw.RoundedBox(0,0,h-1,self.three,1,Color(80,80,80))
		draw.RoundedBox(0,0,0,1,self.four,Color(80,80,80))--
		draw.RoundedBox(0,w-1,0,1,self.two,KShop.UIColor)

		if self.one + 2 > w then
			self.one = w
		else
			self.one = self.one + 2
		end
		if self.one == w then
			if self.two + 2 > h then
				self.two = h
			else
				self.two = self.two + 2
			end
		end
		if self.two == h then
			if self.three - 2 < 0 then
				self.three = 0
			else
				self.three = self.three - 2
			end
		end
		if self.three == 0 then
			if self.four - 2 < 0 then
				self.four = 0
			else
				self.four = self.four - 2
			end
		end
		self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))
	end
end

function PANEL:OnCursorExited()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,1,Color(80,80,80))
		draw.RoundedBox(0,0,h-1,w,1,KShop.UIColor)

		draw.RoundedBox(0,0,0,1,h,KShop.UIColor)--

		draw.RoundedBox(0,w-1,0,1,h,Color(80,80,80))

		draw.RoundedBox(0,0,0,self.one,1,KShop.UIColor) --obere
		draw.RoundedBox(0,0,h-1,self.three,1,Color(80,80,80))--unten
		draw.RoundedBox(0,0,0,1,self.four,Color(80,80,80))--links
		draw.RoundedBox(0,w-1,0,1,self.two,KShop.UIColor)--rechts

		//Links runda
		if self.one == self.onemax && self.two == self.twomax && self.three == self.threemax then
			if self.four + 2 > h then
				self.four = h
			else
				self.four = self.four + 2
			end
		end

		//Unten runda
		if self.one == self.onemax && self.two == self.twomax && self.four == h then
			if self.three + 2 > w then
				self.three = w
			else
				self.three = self.three + 2
			end
		end

		//rechts hoch
		if self.one == self.onemax && self.three == w && self.four == h then
			if self.two - 2 < 0 then
				self.two = 0
			else
				self.two = self.two - 2
			end
		end

		//hoch hinda
		if self.three == w && self.four == h && self.two == 0 then
			if self.one - 2 < 0 then
				self.one = 0
			else
				self.one = self.one - 2
			end
		end

		self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))
	end
end

vgui.Register("kshop_dtext", PANEL, "DTextEntry")

--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]
local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 420)
	self:SetPos(150,30)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h,Color(0,0,0,255))
end

vgui.Register("kshop_panel", PANEL, "Panel")

local PANEL = {}

function PANEL:Init()
	self.backcolor = Color(0,0,0)
	self.draw = false
	self.color = Color(100,100,100)
	self.alpha = 0
end

function PANEL:SetData()
	self.alpha = 0
	self.color = Color(100,100,100)
end

function PANEL:Paint(w, h)
	if self.draw then
		draw.RoundedBox(0,0,0,w,h,self.backcolor)
	end
	draw.RoundedBox(0,0,0,w,1,self.color)
	draw.RoundedBox(0,0,h-1,w,1,self.color)
	draw.RoundedBox(0,0,0,1,h,self.color)
	draw.RoundedBox(0,w-1,0,1,h,self.color)
	self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))
end

function PANEL:SetBackColor(col)
	self.backcolor = col
end

function PANEL:PaintBack(bool)
	self.draw = bool
end

function PANEL:OnCursorEntered()
	function self:Paint(w, h)
		if self.draw then
			draw.RoundedBox(0,0,0,w,h,self.backcolor)
		end
		draw.RoundedBox(0,0,0,w,1,self.color)
		draw.RoundedBox(0,0,h-1,w,1,self.color)
		draw.RoundedBox(0,0,0,1,h,self.color)
		draw.RoundedBox(0,w-1,0,1,h,self.color)
		self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))

		local c = KShop.UIColor
		draw.RoundedBox(0,0,0,w,1,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,0,h-1,w,1,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,0,0,1,h,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,w-1,0,1,h,Color(c.r, c.g, c.b, self.alpha))

		if self.alpha + 4 > 255 then
			self.alpha = 255
		else
			self.alpha = self.alpha + 4
		end
	end
end

function PANEL:OnCursorExited()
	function self:Paint(w, h)
		if self.draw then
			draw.RoundedBox(0,0,0,w,h,self.backcolor)
		end
		draw.RoundedBox(0,0,0,w,1,self.color)
		draw.RoundedBox(0,0,h-1,w,1,self.color)
		draw.RoundedBox(0,0,0,1,h,self.color)
		draw.RoundedBox(0,w-1,0,1,h,self.color)
		self:DrawTextEntryText(Color(255,255,255), KShop.UIColor, Color(255,255,255))

		local c = KShop.UIColor
		draw.RoundedBox(0,0,0,w,1,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,0,h-1,w,1,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,0,0,1,h,Color(c.r, c.g, c.b, self.alpha))
		draw.RoundedBox(0,w-1,0,1,h,Color(c.r, c.g, c.b, self.alpha))

		if self.alpha - 4 < 0 then
			self.alpha = 0
		else
			self.alpha = self.alpha - 4
		end

	end
end

vgui.Register("kshop_dtext2", PANEL, "DTextEntry")

local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.mar = 0
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
	draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)
end

function PANEL:OnCursorEntered()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
		draw.RoundedBox(0,0,0,self.mar,h,KShop.Themes.dark_red)
		draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)

		if self.mar != w+4 then
			self.mar=self.mar+4
		end
	end
end

function PANEL:OnCursorExited()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.light_red)
		draw.RoundedBox(0,0,0,self.mar,h,KShop.Themes.dark_red)
		draw.SimpleText("X", "ks1", w/2, h/2, Color(255,255,255), 1, 1)

		if self.mar != 0 then
			self.mar=self.mar-4
		end
	end
end

vgui.Register("kshop_close", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
	self:SetText("")
	self.mar = 0
	self.text = ""
end

function PANEL:EnterText(text)
	self.text = text
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
	draw.SimpleText(self.text, "ks1", w/2, h/2, Color(255,255,255), 1, 1)
end

function PANEL:OnCursorEntered()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
		draw.RoundedBox(0,0,0,self.mar,h,KShop.UIColor)
		draw.SimpleText(self.text, "ks1", w/2, h/2, Color(255,255,255), 1, 1)

		if self.mar != w+4 then
			self.mar=self.mar+4
		end
	end
end

function PANEL:OnCursorExited()
	function self:Paint(w, h)
		draw.RoundedBox(0,0,0,w,h,KShop.Themes.buttons)
		draw.RoundedBox(0,0,0,self.mar,h,KShop.UIColor)
		draw.SimpleText(self.text, "ks1", w/2, h/2, Color(255,255,255), 1, 1)

		if self.mar != 0 then
			self.mar=self.mar-4
		end
	end
end

vgui.Register("kshop_button", PANEL, "DButton")