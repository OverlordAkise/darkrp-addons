KShop = {}
KShop.Shops = {}

KShop.AddShopCommand = "addshop"

KShop.CopyShopCommand = "copyshop"

KShop.AdminShopCommand = "adminshop"

--Admingroups
KShop.Admins = {"superadmin", "admin", "supervisor", "owner"}

--MAximum armor, a player can have.
KShop.MaxArmor = 100

KShop.UIColor = Color(69, 170, 242)
KShop.Themes = {
	primary = Color(83, 92, 104),
	secondary = Color(123, 132, 144),
	dark_underline = Color(53, 72, 74),
	buttons = Color(99, 110, 114),
	sel_but = Color(79, 90, 94),

	light_red = Color(250, 157, 140),
	dark_red = Color(214, 48, 49),

	buypanel = Color(180,190,195),
	dark_one = Color(150,160,165),
}

--Do not edit below unless you know, what you're doing.
function KShop:Message(m, t)
	if t == 1 then
		col = Color(200,50,50) --Error
	elseif t == 2 then
		col = Color(255,125,0) --Warning
	elseif t == 3 then
		col = Color(50,255,50) --Success
	elseif t == 4 then
		col = Color(255,255,255) --Neutral
	end
	MsgC(col, "##Kiwontas Shopsystem##: "..tostring(m).."\n")
end

function KShop.isAdmin(ply)
	return table.HasValue(KShop.Admins, ply:GetUserGroup())
end