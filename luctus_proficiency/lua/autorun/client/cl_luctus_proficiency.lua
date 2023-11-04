--Luctus Weapon Proficiency
--Made by OverlordAkise

local nodrawCache = {}
timer.Create("luctus_proficiency_nodraw",1,0,function()
    nodrawCache = {}
    local me = LocalPlayer()
    if not IsValid(me) then return end
    local mypos = me:GetPos()
    for k,ply in ipairs(player.GetHumans()) do
        --print("ply",ply,mypos:Distance(ply:GetPos()))
        if ply == me or mypos:Distance(ply:GetPos()) > 128 then
            nodrawCache[ply] = true
        end
    end
end)

local function getLevel(ply)
    return math.floor(ply:GetNW2Int("luctus_proficiency",0)/LUCTUS_PROFICIENCY_XP_REQUIRED)
end

surface.CreateFont("luctus_prof", {
    font = "Arial",
    size = 90,
    weight = 500,
    shadow = true,
    outline = true,
})

hook.Add("PostPlayerDraw","luctus_proficiency",function(ply)
    if nodrawCache[ply] then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local bb = ply:LookupBone("ValveBiped.Bip01_R_Hand")
    if not bb then return end

    local matrix = ply:GetBoneMatrix(bb)
    if not matrix then return end
    local pos = matrix:GetTranslation()
    local ang = matrix:GetAngles()
    pos = pos + (ang:Forward() *3)
    pos = pos + (ang:Right() *-1)
    pos = pos + (ang:Up() *-1)
    ang:RotateAroundAxis(ang:Forward(), -90)

    cam.Start3D2D(pos,ang,0.05)
        draw.SimpleText(getLevel(ply),"luctus_prof",0,0,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    cam.End3D2D()
end)

local color_dark = Color(50,50,50,250)
local color_white = Color(255,255,255,255)
local color_accent = Color(0, 195, 165)
hook.Add("HUDPaint","luctus_proficiency",function()
    draw.RoundedBox(0, ScrW()*0.6, ScrH()-30, 100, 30, color_accent)
    draw.RoundedBox(0, ScrW()*0.6+1, ScrH()-30+1, 100-2, 30-2, color_dark)
    draw.SimpleText("Proficiency: "..getLevel(ply),"Trebuchet18",ScrW()*0.6+10,ScrH()-15,color_white,TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)
end)

print("[luctus_proficiency] cl loaded")
