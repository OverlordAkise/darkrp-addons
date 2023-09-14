--Luctus Highlight Enemies
--Made by OverlordAkise

--This script highlights enemies (=people not in the same team as you)
--with a red border around their playermodel
--Only if enemy is within 512 units or you are zoomed in with a weapon lower than 70 FOV

local jobTeam = {}

hook.Add("InitPostEntity","luctus_highlight_load",function()
    jobTeam = {
    [TEAM_CITIZEN] = {
        [TEAM_GUN]=true,
    },
    [TEAM_GUN] = {
        [TEAM_CITIZEN]=true,
    },
    }
end)

local color_red = Color(255,0,0,255)
local enemies = {}
timer.Create("luctus_highlight_enemies",1,0,function()
    enemies = {}
    local myteam = LocalPlayer():Team()
    local mypos = LocalPlayer():GetPos()
    local scale = LocalPlayer():GetFOV() >= 70 and 512 or math.huge
    for k,ply in ipairs(player.GetAll()) do
        if jobTeam[myteam] and jobTeam[myteam][ply:Team()] then continue end
        if myteam == ply:Team() or mypos:Distance(ply:GetPos()) > scale then continue end
        table.insert(enemies,ply)
    end
end)
hook.Add("PreDrawHalos", "luctus_highlight_enemies", function()
	halo.Add(enemies, color_red, 1, 1, 1)
end)

print("[luctus_highlight_enemies] cl loaded")
