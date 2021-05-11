include("shared.lua")

surface.CreateFont("Billboard Font", {
	font = "Arial",
	size = 28
})

surface.CreateFont("Billboard Title Font", {
	font = "Arial",
	size = 42
})

local MoneyLeaderboard = {}

net.Receive("SendMoneyLeaderboard", function()
	MoneyLeaderboard = net.ReadTable()
	for k,v in pairs(MoneyLeaderboard) do
		MoneyLeaderboard[k].wallet = "$" .. string.Comma(v.wallet)
	end
end)

local header = Color(55, 55, 55)
local bg = Color(25, 25, 25)
local white = Color(255, 255, 255)
function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetAngles():Up(), 90)

	cam.Start3D2D(self:GetPos() + self:GetAngles():Right() * 47 + self:GetAngles():Up() * 5 - self:GetAngles():Forward() * 46, ang, 0.1)

        surface.SetDrawColor(bg)
	    surface.DrawRect(100, 165, 750, 85)

        surface.SetDrawColor(header)
	    surface.DrawRect(100, 250, 750, 530)

	    draw.SimpleText("Money Leaderboard", "Billboard Title Font", 465, 210, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        

        for k, v in pairs(MoneyLeaderboard) do
        	draw.SimpleText(tostring(k) .. ":", "Billboard Font", 180, 240 + k * 50, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        	draw.SimpleText(v.rpname, "Billboard Font", 465, 240 + k * 50, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        	draw.SimpleText(v.wallet , "Billboard Font", 750, 240 + k * 50, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

	    
	cam.End3D2D()
end

