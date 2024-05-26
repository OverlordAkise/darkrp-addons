--Luctus Streetrobber
--Made by OverlordAkise

local scrw = ScrW()
local scrh = ScrH()
local offset = Vector(0, 0, 45)
local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)
local color_black_t = Color(0,0,0,210)
local color_green = Color(20,255,20,255)
local color_green_t = Color(40,255,40,180)
local color_red = Color(255,20,20,255)

surface.CreateFont("LuctusStreetRob", {
    font = "Verdana",
    extended = false,
    size = 56,
    weight = 100,
})

local eyeTraceEnt = nil
local holdingE = false
local canIRob = false
timer.Create("luctus_streetrobber_cache",0.1,0,function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    holdingE = ply:KeyDown(IN_USE)
    local myent = ply:GetEyeTrace().Entity
    if IsValid(myent) and myent:IsPlayer() and LuctusCanBeStreetRobbed(ply,myent) and myent:GetNW2Bool("lstreetrobbable",false) and ply:GetNW2Bool("lstreetrobbable",false) then
        eyeTraceEnt = myent
        canIRob = true
    else
        eyeTraceEnt = false
        canIRob = false
    end
end)

local width = scrw/4
local startX = scrw/2-width/2
local startY = scrh/1.5
local height = 60
hook.Add("HUDPaint","luctus_streetrobber",function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not canIRob then return end
    if not holdingE or not IsValid(eyeTraceEnt) then return end
    local progress = math.min((eyeTraceEnt:GetNW2Float("lstreetrob_progress",0)*width)/100)
    draw.RoundedBox(0,startX,startY,width,height,color_black_t)
    draw.RoundedBox(0,startX+2,startY+2,(progress)-4,height-4,color_green_t)
    draw.SimpleTextOutlined("Robbing...","Trebuchet24",scrw/2,startY+height/2,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,color_black)
end)

hook.Add("PostPlayerDraw", "luctus_streetrobber",function(ply)
    local lply = LocalPlayer()
    if ply == lply or not ply:Alive() then return end
    if lply:GetPos():Distance(ply:GetPos()) > 256 then return end
    local ang = lply:EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(ply:GetPos() + offset + ang:Right()*5 + ang:Forward()*15, Angle(0, ang.y, 90), 0.05)
        draw.RoundedBox(0,-160,-30,320,70,color_black_t)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawOutlinedRect(-160,-30,320,70)
        local tRobbable = ply:GetNW2Bool("lstreetrobbable",false)
        local meCanRob = lply:GetNW2Bool("lstreetrobbable",false)
        if tRobbable and meCanRob then
            draw.SimpleText("Robbable", "LuctusStreetRob", 2, 2, color_green, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Not robbable", "LuctusStreetRob", 2, 2, color_red, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end)

print("[luctus_streetrobber] cl loaded")
