--Luctus Pusher
--Made by OverlordAkise

--This simple script allows you to push people around by pressing E with a specific weapon in hand

--Cooldown between pushes in seconds
LUCTUS_PUSH_COOLDOWN = 10
--Able to push vertical?
LUCTUS_PUSH_VERTICAL = true
--Push force in units
LUCTUS_PUSH_FORCE = 500
--Needed weapon to be able to push
LUCTUS_PUSH_WEAPON = "weapon_fists"


local sounds = {
    "physics/body/body_medium_impact_hard1.wav",
    "physics/body/body_medium_impact_hard2.wav",
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard4.wav",
    "physics/body/body_medium_impact_hard5.wav",
    "physics/body/body_medium_impact_hard6.wav",
    "physics/body/body_medium_impact_hard7.wav",
}

local cd = {}

local function HasCD(ply)
    if not cd[ply] then return false end
    if cd[ply] < CurTime() then return false end
    return true
end

hook.Add("KeyPress","luctus_pusher",function(ply,key)
    if key ~= IN_USE or HasCD(ply) then return end
    if not IsValid(ply:GetActiveWeapon()) or ply:GetActiveWeapon():GetClass() ~= LUCTUS_PUSH_WEAPON then return end
    local target = ply:GetEyeTrace().Entity
    if not IsValid(target) or not target:IsPlayer() or not target:Alive() or ply:GetPos():Distance(target:GetPos()) > 100 then return end
    
    local direction = ply:EyeAngles():Forward()
    if not LUCTUS_PUSH_VERTICAL then
        direction.z = 0
    end
    cd[ply] = CurTime()+LUCTUS_PUSH_COOLDOWN
    target:SetVelocity(direction*LUCTUS_PUSH_FORCE)
    target:ViewPunch(Angle(math.random(-30,30),math.random(-30,30),0))
    if SERVER then
        ply:EmitSound(sounds[math.random(#sounds)],100,100)
    end
end)

if CLIENT then
    hook.Add("HUDPaint","luctus_pusher",function()
        if not IsValid(LocalPlayer()) or not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= LUCTUS_PUSH_WEAPON then return end
        local ply = LocalPlayer():GetEyeTrace().Entity
        if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
        if HasCD(LocalPlayer()) then return end
        draw.SimpleTextOutlined("Press [E] to push","Trebuchet24",ScrW()/2,ScrH()*0.8, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER,2,color_black)
    end)
end

print("[luctus_pusher] sh loaded")
